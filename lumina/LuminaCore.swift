//
//  LuminaCore.swift
//  lumina
//
//  Created by Codex on 2026-05-30.
//

import Foundation
import Security

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

struct LuminaUser: Decodable, Equatable, Identifiable {
    let id: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case username
        case email
        case firstname
        case lastname
    }

    init(id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .id))
        }

        if let displayName = try container.decodeIfPresent(String.self, forKey: .displayName), !displayName.isEmpty {
            self.displayName = displayName
            return
        }

        let firstname = try container.decodeIfPresent(String.self, forKey: .firstname)
        let lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
        let fullName = [firstname, lastname]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !fullName.isEmpty {
            displayName = fullName
            return
        }

        displayName = try container.decodeIfPresent(String.self, forKey: .username)
            ?? container.decodeIfPresent(String.self, forKey: .email)
            ?? "Lumina user"
    }
}

struct ServerCapabilities: Codable, Equatable {
    struct Server: Codable, Equatable {
        let name: String
        let version: String
    }

    struct API: Codable, Equatable {
        let version: String
        let minimumTvClientVersion: String
    }

    struct Auth: Codable, Equatable {
        let modes: [String]
        let sessionValidationRoute: String
    }

    struct Playback: Codable, Equatable {
        struct HLS: Codable, Equatable {
            let movies: Bool
            let episodes: Bool
        }

        struct StreamTokens: Codable, Equatable {
            let requiredForProtectedStreams: Bool
            let transport: String
        }

        struct Progress: Codable, Equatable {
            let supported: Bool
            let recommendedIntervalSeconds: Int
            let events: [String]
        }

        struct Sessions: Codable, Equatable {
            let supported: Bool
            let route: String?
        }

        let hls: HLS
        let streamTokens: StreamTokens
        let progress: Progress
        let sessions: Sessions
    }

    struct Library: Codable, Equatable {
        let home: Bool
        let search: Bool
        let movieBrowse: Bool
        let tvBrowse: Bool
        let movieDetails: Bool
        let tvDetails: Bool
        let watchlist: Bool
        let favorites: Bool
        let artworkKinds: [String]
    }

    struct Diagnostics: Codable, Equatable {
        let correlationIds: Bool
        let playbackSessionCorrelation: Bool
        let clientEventUpload: Bool
    }

    struct Limits: Codable, Equatable {
        let defaultPageSize: Int
        let maximumPageSize: Int
        let maximumArtworkWidth: Int
    }

    let server: Server
    let api: API
    let auth: Auth
    let playback: Playback
    let library: Library
    let diagnostics: Diagnostics
    let routes: [String: String]
    let limits: Limits

    var isTvMVPCompatible: Bool {
        auth.modes.contains("password_jwt")
        && !auth.sessionValidationRoute.isEmpty
        && playback.hls.movies
        && playback.progress.supported
        && routes["catalogHome"] != nil
        && routes["movieHlsManifest"] != nil
        && (routes["movieProgressUpdate"] != nil || routes["progressUpdate"] != nil)
    }
}

struct LuminaErrorEnvelope: Codable, Equatable {
    struct Body: Codable, Equatable {
        let code: String
        let category: String
        let safeMessage: String
        let retryable: Bool
        let correlationId: String?
        let details: [String: String]?
    }

    let error: Body
}

enum LuminaClientError: Error, Equatable {
    case invalidServerURL
    case unsupportedServer
    case server(LuminaErrorEnvelope.Body)
    case transport(String)
    case decoding
    case routeNotFound(String)
    case missingToken

    var safeMessage: String {
        switch self {
        case .invalidServerURL:
            return "Enter a valid Lumina server URL."
        case .unsupportedServer:
            return "This Lumina server does not support Apple TV playback yet."
        case .server(let body):
            return body.safeMessage
        case .transport(let message):
            return message.isEmpty ? "The server could not be reached. Check the address and try again." : message
        case .decoding:
            return "The server response was not compatible with this Apple TV app."
        case .routeNotFound(let path):
            if path == "/api/v1/system/capabilities" {
                return "Server reached, but Lumina capabilities are missing. Add GET /api/v1/system/capabilities to the server."
            }
            if path.contains("login") {
                return "Server reached, but the login route was not found. The app tried \(path)."
            }
            if path.contains("me") {
                return "Server reached, but the session route was not found. The app tried \(path)."
            }
            return "Server reached, but the required API route was not found."
        case .missingToken:
            return "Sign in again to continue."
        }
    }

