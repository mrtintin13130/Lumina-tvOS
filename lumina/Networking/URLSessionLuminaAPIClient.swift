//
//  URLSessionLuminaAPIClient.swift
//  lumina
//

import Foundation

protocol LuminaAPIClient {
    func fetchCapabilities() async throws -> ServerCapabilities
    func login(username: String, password: String) async throws -> LoginResponse
    func currentUser(token: String) async throws -> LuminaUser
    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse
    func fetchMovies(token: String) async throws -> [CatalogItem]
    func fetchTVShows(token: String) async throws -> [CatalogItem]
    func searchCatalog(query: String, token: String) async throws -> [CatalogItem]
    func fetchMovieDetail(movieId: String, token: String) async throws -> CatalogItem
    func fetchTVShowDetail(showId: String, token: String) async throws -> CatalogItem
    func fetchTVSeasons(showId: String, token: String) async throws -> [TVSeasonSummary]
    func fetchTVEpisodes(showId: String, seasonNumber: Int, token: String) async throws -> [CatalogItem]
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

    func fetchMovieDetail(movieId: String, token: String) async throws -> CatalogItem {
        let response: CatalogDetailResponse = try await send(
            path: route("/api/v1/catalog/movies/:movieId", movieId: movieId),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.item
    }

    func fetchTVShowDetail(showId: String, token: String) async throws -> CatalogItem {
        let response: CatalogDetailResponse = try await send(
            path: route("/api/v1/catalog/tv_shows/:showId", showId: showId),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.item
    }

    func fetchTVSeasons(showId: String, token: String) async throws -> [TVSeasonSummary] {
        let response: TVSeasonListResponse = try await send(
            path: route("/api/v1/catalog/tv_shows/:showId/seasons", showId: showId),
            method: "GET",
            token: token,
            body: Optional<Data>.none
        )
        return response.seasons
    }

    func fetchTVEpisodes(showId: String, seasonNumber: Int, token: String) async throws -> [CatalogItem] {
        let response: TVEpisodeListResponse = try await send(
            path: route(
                "/api/v1/catalog/tv_shows/:showId/seasons/:seasonNumber/episodes",
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

    private func route(
        _ template: String,
        movieId: String? = nil,
        showId: String? = nil,
        seasonNumber: Int? = nil,
        sessionId: String? = nil
    ) -> String {
        var path = template
        if let movieId {
            path = path.replacingOccurrences(of: ":movieId", with: movieId)
            path = path.replacingOccurrences(of: ":id", with: movieId)
        }
        if let showId {
            path = path.replacingOccurrences(of: ":showId", with: showId)
        }
        if let seasonNumber {
            path = path.replacingOccurrences(of: ":seasonNumber", with: String(seasonNumber))
        }
        if let sessionId {
            path = path.replacingOccurrences(of: ":sessionId", with: sessionId)
        }
        return path
    }
}

fileprivate struct EmptyResponse: Decodable {
    init() {}
}
