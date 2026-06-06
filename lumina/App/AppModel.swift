//
//  AppModel.swift
//  lumina
//

import Foundation

enum AppPhase: Equatable {
    case restoring
    case setup
    case validating
    case signIn
    case signingIn
    case home
    case loadingPlayback
    case playback(PlaybackProof)
}

@MainActor
final class AppModel: ObservableObject {
    @Published var phase: AppPhase = .restoring
    @Published var serverURLString: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var statusMessage: String?
    @Published var capabilities: ServerCapabilities?
    @Published var currentUser: LuminaUser?
    @Published var playbackProof: PlaybackProof?
    @Published var homeHeroItems: [CatalogItem] = []
    @Published var homeSections: [CatalogSection] = []
    @Published var movies: [CatalogItem] = []
    @Published var tvShows: [CatalogItem] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [CatalogItem] = []
    @Published var isCatalogLoading = false
    @Published var selectedCatalogItem: CatalogItem?
    @Published var selectedTVSeasons: [TVSeasonSummary] = []
    @Published var selectedTVEpisodes: [CatalogItem] = []
    @Published var selectedSeasonNumber: Int?
    @Published var selectedEditorialSection: CatalogSection?
    @Published var isDetailLoading = false
    @Published var isEditorialLoading = false

    private let tokenStore: TokenStore
    private let settingsStore: ServerSettingsStore
    private let diagnostics: DiagnosticsRecorder
    private let playbackProofLoader: PlaybackProofLoader
    private let apiClientFactory: (URL, ServerCapabilities?) -> LuminaAPIClient
    private var playbackLoadID: UUID?
    private var searchLoadID: UUID?
    private var detailLoadID: UUID?
    private var editorialLoadID: UUID?

    init(
        tokenStore: TokenStore = TokenStoreFactory.defaultStore(),
        settingsStore: ServerSettingsStore = UserDefaultsServerSettingsStore(),
        diagnostics: DiagnosticsRecorder = DiagnosticsRecorder(),
        playbackProofLoader: PlaybackProofLoader = PlaybackProofLoader(),
        apiClientFactory: @escaping (URL, ServerCapabilities?) -> LuminaAPIClient = {
            URLSessionLuminaAPIClient(baseURL: $0, capabilities: $1)
        }
    ) {
        self.tokenStore = tokenStore
        self.settingsStore = settingsStore
        self.diagnostics = diagnostics
        self.playbackProofLoader = playbackProofLoader
        self.apiClientFactory = apiClientFactory
        self.serverURLString = settingsStore.serverURLString ?? ""
        self.phase = .setup
    }