    static func fromTransport(_ error: Error) -> LuminaClientError {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
            return .transport("Plain HTTP is blocked by App Transport Security. Allow local networking in the app or use HTTPS.")
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorNotConnectedToInternet {
            return .transport("Apple TV is not connected to the network.")
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCannotConnectToHost {
            return .transport("The Lumina server refused the connection.")
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorTimedOut {
            return .transport("The Lumina server did not respond in time.")
        }
        return .transport(error.localizedDescription)
    }

    static func fromHTTPStatus(_ statusCode: Int, path: String) -> LuminaClientError {
        if statusCode == 404 {
            return .routeNotFound(path)
        }
        return .transport("Server returned HTTP \(statusCode).")
    }
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable, Equatable {
    let accessToken: String
    let user: LuminaUser?

    enum CodingKeys: String, CodingKey {
        case accessToken
        case token
        case user
    }

    init(accessToken: String, user: LuminaUser?) {
        self.accessToken = accessToken
        self.user = user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
            ?? container.decode(String.self, forKey: .token)
        user = try container.decodeIfPresent(LuminaUser.self, forKey: .user)
    }
}

struct BackendErrorResponse: Decodable, Equatable {
    let error: String
    let message: String
}

struct PlayableMovie: Decodable, Equatable, Identifiable {
    let id: String
    let title: String
    let overview: String?
    let resumePositionSeconds: Double?
    let durationSeconds: Double?
    let hlsManifestPath: String?
    let hasPlayableMedia: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case resumePositionSeconds
        case resume_position_seconds
        case durationSeconds
        case duration_seconds
        case hlsManifestPath
        case hls_manifest_path
        case hasPlayableMedia
        case has_playable_media
        case playback_readiness
        case progress
    }

    enum ProgressKeys: String, CodingKey {
        case positionSeconds = "position_seconds"
        case resumePositionSeconds = "resume_position_seconds"
    }

    enum PlaybackReadinessKeys: String, CodingKey {
        case hasPlayableMedia = "has_playable_media"
    }

    init(
        id: String,
        title: String,
        overview: String? = nil,
        resumePositionSeconds: Double? = nil,
        durationSeconds: Double? = nil,
        hlsManifestPath: String? = nil,
        hasPlayableMedia: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.resumePositionSeconds = resumePositionSeconds
        self.durationSeconds = durationSeconds
        self.hlsManifestPath = hlsManifestPath
        self.hasPlayableMedia = hasPlayableMedia
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .id))
        }
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? "Untitled movie"
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        durationSeconds = try container.decodeIfPresent(Double.self, forKey: .durationSeconds)
            ?? container.decodeIfPresent(Double.self, forKey: .duration_seconds)
        hlsManifestPath = try container.decodeIfPresent(String.self, forKey: .hlsManifestPath)
            ?? container.decodeIfPresent(String.self, forKey: .hls_manifest_path)
        if let hasPlayableMedia = try container.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia)
            ?? container.decodeIfPresent(Bool.self, forKey: .has_playable_media) {
            self.hasPlayableMedia = hasPlayableMedia
        } else if let readiness = try? container.nestedContainer(keyedBy: PlaybackReadinessKeys.self, forKey: .playback_readiness) {
            hasPlayableMedia = try readiness.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia)
        } else {
            hasPlayableMedia = nil
        }

        if let resume = try container.decodeIfPresent(Double.self, forKey: .resumePositionSeconds)
            ?? container.decodeIfPresent(Double.self, forKey: .resume_position_seconds) {
            resumePositionSeconds = resume
        } else if let progress = try? container.nestedContainer(keyedBy: ProgressKeys.self, forKey: .progress) {
            resumePositionSeconds = try progress.decodeIfPresent(Double.self, forKey: .resumePositionSeconds)
                ?? progress.decodeIfPresent(Double.self, forKey: .positionSeconds)
        } else {
            resumePositionSeconds = nil
        }
    }
}

struct MovieListResponse: Decodable, Equatable {
    let items: [PlayableMovie]

    enum CodingKeys: String, CodingKey {
        case items
        case data
        case results
        case movies
    }

    init(items: [PlayableMovie]) {
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([PlayableMovie].self, forKey: .items)
            ?? container.decodeIfPresent([PlayableMovie].self, forKey: .data)
            ?? container.decodeIfPresent([PlayableMovie].self, forKey: .results)
            ?? container.decodeIfPresent([PlayableMovie].self, forKey: .movies)
            ?? []
    }
}

