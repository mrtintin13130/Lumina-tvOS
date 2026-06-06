//
//  URLSessionLuminaAPIClient.swift
//  lumina
//

import Foundation

protocol LuminaAPIClient {
    func fetchCapabilities() async throws -> ServerCapabilities
    func login(email: String, password: String) async throws -> LoginResponse
    func currentUser(token: String) async throws -> LuminaUser
    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse
    func fetchEditorialSection(sectionId: String, token: String) async throws -> CatalogSection
    func fetchMovies(token: String) async throws -> [CatalogItem]
    func fetchTVShows(token: String) async throws -> [CatalogItem]
    func searchCatalog(query: String, token: String) async throws -> [CatalogItem]
    func fetchMovieDetail(movieId: String, token: String) async throws -> CatalogItem
    func fetchTVShowDetail(showId: String, token: String) async throws -> CatalogItem
    func fetchTVSeasons(showId: String, token: String) async throws -> [TVSeasonSummary]
    func fetchTVEpisodes(showId: String, seasonNumber: Int, token: String) async throws -> [CatalogItem]
    func fetchPlayableMovie(token: String) async throws -> PlayableMovie
    func fetchMovieProgress(movieId: String, token: String) async throws -> MovieProgressResponse
    func fetchMovieTracks(movieId: String, token: String) async throws -> MediaTrackListing
    func createPlaybackSession(mediaId: String, positionSeconds: Double, token: String) async throws -> PlaybackSessionResponse
    func requestStreamToken(mediaType: String, mediaId: String, token: String) async throws -> String?
    func movieHLSManifestURL(movie: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String) -> URL
    func preflightHLSManifest(url: URL) async throws -> HLSManifestInspection
    func reportProgress(_ update: ProgressUpdateRequest, token: String) async throws
    func updatePlaybackSession(sessionId: String, positionSeconds: Double, playState: String, token: String) async throws
    func stopPlaybackSession(sessionId: String, positionSeconds: Double, token: String) async throws
}

struct URLSessionLuminaAPIClient: LuminaAPIClient {
    static let requestTimeout: TimeInterval = 20
    static let resourceTimeout: TimeInterval = 60
    static let hlsResourceTimeout: TimeInterval = 30

    let baseURL: URL
    var session: URLSession = .shared
    var decoder = JSONDecoder()
    var encoder = JSONEncoder()
    var routeTemplates = RouteTemplateResolver()

