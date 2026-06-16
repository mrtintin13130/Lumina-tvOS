//
//  AppModel.swift
//  lumina
//

import Foundation

enum AppPhase: Equatable {
    case restoring
    case setup
    case validating
    case serverUnavailable
    case signIn
    case signingIn
    case home
    case loadingPlayback
    case playback(PlaybackProof)
}

enum HomeTab: Hashable {
    case home
    case movies
    case tvShows
    case search
    case settings
}

struct SupportSummary: Equatable {
    let appBuild: String
    let serverSummary: String
    let apiSummary: String
    let validationSummary: String
    let diagnosticsSummary: String
    let userDisplayName: String
    let lastSafeError: String
    let lastSupportId: String
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
    @Published var selectedHomeTab: HomeTab = .home
    var automaticCatalogRefreshEnabled = true

    private let tokenStore: TokenStore
    private let settingsStore: ServerSettingsStore
    private let diagnostics: DiagnosticsRecorder
    private let apiClientFactory: (URL, ServerCapabilities?) -> LuminaAPIClient
    private let serverConnectionTester: ServerConnectionTesting
    private let sessionState: SessionStateModel
    private let catalogState: CatalogStateModel
    private let playbackState: PlaybackStateModel

    var supportSummary: SupportSummary {
        let lastError = diagnostics.events.last { $0.severity == .error }
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let serverSummary: String
        let apiSummary: String
        let validationSummary: String
        let diagnosticsSummary: String

        if let capabilities {
            serverSummary = "\(capabilities.server.name) \(capabilities.server.version)"
            apiSummary = "\(capabilities.api.version) / min \(capabilities.api.minimumTvClientVersion)"
            validationSummary = capabilities.isTvMVPCompatible ? L10n.text("Compatible") : L10n.text("Not compatible")
            diagnosticsSummary = capabilities.diagnostics.clientEventUpload
                ? L10n.text("Local events only; server upload available")
                : L10n.text("Local events only")
        } else {
            serverSummary = L10n.text("Not validated")
            apiSummary = L10n.text("Not validated")
            validationSummary = L10n.text("Not validated")
            diagnosticsSummary = L10n.text("Local events only")
        }

        return SupportSummary(
            appBuild: "\(appVersion) (\(buildNumber))",
            serverSummary: DiagnosticsRecorder.redact(serverSummary),
            apiSummary: DiagnosticsRecorder.redact(apiSummary),
            validationSummary: validationSummary,
            diagnosticsSummary: "\(diagnosticsSummary) - \(diagnostics.events.count) \(L10n.text("events"))",
            userDisplayName: DiagnosticsRecorder.redact(currentUser?.displayName ?? L10n.text("Unknown")),
            lastSafeError: DiagnosticsRecorder.redact(statusMessage ?? lastError?.message ?? L10n.text("None")),
            lastSupportId: DiagnosticsRecorder.redact(lastError?.supportId ?? L10n.text("None"))
        )
    }