struct PlaybackSessionResponse: Decodable, Equatable {
    let id: String
    let mediaId: String
    let mediaKind: String

    enum CodingKeys: String, CodingKey {
        case session
        case id
        case sessionId
        case session_id
        case mediaId
        case media_id
        case mediaKind
        case media_type
    }

    init(id: String, mediaId: String, mediaKind: String) {
        self.id = id
        self.mediaId = mediaId
        self.mediaKind = mediaKind
    }

    init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = (try? outerContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .session)) ?? outerContainer
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else if let stringID = try? container.decode(String.self, forKey: .sessionId) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .session_id) {
            id = String(intID)
        } else {
            id = try container.decode(String.self, forKey: .session_id)
        }
        if let stringMediaID = try? container.decode(String.self, forKey: .mediaId) {
            mediaId = stringMediaID
        } else if let intMediaID = try? container.decode(Int.self, forKey: .media_id) {
            mediaId = String(intMediaID)
        } else {
            mediaId = try container.decodeIfPresent(String.self, forKey: .media_id) ?? ""
        }
        mediaKind = try container.decodeIfPresent(String.self, forKey: .mediaKind)
            ?? container.decodeIfPresent(String.self, forKey: .media_type)
            ?? "movie"
    }
}

struct PlaybackProof: Equatable {
    let movie: PlayableMovie
    let streamURL: URL
    let authorizationHeader: String?
    let sessionId: String?
}

struct ProgressUpdateRequest: Encodable {
    let mediaId: String
    let positionSeconds: Double
    let durationSeconds: Double?
    let playState: String

    enum CodingKeys: String, CodingKey {
        case positionSeconds = "position_seconds"
        case durationSeconds = "duration_seconds"
        case playState = "play_state"
    }
}

struct PlaybackSessionCreateRequest: Encodable {
    let mediaType: String
    let mediaId: String
    let positionSeconds: Double
    let playState: String
    let clientLabel: String

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case positionSeconds = "position_seconds"
        case playState = "play_state"
        case clientLabel = "client_label"
    }
}

struct PlaybackSessionUpdateRequest: Encodable {
    let positionSeconds: Double
    let playState: String
    let selectionDiagnostics: [String: String]?

    enum CodingKeys: String, CodingKey {
        case positionSeconds = "position_seconds"
        case playState = "play_state"
        case selectionDiagnostics = "selection_diagnostics"
    }
}

struct StreamTokenRequest: Encodable {
    let mediaType: String
    let mediaId: String

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
    }
}

struct StreamTokenResponse: Decodable, Equatable {
    let token: String?

    enum CodingKeys: String, CodingKey {
        case token
        case streamToken
        case stream_token
    }

    init(token: String?) {
        self.token = token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decodeIfPresent(String.self, forKey: .token)
            ?? container.decodeIfPresent(String.self, forKey: .streamToken)
            ?? container.decodeIfPresent(String.self, forKey: .stream_token)
    }
}

struct MovieProgressResponse: Decodable, Equatable {
    let positionSeconds: Double?
    let durationSeconds: Double?
    let playState: String?

    enum CodingKeys: String, CodingKey {
        case positionSeconds = "position_seconds"
        case durationSeconds = "duration_seconds"
        case playState = "play_state"
    }
}