    static func makeDefaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = resourceTimeout
        configuration.waitsForConnectivity = false
        configuration.allowsConstrainedNetworkAccess = true
        configuration.allowsExpensiveNetworkAccess = true
        configuration.urlCache = URLCache(
            memoryCapacity: 8 * 1024 * 1024,
            diskCapacity: 32 * 1024 * 1024,
            diskPath: "LuminaURLCache"
        )
        return URLSession(configuration: configuration)
    }

    init(
        baseURL: URL,
        session: URLSession = URLSessionLuminaAPIClient.makeDefaultSession(),
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        capabilities: ServerCapabilities? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.routeTemplates = RouteTemplateResolver(routes: capabilities?.routes ?? [:])
    }

    func fetchCapabilities() async throws -> ServerCapabilities {
        try await send(path: "/api/v1/system/capabilities", method: "GET", token: nil, body: Optional<Data>.none)
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let body = try encoder.encode(LoginRequest(email: email, password: password))
        return try await send(path: route(key: "authLogin", fallback: "/api/v1/auth/login"), method: "POST", token: nil, body: body)
    }

    func currentUser(token: String) async throws -> LuminaUser {
        try await send(path: route(key: "authMe", fallback: "/api/v1/auth/me"), method: "GET", token: token, body: Optional<Data>.none)
    }

    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse {
        try await send(
            path: route(key: "catalogHome", fallback: "/api/v1/catalog/home"),
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

    func fetchEditorialSection(sectionId: String, token: String) async throws -> CatalogSection {
        try await send(
            path: route(
                key: "catalogEditorialSection",
                fallback: "/api/v1/catalog/editorial/:sectionId",
                sectionId: sectionId
            ),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
    }

    func fetchMovies(token: String) async throws -> [CatalogItem] {
        let response: CatalogListResponse = try await send(
            path: route(key: "catalogMovies", fallback: "/api/v1/catalog/movies"),
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
            path: route(key: "catalogTvShows", fallback: "/api/v1/catalog/tv_shows"),
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
            path: route(key: "catalogSearch", fallback: "/api/v1/catalog/search"),
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

    func fetchMovieDetail(movieId: String, token: String) async throws -> CatalogItem {
        let response: CatalogDetailResponse = try await send(
            path: route(key: "catalogMovieDetail", fallback: "/api/v1/catalog/movies/:movieId", movieId: movieId),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.item
    }

    func fetchTVShowDetail(showId: String, token: String) async throws -> CatalogItem {
        let response: CatalogDetailResponse = try await send(
            path: route(key: "catalogTvShowDetail", fallback: "/api/v1/catalog/tv_shows/:showId", showId: showId),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.item
    }

    func fetchTVSeasons(showId: String, token: String) async throws -> [TVSeasonSummary] {
        let response: TVSeasonListResponse = try await send(
            path: route(key: "catalogTvSeasons", fallback: "/api/v1/catalog/tv_shows/:showId/seasons", showId: showId),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.seasons
    }

    func fetchTVEpisodes(showId: String, seasonNumber: Int, token: String) async throws -> [CatalogItem] {
        let response: TVEpisodeListResponse = try await send(
            path: route(
                key: "catalogTvEpisodes",
                fallback: "/api/v1/catalog/tv_shows/:showId/seasons/:seasonNumber/episodes",
                showId: showId,
                seasonNumber: seasonNumber
            ),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.episodes
    }

    func fetchPlayableMovie(token: String) async throws -> PlayableMovie {
        let response: MovieListResponse = try await send(
            path: route(key: "catalogMovies", fallback: "/api/v1/catalog/movies"),
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
        try await send(path: route(key: "movieProgress", fallback: "/api/v1/playback/movies/:movieId/progress", movieId: movieId), method: "GET", token: token, body: Optional<Data>.none)
    }

    func fetchMovieTracks(movieId: String, token: String) async throws -> MediaTrackListing {
        try await send(path: route(key: "movieTracks", fallback: "/api/v1/playback/movies/:movieId/tracks", movieId: movieId), method: "GET", token: token, body: Optional<Data>.none)
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
        return try await send(path: route(key: "playbackSessions", fallback: "/api/v1/playback/sessions"), method: "POST", token: token, body: body)
    }

    func requestStreamToken(mediaType: String, mediaId: String, token: String) async throws -> String? {
        let body = try encoder.encode(StreamTokenRequest(mediaType: mediaType, mediaId: mediaId))
        let response: StreamTokenResponse = try await send(path: route(key: "streamToken", fallback: "/api/v1/stream/token"), method: "POST", token: token, body: body)
        return response.token
    }

    func movieHLSManifestURL(movie: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String = "720p") -> URL {
        let path = validatedManifestPath(movie.hlsManifestPath)
            ?? route(key: "movieHlsManifest", fallback: "/api/v1/stream/movies/:movieId/hls/manifest.m3u8", movieId: movie.id)
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

    func preflightHLSManifest(url: URL) async throws -> HLSManifestInspection {
        do {
            let manifest = try await fetchHLSResource(url: url, label: "Manifest", byteRange: nil)
            guard manifest.text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#EXTM3U") else {
                throw LuminaClientError.transport("Manifest request succeeded, but the response was not an HLS manifest.")
            }
            let manifestInspection = Self.inspectHLSManifest(manifest.text)
            guard let playlistURL = firstHLSResourceURL(in: manifest.text, relativeTo: manifest.url, matching: ".m3u8") else {
                return HLSManifestInspection(
                    audioRenditionCount: manifestInspection.audioRenditionCount,
                    subtitleRenditionCount: manifestInspection.subtitleRenditionCount,
                    nonPlaylistSubtitleRenditionCount: manifestInspection.nonPlaylistSubtitleRenditionCount,
                    checkedVariantPlaylist: false,
                    checkedFirstSegment: false
                )
            }

            let playlist = try await fetchHLSResource(url: playlistURL, label: "Playlist", byteRange: nil)
            guard playlist.text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#EXTM3U") else {
                throw LuminaClientError.transport("Playlist request succeeded, but the response was not an HLS playlist.")
            }
            guard let segmentURL = firstHLSResourceURL(in: playlist.text, relativeTo: playlist.url, matching: ".ts") else {
                return HLSManifestInspection(
                    audioRenditionCount: manifestInspection.audioRenditionCount,
                    subtitleRenditionCount: manifestInspection.subtitleRenditionCount,
                    nonPlaylistSubtitleRenditionCount: manifestInspection.nonPlaylistSubtitleRenditionCount,
                    checkedVariantPlaylist: true,
                    checkedFirstSegment: false
                )
            }
            _ = try await fetchHLSResource(url: segmentURL, label: "First segment", byteRange: "bytes=0-1")
            return HLSManifestInspection(
                audioRenditionCount: manifestInspection.audioRenditionCount,
                subtitleRenditionCount: manifestInspection.subtitleRenditionCount,
                nonPlaylistSubtitleRenditionCount: manifestInspection.nonPlaylistSubtitleRenditionCount,
                checkedVariantPlaylist: true,
                checkedFirstSegment: true
            )
        } catch let error as LuminaClientError {
            throw error
        } catch {
            throw LuminaClientError.fromTransport(error)
        }
    }

    private func fetchHLSResource(url: URL, label: String, byteRange: String?) async throws -> (url: URL, text: String) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = Self.hlsResourceTimeout
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

    static func inspectHLSManifest(_ manifest: String) -> HLSManifestInspection {
        let mediaLines = manifest
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasPrefix("#EXT-X-MEDIA:") }
        let audioLines = mediaLines.filter { hlsMediaLine($0, hasType: "AUDIO") }
        let subtitleLines = mediaLines.filter { hlsMediaLine($0, hasType: "SUBTITLES") }
        let nonPlaylistSubtitleLines = subtitleLines.filter { line in
            guard let uri = hlsAttribute("URI", in: line) else {
                return true
            }
            return !uri.localizedCaseInsensitiveContains(".m3u8")
        }
        return HLSManifestInspection(
            audioRenditionCount: audioLines.count,
            subtitleRenditionCount: subtitleLines.count,
            nonPlaylistSubtitleRenditionCount: nonPlaylistSubtitleLines.count,
            checkedVariantPlaylist: false,
            checkedFirstSegment: false
        )
    }

    private static func hlsMediaLine(_ line: String, hasType type: String) -> Bool {
        hlsAttribute("TYPE", in: line)?.uppercased() == type
    }

    private static func hlsAttribute(_ name: String, in line: String) -> String? {
        guard let attributesStart = line.firstIndex(of: ":") else {
            return nil
        }
        let attributes = line[line.index(after: attributesStart)...]
        for rawAttribute in attributes.split(separator: ",", omittingEmptySubsequences: false) {
            let pieces = rawAttribute.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard pieces.count == 2, pieces[0].trimmingCharacters(in: .whitespacesAndNewlines) == name else {
                continue
            }
            return pieces[1]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
        return nil
    }

    func reportProgress(_ update: ProgressUpdateRequest, token: String) async throws {
        let body = try encoder.encode(update)
        let _: EmptyResponse = try await send(path: route(keys: ["movieProgressUpdate", "progressUpdate"], fallback: "/api/v1/playback/movies/:movieId/progress", movieId: update.mediaId), method: "PUT", token: token, body: body)
    }

    func updatePlaybackSession(sessionId: String, positionSeconds: Double, playState: String, token: String) async throws {
        let body = try encoder.encode(
            PlaybackSessionUpdateRequest(
                positionSeconds: positionSeconds,
                playState: playState,
                selectionDiagnostics: nil
            )
        )
        let _: EmptyResponse = try await send(path: route(key: "playbackSession", fallback: "/api/v1/playback/sessions/:sessionId", sessionId: sessionId), method: "PUT", token: token, body: body)
    }

    func stopPlaybackSession(sessionId: String, positionSeconds: Double, token: String) async throws {
        let body = try encoder.encode(
            PlaybackSessionUpdateRequest(
                positionSeconds: positionSeconds,
                playState: "stopped",
                selectionDiagnostics: nil
            )
        )
        let _: EmptyResponse = try await send(path: route(key: "playbackSessionStop", fallback: "/api/v1/playback/sessions/:sessionId/stop", sessionId: sessionId), method: "POST", token: token, body: body)
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
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = Self.requestTimeout
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
            if http.statusCode == 401 || http.statusCode == 403 {
                throw LuminaClientError.sessionExpired
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

    private func route(
        key: String,
        fallback: String,
        movieId: String? = nil,
        showId: String? = nil,
        seasonNumber: Int? = nil,
        sessionId: String? = nil,
        sectionId: String? = nil
    ) -> String {
        var parameters: [String: String] = [:]
        if let movieId {
            parameters["movieId"] = movieId
            parameters["id"] = movieId
        }
        if let showId {
            parameters["showId"] = showId
        }
        if let seasonNumber {
            parameters["seasonNumber"] = String(seasonNumber)
        }
        if let sessionId {
            parameters["sessionId"] = sessionId
        }
        if let sectionId {
            parameters["sectionId"] = sectionId
            parameters["id"] = sectionId
        }
        return routeTemplates.path(key: key, fallback: fallback, parameters: parameters)
    }

    private func route(
        keys: [String],
        fallback: String,
        movieId: String? = nil
    ) -> String {
        var parameters: [String: String] = [:]
        if let movieId {
            parameters["movieId"] = movieId
            parameters["id"] = movieId
        }
        return routeTemplates.path(keys: keys, fallback: fallback, parameters: parameters)
    }

    private func validatedManifestPath(_ path: String?) -> String? {
        guard let path, path.hasPrefix("/api/") else {
            return nil
        }
        return path
    }
}

fileprivate struct EmptyResponse: Decodable {
    init() {}
}