    init(
        tokenStore: TokenStore = TokenStoreFactory.defaultStore(),
        settingsStore: ServerSettingsStore = UserDefaultsServerSettingsStore(),
        diagnostics: DiagnosticsRecorder = DiagnosticsRecorder(),
        playbackProofLoader: PlaybackProofLoader = PlaybackProofLoader(),
        apiClientFactory: @escaping (URL, ServerCapabilities?) -> LuminaAPIClient = {
            URLSessionLuminaAPIClient(baseURL: $0, capabilities: $1)
        },
        serverConnectionTester: ServerConnectionTesting? = nil
    ) {
        self.tokenStore = tokenStore
        self.settingsStore = settingsStore
        self.diagnostics = diagnostics
        self.apiClientFactory = apiClientFactory
        self.serverConnectionTester = serverConnectionTester
            ?? ServerConnectionTester(apiClientFactory: apiClientFactory)
        self.sessionState = SessionStateModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: apiClientFactory,
            serverConnectionTester: self.serverConnectionTester
        )
        self.catalogState = CatalogStateModel()
        self.playbackState = PlaybackStateModel(
            playbackProofLoader: playbackProofLoader,
            diagnostics: diagnostics
        )
        syncFromSessionState()
        syncFromCatalogState()
        syncFromPlaybackState()
        self.phase = .setup
    }

    func restoreSession() async {
        guard phase == .restoring || phase == .setup || phase == .serverUnavailable else {
            return
        }
        do {
            guard try await sessionState.restore(normalizeServerURL: normalizeServerURL) != nil else {
                syncFromSessionState()
                phase = .signIn
                return
            }
            syncFromSessionState()
            phase = .home
            await loadCatalog()
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "restore_session", phase: .auth)
            switch error {
            case .sessionExpired, .missingToken:
                handleSessionError(error, fallbackPhase: .signIn)
            default:
                sessionState.statusMessage = error.safeMessage
                syncFromSessionState()
                phase = .serverUnavailable
            }
        } catch {
            diagnostics.record(operation: "restore_session", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromSessionState()
            phase = .serverUnavailable
        }
    }

    func validateServer() async {
        copyToSessionState()
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            phase = .setup
            return
        }

        phase = .validating
        do {
            try await sessionState.validateServer(url)
            syncFromSessionState()
            phase = .signIn
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "validate_server", phase: .setup)
            sessionState.statusMessage = error.safeMessage
            syncFromSessionState()
            phase = .setup
        } catch {
            diagnostics.record(operation: "validate_server", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromSessionState()
            phase = .setup
        }
    }

    func chooseDiscoveredServer(_ server: LuminaDiscoveredServer) async {
        guard let url = server.baseURL else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            phase = .setup
            return
        }
        serverURLString = url.absoluteString
        await validateServer()
    }

    func retrySavedServer() async {
        guard sessionState.retrySavedServer() else {
            phase = .setup
            return
        }
        syncFromSessionState()
        phase = .restoring
        await restoreSession()
    }

    func searchForServer() {
        statusMessage = nil
        phase = .setup
    }

    func signIn() async {
        copyToSessionState()
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            phase = .setup
            return
        }

        phase = .signingIn
        do {
            _ = try await sessionState.signIn(serverURL: url)
            syncFromSessionState()
            phase = .home
            await loadCatalog()
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "sign_in", phase: .auth)
            sessionState.statusMessage = error.safeMessage
            syncFromSessionState()
            phase = .signIn
        } catch {
            diagnostics.record(operation: "sign_in", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromSessionState()
            phase = .signIn
        }
    }

    func signOut() {
        playbackState.exit()
        catalogState.reset()
        sessionState.signOut()
        syncFromSessionState()
        syncFromCatalogState()
        syncFromPlaybackState()
        phase = .signIn
    }

    func loadCatalog() async {
        guard phase == .home, !isCatalogLoading else { return }
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            return
        }
        catalogState.isCatalogLoading = true
        syncFromCatalogState()
        defer {
            catalogState.isCatalogLoading = false
            syncFromCatalogState()
        }

        do {
            let token = try sessionState.token()
            let repository = catalogRepository(for: url, token: token)
            catalogState.applyHomeSnapshot(try await repository.loadHome())
            sessionState.statusMessage = nil
            syncFromCatalogState()
            syncFromSessionState()
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "load_catalog", phase: .catalog)
            handleSessionError(error)
        } catch {
            diagnostics.record(operation: "load_catalog", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromSessionState()
        }
    }

    func runSearch() async {
        copyToCatalogState()
        guard let search = catalogState.beginSearch() else {
            syncFromCatalogState()
            return
        }
        guard let url = normalizeServerURL(serverURLString) else {
            _ = catalogState.failSearch(loadID: search.loadID)
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            syncFromCatalogState()
            return
        }
        syncFromCatalogState()

        do {
            let token = try sessionState.token()
            let repository = catalogRepository(for: url, token: token)
            let results = try await repository.search(query: search.query)
            guard catalogState.completeSearch(loadID: search.loadID, results: results) else { return }
            sessionState.statusMessage = catalogState.searchResults.isEmpty ? L10n.text("No catalog results found.") : nil
            syncFromCatalogState()
            syncFromSessionState()
        } catch let error as LuminaClientError {
            guard catalogState.failSearch(loadID: search.loadID) else { return }
            diagnostics.record(error: error, operation: "catalog_search", phase: .catalog)
            syncFromCatalogState()
            handleSessionError(error)
        } catch {
            guard catalogState.failSearch(loadID: search.loadID) else { return }
            diagnostics.record(operation: "catalog_search", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromCatalogState()
            syncFromSessionState()
        }
    }

    func openCatalogDetail(_ item: CatalogItem) async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            return
        }
        let loadID = catalogState.beginDetail(item)
        syncFromCatalogState()

        do {
            let token = try sessionState.token()
            let repository = catalogRepository(for: url, token: token)
            if item.mediaType == "tv_show" {
                let snapshot = try await repository.tvShowDetail(showId: item.id)
                guard catalogState.applyTVShowDetail(loadID: loadID, snapshot: snapshot) else { return }
            } else if item.mediaType == "movie" {
                let detail = try await repository.movieDetail(movieId: item.id)
                guard catalogState.applyMovieDetail(loadID: loadID, item: detail) else { return }
            }
            sessionState.statusMessage = nil
            syncFromCatalogState()
            syncFromSessionState()
        } catch let error as LuminaClientError {
            guard catalogState.failDetail(loadID: loadID) else { return }
            diagnostics.record(error: error, operation: "catalog_detail", phase: .catalog)
            syncFromCatalogState()
            handleSessionError(error)
        } catch {
            guard catalogState.failDetail(loadID: loadID) else { return }
            diagnostics.record(operation: "catalog_detail", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromCatalogState()
            syncFromSessionState()
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
        catalogState.beginSeason(season)
        syncFromCatalogState()

        do {
            let token = try sessionState.token()
            let repository = catalogRepository(for: url, token: token)
            let episodes = try await repository.episodes(showId: show.id, seasonNumber: season.seasonNumber)
            catalogState.completeSeason(episodes: episodes)
            sessionState.statusMessage = episodes.isEmpty ? L10n.text("No episodes found for this season.") : nil
            syncFromCatalogState()
            syncFromSessionState()
        } catch let error as LuminaClientError {
            catalogState.failSeason()
            diagnostics.record(error: error, operation: "catalog_tv_episodes", phase: .catalog)
            syncFromCatalogState()
            handleSessionError(error)
        } catch {
            catalogState.failSeason()
            diagnostics.record(operation: "catalog_tv_episodes", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromCatalogState()
            syncFromSessionState()
        }
    }

    func closeCatalogDetail() {
        catalogState.closeDetail()
        syncFromCatalogState()
    }

    func openHomeTab(_ tab: HomeTab) {
        selectedHomeTab = tab
        catalogState.closeDetail()
        catalogState.closeEditorial()
        syncFromCatalogState()
    }

    func openEditorialSection(_ section: CatalogSection) async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            return
        }
        let loadID = catalogState.beginEditorial(section)
        syncFromCatalogState()

        do {
            let token = try sessionState.token()
            let repository = catalogRepository(for: url, token: token)
            let editorialSection = try await repository.editorialSection(sectionId: section.id)
            guard catalogState.completeEditorial(loadID: loadID, section: editorialSection) else { return }
            sessionState.statusMessage = nil
            syncFromCatalogState()
            syncFromSessionState()
        } catch let error as LuminaClientError {
            guard catalogState.failEditorial(loadID: loadID) else { return }
            diagnostics.record(error: error, operation: "catalog_editorial", phase: .catalog)
            syncFromCatalogState()
            handleSessionError(error)
        } catch {
            guard catalogState.failEditorial(loadID: loadID) else { return }
            diagnostics.record(operation: "catalog_editorial", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromCatalogState()
            syncFromSessionState()
        }
    }

    func closeEditorialSection() {
        catalogState.closeEditorial()
        syncFromCatalogState()
    }

    func playCatalogMovie(_ item: CatalogItem) async {
        guard item.mediaType == "movie" || item.mediaType == "episode" else {
            statusMessage = L10n.text("This title is not playable on Apple TV yet.")
            return
        }
        await loadPlaybackProof(movieOverride: item.playableMovie)
    }

    func canToggleWatchlist(for item: CatalogItem) -> Bool {
        capabilities?.library.watchlist == true && supportsLibraryMembership(item)
    }

    func canToggleFavorite(for item: CatalogItem) -> Bool {
        capabilities?.library.favorites == true && supportsLibraryMembership(item)
    }

    func toggleWatchlist(_ item: CatalogItem) async {
        await setLibraryMembership(
            item,
            operation: "catalog_watchlist",
            unsupportedMessage: L10n.text("Watchlist is not available for this title."),
            action: { client, token, item in
                try await client.setWatchlisted(
                    mediaType: item.mediaType,
                    mediaId: item.id,
                    isWatchlisted: item.isWatchlisted != true,
                    token: token
                )
            }
        )
    }

    func toggleFavorite(_ item: CatalogItem) async {
        await setLibraryMembership(
            item,
            operation: "catalog_favorite",
            unsupportedMessage: L10n.text("Favorites are not available for this title."),
            action: { client, token, item in
                try await client.setFavorite(
                    mediaType: item.mediaType,
                    mediaId: item.id,
                    isFavorite: item.isFavorite != true,
                    token: token
                )
            }
        )
    }

    func openTrailer(_ item: CatalogItem) {
        statusMessage = L10n.text("Trailer playback is not wired yet.")
        diagnostics.record(operation: "catalog_trailer", message: "Trailer selected for \(item.mediaType) \(item.id)")
    }

    func openCatalogLink(_ item: CatalogItem) {
        statusMessage = L10n.browsingNotReady(item.title)
        diagnostics.record(operation: "catalog_link", message: "Catalog link selected: \(item.id)")
    }

    func openPersonDetails(_ person: CatalogPersonCredit) {
        statusMessage = L10n.personDetailsNotReady(person.name)
        diagnostics.record(operation: "catalog_person", message: "Person selected: \(person.id)")
    }

    private func supportsLibraryMembership(_ item: CatalogItem) -> Bool {
        item.mediaType == "movie" || item.mediaType == "tv_show"
    }

    private func setLibraryMembership(
        _ item: CatalogItem,
        operation: String,
        unsupportedMessage: String,
        action: (LuminaAPIClient, String, CatalogItem) async throws -> Void
    ) async {
        guard supportsLibraryMembership(item) else {
            statusMessage = unsupportedMessage
            sessionState.statusMessage = statusMessage
            syncFromSessionState()
            return
        }
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            sessionState.statusMessage = statusMessage
            syncFromSessionState()
            return
        }

        do {
            let token = try sessionState.token()
            try await action(apiClient(for: url), token, item)
            sessionState.statusMessage = nil
            syncFromSessionState()
            await openCatalogDetail(item)
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: operation, phase: .catalog)
            handleSessionError(error)
        } catch {
            diagnostics.record(operation: operation, message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromSessionState()
        }
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
        let loadID = playbackState.beginLoad()
        phase = .loadingPlayback
        var result: PlaybackProofLoadResult?
        var playbackToken: String?
        var playbackClient: LuminaAPIClient?
        do {
            let token = try sessionState.token()
            playbackToken = token
            let client = apiClient(for: url)
            playbackClient = client
            result = try await playbackState.loadMovieProof(
                movieOverride: movieOverride,
                token: token,
                client: client
            )
            guard playbackState.isCurrentLoad(loadID) else {
                await stopPlaybackSessionIfNeeded(
                    result?.session,
                    client: client,
                    token: token,
                    positionSeconds: result?.resumePositionSeconds ?? 0
                )
                return
            }
            guard let result else { return }
            guard playbackState.applyLoadedProof(result, loadID: loadID) else { return }
            syncFromPlaybackState()
            if let playbackProof {
                phase = .playback(playbackProof)
            }
            sessionState.statusMessage = nil
            syncFromSessionState()
        } catch let error as LuminaClientError {
            if let playbackClient, let playbackToken {
                await stopPlaybackSessionIfNeeded(
                    result?.session,
                    client: playbackClient,
                    token: playbackToken,
                    positionSeconds: result?.resumePositionSeconds ?? 0
                )
            }
            guard playbackState.isCurrentLoad(loadID) else { return }
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
            guard playbackState.isCurrentLoad(loadID) else { return }
            diagnostics.record(operation: "load_playback_proof", message: "\(error)")
            sessionState.statusMessage = LuminaClientError.fromTransport(error).safeMessage
            syncFromSessionState()
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

    @discardableResult
    func reportPlaybackProgress(positionSeconds: Double, event: String) async -> Bool {
        guard let proof = playbackProof, let url = normalizeServerURL(serverURLString) else {
            return true
        }
        do {
            let token = try sessionState.token()
            let client = apiClient(for: url)
            try await client.reportProgress(
                ProgressUpdateRequest(
                    mediaId: proof.movie.id,
                    mediaType: proof.movie.playbackMediaType,
                    showId: proof.movie.showId,
                    seasonNumber: proof.movie.seasonNumber,
                    episodeNumber: proof.movie.episodeNumber,
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
            return true
        } catch let error as LuminaClientError {
            diagnostics.record(error: error, operation: "playback_progress", phase: .playback)
            if error == .sessionExpired || error == .missingToken {
                sessionState.signOut(message: nil)
                syncFromSessionState()
                return false
            }
            return true
        } catch {
            diagnostics.record(operation: "playback_progress", message: "\(error)")
            return true
        }
    }

    func requestPlaybackExit() {
        phase = .home
    }

    func finishPlayback(positionSeconds: Double, event: String) async {
        let sessionIsValid = await reportPlaybackProgress(positionSeconds: positionSeconds, event: event)
        playbackState.exit()
        syncFromPlaybackState()
        phase = sessionIsValid ? .home : .signIn
    }

    func exitPlayback() {
        playbackState.exit()
        syncFromPlaybackState()
        phase = .home
    }

    func recordPlaybackFailure(_ message: String) {
        sessionState.statusMessage = playbackState.recordFailure(message)
        syncFromSessionState()
    }

    func recordPlaybackMediaOptions(
        audioCount: Int,
        subtitleCount: Int,
        backendTracks: MediaTrackListing?,
        manifestInspection: HLSManifestInspection?
    ) {
        playbackState.recordMediaOptions(
            audioCount: audioCount,
            subtitleCount: subtitleCount,
            backendTracks: backendTracks,
            manifestInspection: manifestInspection
        )
    }

    func recordPlaybackMediaOptionsUnavailable(_ message: String) {
        playbackState.recordMediaOptionsUnavailable(message)
    }

    func artworkURL(for path: String?, kind: CatalogArtworkKind) -> URL? {
        guard let serverURL = normalizeServerURL(serverURLString) else { return nil }
        return ArtworkURLResolver(serverURL: serverURL).url(for: path, kind: kind)
    }

    func resetServer() {
        playbackState.reset()
        catalogState.reset()
        sessionState.resetServer()
        syncFromPlaybackState()
        syncFromCatalogState()
        syncFromSessionState()
        phase = .setup
    }

    func normalizeServerURL(_ value: String) -> URL? {
        ServerURLNormalizer.normalize(value)
    }

    private func apiClient(for url: URL) -> LuminaAPIClient {
        apiClientFactory(url, capabilities)
    }

    private func catalogRepository(for url: URL, token: String) -> CatalogRepository {
        CatalogRepository(client: apiClient(for: url), token: token)
    }

    private func copyToSessionState() {
        sessionState.serverURLString = serverURLString
        sessionState.email = email
        sessionState.password = password
        sessionState.statusMessage = statusMessage
        sessionState.capabilities = capabilities
        sessionState.currentUser = currentUser
    }

    private func syncFromSessionState() {
        serverURLString = sessionState.serverURLString
        email = sessionState.email
        password = sessionState.password
        statusMessage = sessionState.statusMessage
        capabilities = sessionState.capabilities
        currentUser = sessionState.currentUser
    }

    private func copyToCatalogState() {
        catalogState.homeHeroItems = homeHeroItems
        catalogState.homeSections = homeSections
        catalogState.movies = movies
        catalogState.tvShows = tvShows
        catalogState.searchQuery = searchQuery
        catalogState.searchResults = searchResults
        catalogState.isCatalogLoading = isCatalogLoading
        catalogState.selectedCatalogItem = selectedCatalogItem
        catalogState.selectedTVSeasons = selectedTVSeasons
        catalogState.selectedTVEpisodes = selectedTVEpisodes
        catalogState.selectedSeasonNumber = selectedSeasonNumber
        catalogState.selectedEditorialSection = selectedEditorialSection
        catalogState.isDetailLoading = isDetailLoading
        catalogState.isEditorialLoading = isEditorialLoading
    }

    private func syncFromCatalogState() {
        homeHeroItems = catalogState.homeHeroItems
        homeSections = catalogState.homeSections
        movies = catalogState.movies
        tvShows = catalogState.tvShows
        searchQuery = catalogState.searchQuery
        searchResults = catalogState.searchResults
        isCatalogLoading = catalogState.isCatalogLoading
        selectedCatalogItem = catalogState.selectedCatalogItem
        selectedTVSeasons = catalogState.selectedTVSeasons
        selectedTVEpisodes = catalogState.selectedTVEpisodes
        selectedSeasonNumber = catalogState.selectedSeasonNumber
        selectedEditorialSection = catalogState.selectedEditorialSection
        isDetailLoading = catalogState.isDetailLoading
        isEditorialLoading = catalogState.isEditorialLoading
    }

    private func syncFromPlaybackState() {
        playbackProof = playbackState.playbackProof
    }

    private func handleSessionError(_ error: LuminaClientError, fallbackPhase: AppPhase = .home) {
        if error == .sessionExpired || error == .missingToken {
            sessionState.signOut(message: error.safeMessage)
            playbackState.reset()
            catalogState.reset()
            syncFromSessionState()
            syncFromPlaybackState()
            syncFromCatalogState()
            phase = .signIn
            return
        }
        sessionState.statusMessage = error.safeMessage
        syncFromSessionState()
        phase = fallbackPhase
    }
}

#if DEBUG
extension AppModel {
    static func uiTestingModel(tab: HomeTab = .home, showsDetail: Bool = false, signedIn: Bool = true) -> AppModel {
        let model = AppModel()
        let capabilities = ServerCapabilities(
            server: .init(name: "Lumina", version: "UI Test"),
            api: .init(version: "2026-05-tv", minimumTvClientVersion: "1.0"),
            auth: .init(modes: ["password_jwt"], sessionValidationRoute: "/api/v1/auth/me"),
            playback: .init(
                hls: .init(movies: true, episodes: true),
                streamTokens: .init(requiredForProtectedStreams: true, transport: "query"),
                progress: .init(supported: true, recommendedIntervalSeconds: 15, events: ["playing", "paused", "stopped"]),
                sessions: .init(supported: true, route: "/api/v1/playback/sessions")
            ),
            library: .init(
                home: true,
                search: true,
                movieBrowse: true,
                tvBrowse: true,
                movieDetails: true,
                tvDetails: true,
                watchlist: false,
                favorites: false,
                artworkKinds: ["poster", "backdrop"]
            ),
            diagnostics: .init(correlationIds: true, playbackSessionCorrelation: true, clientEventUpload: false),
            routes: [
                "catalogHome": "/api/v1/catalog/home",
                "movieHlsManifest": "/api/v1/movies/{id}/hls/master.m3u8",
                "movieProgressUpdate": "/api/v1/movies/{id}/progress"
            ],
            limits: .init(defaultPageSize: 24, maximumPageSize: 100, maximumArtworkWidth: 1280)
        )
        let movie = CatalogItem(
            id: "ui-movie",
            mediaType: "movie",
            title: "UI Test Movie",
            subtitle: "2026",
            overview: "A safe fixture used by tvOS smoke tests.",
            progressPercent: 42,
            hasPlayableMedia: true,
            year: 2026,
            runtimeMinutes: 92,
            genres: ["Drama"],
            cast: [
                CatalogPersonCredit(id: "ui-person-1", name: "Alex Rivera", role: "Pilot", creditType: "cast")
            ],
            crew: [
                CatalogPersonCredit(id: "ui-person-2", name: "Sam Chen", role: "Director", department: "Directing", creditType: "crew")
            ]
        )

        model.phase = .home
        model.serverURLString = "https://lumina.example.test"
        model.capabilities = capabilities
        model.currentUser = LuminaUser(id: "ui-user", displayName: "UI Tester")
        model.automaticCatalogRefreshEnabled = false
        model.homeHeroItems = [movie]
        model.homeSections = [
            CatalogSection(id: "continue", title: "Continue Watching", type: "continue_watching", items: [movie]),
            CatalogSection(id: "recent", title: "Recently Added", type: "poster", items: [movie])
        ]
        model.movies = [movie]
        model.tvShows = [CatalogItem(id: "ui-show", mediaType: "tv_show", title: "UI Test Show", subtitle: "1 season")]
        model.searchQuery = tab == .search ? "movie" : ""
        model.searchResults = [movie]
        model.selectedHomeTab = tab
        model.selectedCatalogItem = showsDetail ? movie : nil
        model.statusMessage = nil

        if !signedIn {
            model.phase = .signIn
        }

        return model
    }
}
#endif