struct CatalogItem: Decodable, Equatable, Identifiable {
    let id: String
    let mediaType: String
    let title: String
    let subtitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let logoPath: String?
    let progressPercent: Double
    let watchedState: String?
    let hasPlayableMedia: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case mediaId = "media_id"
        case mediaType = "media_type"
        case title
        case name
        case originalTitle = "original_title"
        case year
        case overview
        case description
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case backdropWithTextPath = "backdrop_with_text_path"
        case logoPath = "logo_path"
        case progress
        case progressPercent = "progress_percent"
        case watchedState = "watched_state"
        case playbackReadiness = "playback_readiness"
        case hasPlayableMedia = "has_playable_media"
        case show
        case seasonNumber = "season_number"
        case episodeNumber = "episode_number"
        case episodeTitle = "episode_title"
    }

    enum ProgressKeys: String, CodingKey {
        case progressPercent = "progress_percent"
    }

    enum PlaybackReadinessKeys: String, CodingKey {
        case hasPlayableMedia = "has_playable_media"
    }

    enum ShowKeys: String, CodingKey {
        case title
    }

    init(
        id: String,
        mediaType: String = "movie",
        title: String,
        subtitle: String? = nil,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        logoPath: String? = nil,
        progressPercent: Double = 0,
        watchedState: String? = nil,
        hasPlayableMedia: Bool? = nil
    ) {
        self.id = id
        self.mediaType = mediaType
        self.title = title
        self.subtitle = subtitle
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.logoPath = logoPath
        self.progressPercent = progressPercent
        self.watchedState = watchedState
        self.hasPlayableMedia = hasPlayableMedia
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else if let stringID = try? container.decode(String.self, forKey: .mediaId) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .mediaId))
        }

        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType) ?? "movie"
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? "Untitled"
        let year = try container.decodeIfPresent(Int.self, forKey: .year)
        let originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle)
        if let show = try? container.nestedContainer(keyedBy: ShowKeys.self, forKey: .show),
           let showTitle = try show.decodeIfPresent(String.self, forKey: .title) {
            let season = try container.decodeIfPresent(Int.self, forKey: .seasonNumber)
            let episode = try container.decodeIfPresent(Int.self, forKey: .episodeNumber)
            let episodeTitle = try container.decodeIfPresent(String.self, forKey: .episodeTitle)
            subtitle = [showTitle, season.map { "S\($0)" }, episode.map { "E\($0)" }, episodeTitle]
                .compactMap { $0 }
                .joined(separator: " ")
        } else if let year {
            subtitle = String(year)
        } else {
            subtitle = originalTitle
        }
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
            ?? container.decodeIfPresent(String.self, forKey: .description)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropWithTextPath)
            ?? container.decodeIfPresent(String.self, forKey: .backdropPath)
        logoPath = try container.decodeIfPresent(String.self, forKey: .logoPath)
        if let progress = try? container.nestedContainer(keyedBy: ProgressKeys.self, forKey: .progress) {
            progressPercent = try progress.decodeIfPresent(Double.self, forKey: .progressPercent) ?? 0
        } else {
            progressPercent = try container.decodeIfPresent(Double.self, forKey: .progressPercent) ?? 0
        }
        watchedState = try container.decodeIfPresent(String.self, forKey: .watchedState)
        if let direct = try container.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia) {
            hasPlayableMedia = direct
        } else if let readiness = try? container.nestedContainer(keyedBy: PlaybackReadinessKeys.self, forKey: .playbackReadiness) {
            hasPlayableMedia = try readiness.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia)
        } else {
            hasPlayableMedia = nil
        }
    }

    var playableMovie: PlayableMovie {
        PlayableMovie(id: id, title: title, overview: overview, hasPlayableMedia: hasPlayableMedia)
    }
}

struct CatalogSection: Decodable, Equatable, Identifiable {
    let id: String
    let title: String
    let mediaType: String?
    let items: [CatalogItem]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case mediaType = "media_type"
        case items
    }
}

struct CatalogHomeResponse: Decodable, Equatable {
    struct Hero: Decodable, Equatable {
        let items: [CatalogItem]
    }

    let hero: Hero?
    let sections: [CatalogSection]
}

struct CatalogListResponse: Decodable, Equatable {
    let results: [CatalogItem]

    enum CodingKeys: String, CodingKey {
        case results
        case items
        case data
    }

    init(results: [CatalogItem]) {
        self.results = results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decodeIfPresent([CatalogItem].self, forKey: .results)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .items)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .data)
            ?? []
    }
}

enum CatalogArtworkKind {
    case poster
    case backdrop
    case logo

    var tmdbWidthPath: String {
        switch self {
        case .poster:
            return "w500"
        case .backdrop:
            return "w1280"
        case .logo:
            return "w500"
        }
    }
}

protocol LuminaAPIClient {
    func fetchCapabilities() async throws -> ServerCapabilities
    func login(username: String, password: String) async throws -> LoginResponse
    func currentUser(token: String) async throws -> LuminaUser
    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse
    func fetchMovies(token: String) async throws -> [CatalogItem]
    func fetchTVShows(token: String) async throws -> [CatalogItem]
    func searchCatalog(query: String, token: String) async throws -> [CatalogItem]
    func fetchPlayableMovie(token: String) async throws -> PlayableMovie
    func fetchMovieProgress(movieId: String, token: String) async throws -> MovieProgressResponse
    func createPlaybackSession(mediaId: String, positionSeconds: Double, token: String) async throws -> PlaybackSessionResponse
    func requestStreamToken(mediaType: String, mediaId: String, token: String) async throws -> String?
    func movieHLSManifestURL(movie: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String) -> URL
    func preflightHLSManifest(url: URL) async throws
    func reportProgress(_ update: ProgressUpdateRequest, token: String) async throws
    func updatePlaybackSession(sessionId: String, positionSeconds: Double, playState: String, token: String) async throws
    func stopPlaybackSession(sessionId: String, positionSeconds: Double, token: String) async throws
}