    func restoreSession() async {
        guard phase == .restoring || phase == .setup else {
            return
        }
        guard let storedServer = settingsStore.serverURLString, normalizeServerURL(storedServer) != nil else {
            phase = .setup
            return
        }
        serverURLString = storedServer
        do {
            guard let session = try await authSessionRepository().restore(normalizeServerURL: normalizeServerURL) else {
                phase = .signIn
                return
            }
            serverURLString = session.serverURL.absoluteString
            capabilities = session.capabilities
            currentUser = session.user
            phase = .home
            statusMessage = nil
            await loadCatalog()
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "restore_session", phase: .auth)
            handleSessionError(error, fallbackPhase: .signIn)
        } catch {
            diagnostics.record(operation: "restore_session", message: "\(error)")
            statusMessage = "Sign in again to continue."
            phase = .signIn
        }
    }

    func validateServer() async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            phase = .setup
            return
        }

        phase = .validating
        do {
            let capabilities = try await authSessionRepository().validateServer(url)
            self.capabilities = capabilities
            serverURLString = url.absoluteString
            statusMessage = nil
            phase = .signIn
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "validate_server", phase: .setup)
            statusMessage = error.safeMessage
            phase = .setup
        } catch {
            diagnostics.record(operation: "validate_server", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
            phase = .setup
        }
    }

    func signIn() async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            phase = .setup
            return
        }
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty, !password.isEmpty else {
            statusMessage = "Enter your Lumina email and password."
            phase = .signIn
            return
        }

        phase = .signingIn
        do {
            let session = try await authSessionRepository().signIn(
                serverURL: url,
                email: email,
                password: password
            )
            capabilities = session.capabilities
            currentUser = session.user
            password = ""
            statusMessage = nil
            phase = .home
            await loadCatalog()
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "sign_in", phase: .auth)
            statusMessage = error.safeMessage
            phase = .signIn
        } catch {
            diagnostics.record(operation: "sign_in", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
            phase = .signIn
        }
    }

    func signOut() {
        playbackLoadID = nil
        searchLoadID = nil
        detailLoadID = nil
        editorialLoadID = nil
        authSessionRepository().signOut()
        currentUser = nil
        selectedEditorialSection = nil
        isEditorialLoading = false
        password = ""
        phase = .signIn
        statusMessage = "Signed out."
    }

    func loadCatalog() async {
        guard phase == .home, !isCatalogLoading else { return }
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            return
        }
        isCatalogLoading = true
        defer { isCatalogLoading = false }

        do {
            let token = try authSessionRepository().token()
            let repository = catalogRepository(for: url, token: token)
            applyHomeSnapshot(try await repository.loadHome())
            statusMessage = nil
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "load_catalog", phase: .catalog)
            handleSessionError(error)
        } catch {
            diagnostics.record(operation: "load_catalog", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
        }
    }

    func runSearch() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            return
        }
        let loadID = UUID()
        searchLoadID = loadID
        isCatalogLoading = true
        defer { isCatalogLoading = false }

        do {
            let token = try authSessionRepository().token()
            let repository = catalogRepository(for: url, token: token)
            let results = try await repository.search(query: query)
            guard searchLoadID == loadID else { return }
            searchResults = results
            statusMessage = searchResults.isEmpty ? "No catalog results found." : nil
        } catch let error as LuminaClientError {
            guard searchLoadID == loadID else { return }
            diagnostics.record(error: error, operation: "catalog_search", phase: .catalog)
            handleSessionError(error)
        } catch {
            guard searchLoadID == loadID else { return }
            diagnostics.record(operation: "catalog_search", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
        }
    }

    func openCatalogDetail(_ item: CatalogItem) async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            return
        }
        isDetailLoading = true
        let loadID = UUID()
        detailLoadID = loadID
        selectedCatalogItem = item
        selectedTVSeasons = []
        selectedTVEpisodes = []
        selectedSeasonNumber = nil
        defer { isDetailLoading = false }

        do {
            let token = try authSessionRepository().token()
            let repository = catalogRepository(for: url, token: token)
            if item.mediaType == "tv_show" {
                let snapshot = try await repository.tvShowDetail(showId: item.id)
                guard detailLoadID == loadID else { return }
                applyTVShowDetailSnapshot(snapshot)
            } else if item.mediaType == "movie" {
                let detail = try await repository.movieDetail(movieId: item.id)
                guard detailLoadID == loadID else { return }
                selectedCatalogItem = detail
            }
            statusMessage = nil
        } catch let error as LuminaClientError {
            guard detailLoadID == loadID else { return }
            diagnostics.record(error: error, operation: "catalog_detail", phase: .catalog)
            handleSessionError(error)
        } catch {
            guard detailLoadID == loadID else { return }
            diagnostics.record(operation: "catalog_detail", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
        }
    }

    func selectTVSeason(_ season: TVSeasonSummary) async {
        guard let show = selectedCatalogItem, show.mediaType == "tv_show" else {
            return
        }
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            return
        }
        selectedSeasonNumber = season.seasonNumber
        isDetailLoading = true
        defer { isDetailLoading = false }

        do {
            let token = try authSessionRepository().token()
            let repository = catalogRepository(for: url, token: token)
            selectedTVEpisodes = try await repository.episodes(showId: show.id, seasonNumber: season.seasonNumber)
            statusMessage = selectedTVEpisodes.isEmpty ? "No episodes found for this season." : nil
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "catalog_tv_episodes", phase: .catalog)
            handleSessionError(error)
        } catch {
            diagnostics.record(operation: "catalog_tv_episodes", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
        }
    }

    func closeCatalogDetail() {
        selectedCatalogItem = nil
        selectedTVSeasons = []
        selectedTVEpisodes = []
        selectedSeasonNumber = nil
    }

    func openEditorialSection(_ section: CatalogSection) async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            return
        }
        let loadID = UUID()
        editorialLoadID = loadID
        selectedEditorialSection = section
        isEditorialLoading = true
        defer {
            if editorialLoadID == loadID {
                isEditorialLoading = false
            }
        }

        do {
            let token = try authSessionRepository().token()
            let repository = catalogRepository(for: url, token: token)
            let editorialSection = try await repository.editorialSection(sectionId: section.id)
            guard editorialLoadID == loadID else { return }
            selectedEditorialSection = editorialSection
            statusMessage = nil
        } catch let error as LuminaClientError {
            guard editorialLoadID == loadID else { return }
            diagnostics.record(error: error, operation: "catalog_editorial", phase: .catalog)
            handleSessionError(error)
        } catch {
            guard editorialLoadID == loadID else { return }
            diagnostics.record(operation: "catalog_editorial", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
        }
    }

    func closeEditorialSection() {
        editorialLoadID = nil
        selectedEditorialSection = nil
        isEditorialLoading = false
    }

    func playCatalogMovie(_ item: CatalogItem) async {
        guard item.mediaType == "movie" else {
            statusMessage = "Episode playback from catalog shelves is not wired yet."
            return
        }
        await loadPlaybackProof(movieOverride: item.playableMovie)
    }

    func openTrailer(_ item: CatalogItem) {
        statusMessage = "Trailer playback is not wired yet."
        diagnostics.record(operation: "catalog_trailer", message: "Trailer selected for \(item.mediaType) \(item.id)")
    }

    func openCatalogLink(_ item: CatalogItem) {
        statusMessage = "\(item.title) browsing is not wired yet."
        diagnostics.record(operation: "catalog_link", message: "Catalog link selected: \(item.id)")
    }

    func loadPlaybackProof() async {
        await loadPlaybackProof(movieOverride: nil)
    }

    private func loadPlaybackProof(movieOverride: PlayableMovie?) async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            phase = .setup
            return
        }
        let loadID = UUID()
        playbackLoadID = loadID
        phase = .loadingPlayback
        var result: PlaybackProofLoadResult?
        var playbackToken: String?
        var playbackClient: LuminaAPIClient?
        do {
            let token = try authSessionRepository().token()
            playbackToken = token
            let client = apiClient(for: url)
            playbackClient = client
            result = try await playbackProofLoader.loadMovieProof(
                movieOverride: movieOverride,
                token: token,
                client: client
            )
            guard playbackLoadID == loadID else {
                await stopPlaybackSessionIfNeeded(
                    result?.session,
                    client: client,
                    token: token,
                    positionSeconds: result?.resumePositionSeconds ?? 0
                )
                return
            }
            guard let result else { return }
            let proof = result.proof
            playbackProof = proof
            phase = .playback(proof)
            statusMessage = nil
        } catch let error as LuminaClientError {
            if let playbackClient, let playbackToken {
                await stopPlaybackSessionIfNeeded(
                    result?.session,
                    client: playbackClient,
                    token: playbackToken,
                    positionSeconds: result?.resumePositionSeconds ?? 0
                )
            }
            guard playbackLoadID == loadID else { return }
            diagnostics.record(error: error, operation: "load_playback_proof", phase: .playback)
            handleSessionError(error, fallbackPhase: .home)
        } catch {
            if let playbackClient, let playbackToken {
                await stopPlaybackSessionIfNeeded(
                    result?.session,
                    client: playbackClient,
                    token: playbackToken,
                    positionSeconds: result?.resumePositionSeconds ?? 0
                )
            }
            guard playbackLoadID == loadID else { return }
            diagnostics.record(operation: "load_playback_proof", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
            phase = .home
        }
    }

    private func stopPlaybackSessionIfNeeded(
        _ session: PlaybackSessionResponse?,
        client: LuminaAPIClient,
        token: String,
        positionSeconds: Double
    ) async {
        guard let session else { return }
        try? await client.stopPlaybackSession(sessionId: session.id, positionSeconds: positionSeconds, token: token)
    }

    func reportPlaybackProgress(positionSeconds: Double, event: String) async {
        guard let proof = playbackProof, let url = normalizeServerURL(serverURLString) else {
            return
        }
        do {
            let token = try authSessionRepository().token()
            let client = apiClient(for: url)
            try await client.reportProgress(
                ProgressUpdateRequest(
                    mediaId: proof.movie.id,
                    positionSeconds: positionSeconds,
                    durationSeconds: proof.movie.durationSeconds,
                    playState: event == "exit" ? "paused" : event
                ),
                token: token
            )
            if let sessionId = proof.sessionId {
                if event == "exit" || event == "stopped" {
                    try await client.stopPlaybackSession(sessionId: sessionId, positionSeconds: positionSeconds, token: token)
                } else {
                    try await client.updatePlaybackSession(sessionId: sessionId, positionSeconds: positionSeconds, playState: event, token: token)
                }
            }
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "playback_progress", phase: .playback)
            if error == .sessionExpired || error == .missingToken {
                authSessionRepository().signOut()
            }
        } catch {
            diagnostics.record(operation: "playback_progress", message: "\(error)")
        }
    }

    func exitPlayback() {
        playbackLoadID = nil
        playbackProof = nil
        phase = .home
    }

    func recordPlaybackFailure(_ message: String) {
        diagnostics.record(operation: "avkit_playback", phase: .playback, message: message)
        statusMessage = DiagnosticsRecorder.redact(message)
    }

    func recordPlaybackMediaOptions(
        audioCount: Int,
        subtitleCount: Int,
        backendTracks: MediaTrackListing?,
        manifestInspection: HLSManifestInspection?
    ) {
        let backendAudioCount = backendTracks?.tracks.audio.count ?? 0
        let backendEmbeddedSubtitleCount = backendTracks?.tracks.subtitles.embedded.count ?? 0
        let backendExternalSubtitleCount = backendTracks?.tracks.subtitles.external.count ?? 0
        let manifestAudioCount = manifestInspection?.audioRenditionCount ?? 0
        let manifestSubtitleCount = manifestInspection?.subtitleRenditionCount ?? 0
        let nonPlaylistSubtitleCount = manifestInspection?.nonPlaylistSubtitleRenditionCount ?? 0
        let severity: DiagnosticsSeverity = mediaSelectionSeverity(
            avkitAudioCount: audioCount,
            avkitSubtitleCount: subtitleCount,
            backendAudioCount: backendAudioCount,
            backendSubtitleCount: backendEmbeddedSubtitleCount + backendExternalSubtitleCount,
            manifestAudioCount: manifestAudioCount,
            manifestSubtitleCount: manifestSubtitleCount,
            nonPlaylistSubtitleCount: nonPlaylistSubtitleCount
        )
        diagnostics.record(
            operation: "avkit_media_selection",
            phase: .playback,
            severity: severity,
            message: "AVKit media options audio=\(audioCount) subtitles=\(subtitleCount); HLS media audio=\(manifestAudioCount) subtitles=\(manifestSubtitleCount) non_playlist_subtitles=\(nonPlaylistSubtitleCount); backend audio=\(backendAudioCount) embedded_subtitles=\(backendEmbeddedSubtitleCount) external_subtitles=\(backendExternalSubtitleCount)"
        )
    }

    private func mediaSelectionSeverity(
        avkitAudioCount: Int,
        avkitSubtitleCount: Int,
        backendAudioCount: Int,
        backendSubtitleCount: Int,
        manifestAudioCount: Int,
        manifestSubtitleCount: Int,
        nonPlaylistSubtitleCount: Int
    ) -> DiagnosticsSeverity {
        if backendAudioCount > 0, manifestAudioCount == 0 {
            return .warning
        }
        if backendSubtitleCount > 0, manifestSubtitleCount == 0 {
            return .warning
        }
        if manifestAudioCount > 0, avkitAudioCount == 0 {
            return .warning
        }
        if manifestSubtitleCount > 0, avkitSubtitleCount == 0 {
            return .warning
        }
        if nonPlaylistSubtitleCount > 0 {
            return .warning
        }
        return .info
    }

    func recordPlaybackMediaOptionsUnavailable(_ message: String) {
        diagnostics.record(
            operation: "avkit_media_selection",
            phase: .playback,
            severity: .warning,
            message: message
        )
    }

    func artworkURL(for path: String?, kind: CatalogArtworkKind) -> URL? {
        guard let serverURL = normalizeServerURL(serverURLString) else { return nil }
        return ArtworkURLResolver(serverURL: serverURL).url(for: path, kind: kind)
    }

    func resetServer() {
        playbackLoadID = nil
        searchLoadID = nil
        detailLoadID = nil
        editorialLoadID = nil
        try? tokenStore.clearToken()
        settingsStore.serverURLString = nil
        capabilities = nil
        currentUser = nil
        homeHeroItems = []
        homeSections = []
        movies = []
        tvShows = []
        searchQuery = ""
        searchResults = []
        selectedCatalogItem = nil
        selectedTVSeasons = []
        selectedTVEpisodes = []
        selectedSeasonNumber = nil
        selectedEditorialSection = nil
        isEditorialLoading = false
        playbackProof = nil
        email = ""
        password = ""
        statusMessage = nil
        phase = .setup
    }

    func normalizeServerURL(_ value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: candidate), url.host != nil else {
            return nil
        }
        return url
    }

    private func apiClient(for url: URL) -> LuminaAPIClient {
        apiClientFactory(url, capabilities)
    }

    private func catalogRepository(for url: URL, token: String) -> CatalogRepository {
        CatalogRepository(client: apiClient(for: url), token: token)
    }

    private func authSessionRepository() -> AuthSessionRepository {
        AuthSessionRepository(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: apiClientFactory
        )
    }

    private func applyHomeSnapshot(_ snapshot: CatalogHomeSnapshot) {
        homeHeroItems = snapshot.heroItems
        homeSections = snapshot.sections
        movies = snapshot.movies
        tvShows = snapshot.tvShows
    }

    private func applyTVShowDetailSnapshot(_ snapshot: TVShowDetailSnapshot) {
        selectedCatalogItem = snapshot.show
        selectedTVSeasons = snapshot.seasons
        selectedSeasonNumber = snapshot.selectedSeasonNumber
        selectedTVEpisodes = snapshot.episodes
    }

    private func handleSessionError(_ error: LuminaClientError, fallbackPhase: AppPhase = .home) {
        if error == .sessionExpired || error == .missingToken {
            authSessionRepository().signOut()
            currentUser = nil
            playbackProof = nil
            playbackLoadID = nil
            statusMessage = error.safeMessage
            phase = .signIn
            return
        }
        statusMessage = error.safeMessage
        phase = fallbackPhase
    }
}
