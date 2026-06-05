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
    @Published var username: String = ""
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
    @Published var isDetailLoading = false

    private let tokenStore: TokenStore
    private let settingsStore: ServerSettingsStore
    private let diagnostics: DiagnosticsRecorder
    private let apiClientFactory: (URL) -> LuminaAPIClient

    init(
        tokenStore: TokenStore = KeychainTokenStore(),
        settingsStore: ServerSettingsStore = UserDefaultsServerSettingsStore(),
        diagnostics: DiagnosticsRecorder = DiagnosticsRecorder(),
        apiClientFactory: @escaping (URL) -> LuminaAPIClient = { URLSessionLuminaAPIClient(baseURL: $0) }
    ) {
        self.tokenStore = tokenStore
        self.settingsStore = settingsStore
        self.diagnostics = diagnostics
        self.apiClientFactory = apiClientFactory
        self.serverURLString = settingsStore.serverURLString ?? ""
        self.phase = .setup
    }

    func restoreSession() async {
        guard phase == .restoring || phase == .setup else {
            return
        }
        guard let storedServer = settingsStore.serverURLString, let url = normalizeServerURL(storedServer) else {
            phase = .setup
            return
        }
        serverURLString = storedServer
        do {
            guard let token = try tokenStore.loadToken() else {
                phase = .signIn
                return
            }
            let client = apiClientFactory(url)
            currentUser = try await client.currentUser(token: token)
            phase = .home
            statusMessage = nil
            await loadCatalog()
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
            let client = apiClientFactory(url)
            let capabilities = try await client.fetchCapabilities()
            self.capabilities = capabilities
            guard capabilities.isTvMVPCompatible else {
                throw LuminaClientError.unsupportedServer
            }
            settingsStore.serverURLString = url.absoluteString
            serverURLString = url.absoluteString
            statusMessage = nil
            phase = .signIn
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "validate_server", message: error.safeMessage)
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
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            statusMessage = "Enter your Lumina username and password."
            phase = .signIn
            return
        }

        phase = .signingIn
        do {
            let client = apiClientFactory(url)
            let response = try await client.login(username: username, password: password)
            try tokenStore.saveToken(response.accessToken)
            if let user = response.user {
                currentUser = user
            } else {
                currentUser = try await client.currentUser(token: response.accessToken)
            }
            password = ""
            statusMessage = nil
            phase = .home
            await loadCatalog()
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "sign_in", message: error.safeMessage)
            statusMessage = error.safeMessage
            phase = .signIn
        } catch {
            diagnostics.record(operation: "sign_in", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
            phase = .signIn
        }
    }

    func signOut() {
        do {
            try tokenStore.clearToken()
        } catch {
            diagnostics.record(operation: "sign_out", message: "\(error)")
        }
        currentUser = nil
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
            guard let token = try tokenStore.loadToken() else {
                throw LuminaClientError.missingToken
            }
            let client = apiClientFactory(url)
            async let home = client.fetchCatalogHome(token: token)
            async let movieRows = client.fetchMovies(token: token)
            async let tvRows = client.fetchTVShows(token: token)
            let (homeResponse, fetchedMovies, fetchedTVShows) = try await (home, movieRows, tvRows)
            homeHeroItems = homeResponse.hero?.items ?? homeResponse.sections.first?.items ?? []
            homeSections = homeResponse.sections
            movies = fetchedMovies
            tvShows = fetchedTVShows
            statusMessage = nil
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "load_catalog", message: error.safeMessage)
            statusMessage = error.safeMessage
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
        isCatalogLoading = true
        defer { isCatalogLoading = false }

        do {
            guard let token = try tokenStore.loadToken() else {
                throw LuminaClientError.missingToken
            }
            let client = apiClientFactory(url)
            searchResults = try await client.searchCatalog(query: query, token: token)
            statusMessage = searchResults.isEmpty ? "No catalog results found." : nil
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "catalog_search", message: error.safeMessage)
            statusMessage = error.safeMessage
        } catch {
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
        selectedCatalogItem = item
        selectedTVSeasons = []
        selectedTVEpisodes = []
        selectedSeasonNumber = nil
        defer { isDetailLoading = false }

        do {
            guard let token = try tokenStore.loadToken() else {
                throw LuminaClientError.missingToken
            }
            let client = apiClientFactory(url)
            if item.mediaType == "tv_show" {
                async let detail = client.fetchTVShowDetail(showId: item.id, token: token)
                async let seasons = client.fetchTVSeasons(showId: item.id, token: token)
                let (showDetail, fetchedSeasons) = try await (detail, seasons)
                selectedCatalogItem = showDetail
                selectedTVSeasons = fetchedSeasons
                if let firstSeason = fetchedSeasons.first {
                    await selectTVSeason(firstSeason)
                }
            } else if item.mediaType == "movie" {
                selectedCatalogItem = try await client.fetchMovieDetail(movieId: item.id, token: token)
            }
            statusMessage = nil
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "catalog_detail", message: error.safeMessage)
            statusMessage = error.safeMessage
        } catch {
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
            guard let token = try tokenStore.loadToken() else {
                throw LuminaClientError.missingToken
            }
            let client = apiClientFactory(url)
            selectedTVEpisodes = try await client.fetchTVEpisodes(
                showId: show.id,
                seasonNumber: season.seasonNumber,
                token: token
            )
            statusMessage = selectedTVEpisodes.isEmpty ? "No episodes found for this season." : nil
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "catalog_tv_episodes", message: error.safeMessage)
            statusMessage = error.safeMessage
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

    func loadPlaybackProof() async {
        await loadPlaybackProof(movieOverride: nil)
    }

    private func loadPlaybackProof(movieOverride: PlayableMovie?) async {
        guard let url = normalizeServerURL(serverURLString) else {
            statusMessage = LuminaClientError.invalidServerURL.safeMessage
            phase = .setup
            return
        }
        phase = .loadingPlayback
        do {
            guard let token = try tokenStore.loadToken() else {
                throw LuminaClientError.missingToken
            }
            let client = apiClientFactory(url)
            let movie: PlayableMovie
            if let movieOverride {
                movie = movieOverride
            } else {
                movie = try await client.fetchPlayableMovie(token: token)
            }
            let progress = try? await client.fetchMovieProgress(movieId: movie.id, token: token)
            let resumePosition = progress?.positionSeconds ?? movie.resumePositionSeconds ?? 0
            let session = try? await client.createPlaybackSession(mediaId: movie.id, positionSeconds: resumePosition, token: token)
            let streamToken = try await client.requestStreamToken(mediaType: "movie", mediaId: movie.id, token: token)
            let streamURL = client.movieHLSManifestURL(
                movie: movie,
                streamToken: streamToken,
                sessionId: session?.id,
                startTime: resumePosition,
                quality: "720p"
            )
            try await client.preflightHLSManifest(url: streamURL)
            let proof = PlaybackProof(
                movie: PlayableMovie(
                    id: movie.id,
                    title: movie.title,
                    overview: movie.overview,
                    resumePositionSeconds: resumePosition,
                    durationSeconds: progress?.durationSeconds ?? movie.durationSeconds,
                    hlsManifestPath: movie.hlsManifestPath,
                    hasPlayableMedia: movie.hasPlayableMedia
                ),
                streamURL: streamURL,
                authorizationHeader: nil,
                sessionId: session?.id
            )
            playbackProof = proof
            phase = .playback(proof)
            statusMessage = nil
        } catch let error as LuminaClientError {
            diagnostics.record(operation: "load_playback_proof", message: error.safeMessage)
            statusMessage = error.safeMessage
            phase = .home
        } catch {
            diagnostics.record(operation: "load_playback_proof", message: "\(error)")
            statusMessage = LuminaClientError.fromTransport(error).safeMessage
            phase = .home
        }
    }

    func reportPlaybackProgress(positionSeconds: Double, event: String) async {
        guard let proof = playbackProof, let url = normalizeServerURL(serverURLString) else {
            return
        }
        do {
            guard let token = try tokenStore.loadToken() else {
                throw LuminaClientError.missingToken
            }
            let client = apiClientFactory(url)
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
        } catch {
            diagnostics.record(operation: "playback_progress", message: "\(error)")
        }
    }

    func exitPlayback() {
        phase = .home
    }

    func recordPlaybackFailure(_ message: String) {
        diagnostics.record(operation: "avkit_playback", message: message)
        statusMessage = DiagnosticsRecorder.redact(message)
    }

    func artworkURL(for path: String?, kind: CatalogArtworkKind) -> URL? {
        guard let path, !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)

        if let absoluteURL = URL(string: trimmedPath), absoluteURL.scheme != nil {
            return absoluteURL
        }

        if trimmedPath.hasPrefix("/api/") || trimmedPath.hasPrefix("/assets/") || trimmedPath.hasPrefix("/artwork/") {
            guard let serverURL = normalizeServerURL(serverURLString) else { return nil }
            return URL(string: trimmedPath, relativeTo: serverURL)?.absoluteURL
        }

        if trimmedPath.hasPrefix("/") {
            return URL(string: "https://image.tmdb.org/t/p/\(kind.tmdbWidthPath)\(trimmedPath)")
        }

        guard let serverURL = normalizeServerURL(serverURLString) else { return nil }
        return URL(string: trimmedPath, relativeTo: serverURL)?.absoluteURL
    }

    func resetServer() {
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
        username = ""
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
}