struct URLSessionLuminaAPIClient: LuminaAPIClient {
    let baseURL: URL
    var session: URLSession = .shared
    var decoder = JSONDecoder()
    var encoder = JSONEncoder()

    func fetchCapabilities() async throws -> ServerCapabilities {
        try await send(path: "/api/v1/system/capabilities", method: "GET", token: nil, body: Optional<Data>.none)
    }

    func login(username: String, password: String) async throws -> LoginResponse {
        let body = try encoder.encode(LoginRequest(email: username, password: password))
        return try await send(path: "/api/v1/auth/login", method: "POST", token: nil, body: body)
    }

    func currentUser(token: String) async throws -> LuminaUser {
        try await send(path: "/api/v1/auth/me", method: "GET", token: token, body: Optional<Data>.none)
    }

    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse {
        try await send(
            path: "/api/v1/catalog/home",
            queryItems: [
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "hero_limit", value: "5"),
                URLQueryItem(name: "section_limit", value: "12"),
                URLQueryItem(name: "include_presentation", value: "true"),
                URLQueryItem(name: "include_badges", value: "true")
            ],
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
    }

    func fetchMovies(token: String) async throws -> [CatalogItem] {
        let response: CatalogListResponse = try await send(
            path: "/api/v1/catalog/movies",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(name: "order_by", value: "rating"),
                URLQueryItem(name: "sort_direction", value: "desc"),
                URLQueryItem(name: "watched_state", value: "any")
            ],
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.results
    }

    func fetchTVShows(token: String) async throws -> [CatalogItem] {
        let response: CatalogListResponse = try await send(
            path: "/api/v1/catalog/tv_shows",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(name: "order_by", value: "first_air_year"),
                URLQueryItem(name: "sort_direction", value: "desc"),
                URLQueryItem(name: "watched_state", value: "any")
            ],
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.results
    }

    func searchCatalog(query: String, token: String) async throws -> [CatalogItem] {
        let response: CatalogListResponse = try await send(
            path: "/api/v1/catalog/search",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(name: "order_by", value: "relevance"),
                URLQueryItem(name: "sort_direction", value: "desc")
            ],
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.results
    }

    func fetchPlayableMovie(token: String) async throws -> PlayableMovie {
        let response: MovieListResponse = try await send(
            path: "/api/v1/catalog/movies",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "20")
            ],
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        guard let movie = response.items.first(where: { $0.hasPlayableMedia != false }) else {
            throw LuminaClientError.server(
                LuminaErrorEnvelope.Body(
                    code: "NO_PLAYABLE_MOVIE",
                    category: "missing_media",
                    safeMessage: "No playable movie was found on this Lumina server.",
                    retryable: true,
                    correlationId: nil,
                    details: nil
                )
            )
        }
        return movie
    }

    func fetchMovieProgress(movieId: String, token: String) async throws -> MovieProgressResponse {
        try await send(path: route("/api/v1/playback/movies/:movieId/progress", movieId: movieId), method: "GET", token: token, body: Optional<Data>.none)
    }

    func createPlaybackSession(mediaId: String, positionSeconds: Double, token: String) async throws -> PlaybackSessionResponse {
        let body = try encoder.encode(
            PlaybackSessionCreateRequest(
                mediaType: "movie",
                mediaId: mediaId,
                positionSeconds: positionSeconds,
                playState: "playing",
                clientLabel: "Lumina tvOS"
            )
        )
        return try await send(path: "/api/v1/playback/sessions", method: "POST", token: token, body: body)
    }

    func requestStreamToken(mediaType: String, mediaId: String, token: String) async throws -> String? {
        let body = try encoder.encode(StreamTokenRequest(mediaType: mediaType, mediaId: mediaId))
        let response: StreamTokenResponse = try await send(path: "/api/v1/stream/token", method: "POST", token: token, body: body)
        return response.token
    }

    func movieHLSManifestURL(movie: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String = "720p") -> URL {
        let path = movie.hlsManifestPath ?? route("/api/v1/stream/movies/:movieId/hls/manifest.m3u8", movieId: movie.id)
        var queryItems = [
            URLQueryItem(name: "quality", value: quality),
            URLQueryItem(name: "t", value: String(Int(max(0, startTime))))
        ]
        if let streamToken {
            queryItems.append(URLQueryItem(name: "stream_token", value: streamToken))
        }
        if let sessionId {
            queryItems.append(URLQueryItem(name: "session_id", value: sessionId))
        }
        return makeURL(path: path, queryItems: queryItems)
    }

    func preflightHLSManifest(url: URL) async throws {
        do {
            let manifest = try await fetchHLSResource(url: url, label: "Manifest", byteRange: nil)
            guard manifest.text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#EXTM3U") else {
                throw LuminaClientError.transport("Manifest request succeeded, but the response was not an HLS manifest.")
            }
            guard let playlistURL = firstHLSResourceURL(in: manifest.text, relativeTo: manifest.url, matching: ".m3u8") else {
                return
            }

            let playlist = try await fetchHLSResource(url: playlistURL, label: "Playlist", byteRange: nil)
            guard playlist.text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#EXTM3U") else {
                throw LuminaClientError.transport("Playlist request succeeded, but the response was not an HLS playlist.")
            }
            guard let segmentURL = firstHLSResourceURL(in: playlist.text, relativeTo: playlist.url, matching: ".ts") else {
                return
            }
            _ = try await fetchHLSResource(url: segmentURL, label: "First segment", byteRange: "bytes=0-1")
        } catch let error as LuminaClientError {
            throw error
        } catch {
            throw LuminaClientError.fromTransport(error)
        }
    }

    private func fetchHLSResource(url: URL, label: String, byteRange: String?) async throws -> (url: URL, text: String) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/vnd.apple.mpegurl, application/x-mpegURL, video/MP2T, text/plain, */*", forHTTPHeaderField: "Accept")
        if let byteRange {
            request.setValue(byteRange, forHTTPHeaderField: "Range")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw LuminaClientError.transport("\(label) request did not return an HTTP response.")
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data.prefix(240), encoding: .utf8) ?? ""
            let detail = body.isEmpty ? "" : " \(DiagnosticsRecorder.redact(body))"
            throw LuminaClientError.transport("\(label) request returned HTTP \(http.statusCode).\(detail)")
        }

        return (http.url ?? url, String(data: data, encoding: .utf8) ?? "")
    }

    private func firstHLSResourceURL(in playlist: String, relativeTo baseURL: URL, matching suffix: String) -> URL? {
        playlist
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty && !$0.hasPrefix("#") && $0.contains(suffix) }
            .flatMap { URL(string: $0, relativeTo: baseURL)?.absoluteURL }
    }

    func reportProgress(_ update: ProgressUpdateRequest, token: String) async throws {
        let body = try encoder.encode(update)
        let _: EmptyResponse = try await send(path: route("/api/v1/playback/movies/:movieId/progress", movieId: update.mediaId), method: "PUT", token: token, body: body)
    }

    func updatePlaybackSession(sessionId: String, positionSeconds: Double, playState: String, token: String) async throws {
        let body = try encoder.encode(
            PlaybackSessionUpdateRequest(
                positionSeconds: positionSeconds,
                playState: playState,
                selectionDiagnostics: nil
            )
        )
        let _: EmptyResponse = try await send(path: route("/api/v1/playback/sessions/:sessionId", sessionId: sessionId), method: "PUT", token: token, body: body)
    }

    func stopPlaybackSession(sessionId: String, positionSeconds: Double, token: String) async throws {
        let body = try encoder.encode(
            PlaybackSessionUpdateRequest(
                positionSeconds: positionSeconds,
                playState: "stopped",
                selectionDiagnostics: nil
            )
        )
        let _: EmptyResponse = try await send(path: route("/api/v1/playback/sessions/:sessionId/stop", sessionId: sessionId), method: "POST", token: token, body: body)
    }

    private func send<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        method: String,
        token: String?,
        body: Data?
    ) async throws -> Response {
        let url = makeURL(path: path, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw LuminaClientError.transport("missing HTTP response")
            }
            if (200..<300).contains(http.statusCode) {
                if data.isEmpty, Response.self == EmptyResponse.self {
                    return EmptyResponse() as! Response
                }
                do {
                    return try decoder.decode(Response.self, from: data)
                } catch {
                    throw LuminaClientError.decoding
                }
            }
            if let envelope = try? decoder.decode(LuminaErrorEnvelope.self, from: data) {
                throw LuminaClientError.server(envelope.error)
            }
            if let backendError = try? decoder.decode(BackendErrorResponse.self, from: data) {
                throw LuminaClientError.server(
                    LuminaErrorEnvelope.Body(
                        code: backendError.error.uppercased(),
                        category: "auth",
                        safeMessage: backendError.message,
                        retryable: false,
                        correlationId: nil,
                        details: nil
                    )
                )
            }
            throw LuminaClientError.fromHTTPStatus(http.statusCode, path: path)
        } catch let error as LuminaClientError {
            throw error
        } catch {
            throw LuminaClientError.fromTransport(error)
        }
    }

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL {
        let rawURL = URL(string: path, relativeTo: baseURL)?.absoluteURL
            ?? baseURL.appending(path: path)
        guard var components = URLComponents(url: rawURL, resolvingAgainstBaseURL: true) else {
            return rawURL
        }
        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }
        return components.url ?? rawURL
    }

    private func route(_ template: String, movieId: String? = nil, sessionId: String? = nil) -> String {
        var path = template
        if let movieId {
            path = path.replacingOccurrences(of: ":movieId", with: movieId)
            path = path.replacingOccurrences(of: ":id", with: movieId)
        }
        if let sessionId {
            path = path.replacingOccurrences(of: ":sessionId", with: sessionId)
        }
        return path
    }
}

private struct EmptyResponse: Decodable {
    init() {}
}

protocol TokenStore {
    func loadToken() throws -> String?
    func saveToken(_ token: String) throws
    func clearToken() throws
}

final class KeychainTokenStore: TokenStore {
    private let service = "com.nitramator.lumina.auth"
    private let account = "jwt"

    func loadToken() throws -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = item as? Data else {
            throw LuminaClientError.missingToken
        }
        return String(data: data, encoding: .utf8)
    }

    func saveToken(_ token: String) throws {
        try clearToken()
        var item = baseQuery()
        item[kSecValueData as String] = Data(token.utf8)
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LuminaClientError.missingToken
        }
    }

    func clearToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw LuminaClientError.missingToken
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

final class InMemoryTokenStore: TokenStore {
    private var token: String?

    func loadToken() throws -> String? {
        token
    }

    func saveToken(_ token: String) throws {
        self.token = token
    }

    func clearToken() throws {
        token = nil
    }
}

protocol ServerSettingsStore: AnyObject {
    var serverURLString: String? { get set }
}

final class UserDefaultsServerSettingsStore: ServerSettingsStore {
    private let defaults: UserDefaults
    private let key = "lumina.serverURL"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var serverURLString: String? {
        get { defaults.string(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}

struct DiagnosticsEvent: Equatable {
    let operation: String
    let routeKey: String?
    let statusCode: Int?
    let correlationId: String?
    let message: String
}

final class DiagnosticsRecorder {
    private(set) var events: [DiagnosticsEvent] = []

    func record(operation: String, routeKey: String? = nil, statusCode: Int? = nil, correlationId: String? = nil, message: String) {
        events.append(
            DiagnosticsEvent(
                operation: operation,
                routeKey: routeKey,
                statusCode: statusCode,
                correlationId: correlationId,
                message: Self.redact(message)
            )
        )
    }

    static func redact(_ value: String) -> String {
        var redacted = value
        let patterns = [
            #"Bearer\s+[A-Za-z0-9._\-]+"#,
            #"(?i)password[=:]\S+"#,
            #"(?i)(stream_token|access_token|refresh_token|signature|signed)[=][^&\s]+"#,
            #"(?i)(token|jwt|authorization)[=:]\S+"#,
            #"/Users/[^ ]+"#,
            #"(?i)select\s+.+\s+from\s+.+"#
        ]
        for pattern in patterns {
            redacted = redacted.replacingOccurrences(of: pattern, with: "[redacted]", options: .regularExpression)
        }
        return redacted
    }
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

    func playCatalogMovie(_ item: CatalogItem) async {
        guard item.mediaType == "movie" else {
            statusMessage = "Episode playback from catalog shelves is not wired yet."
            return
        }
        await loadPlaybackProof(movieOverride: item.playableMovie)
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
