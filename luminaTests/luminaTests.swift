//
//  luminaTests.swift
//  luminaTests
//
//  Created by Martin Thomas on 29/05/2026.
//

import Darwin
import XCTest
@testable import lumina

final class luminaTests: XCTestCase {

    func testSupportedCapabilitiesDecodeAndAreCompatible() throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")

        XCTAssertEqual(capabilities.auth.modes, ["password_jwt"])
        XCTAssertTrue(capabilities.isTvMVPCompatible)
        XCTAssertEqual(capabilities.routes["movieHlsManifest"], "/api/v1/stream/movies/:id/hls/manifest.m3u8")
        XCTAssertEqual(capabilities.routes["authLogin"], "/api/v1/auth/login")
        XCTAssertEqual(capabilities.routes["catalogMovieDetail"], "/api/v1/catalog/movies/:movieId")
        XCTAssertEqual(capabilities.routes["streamToken"], "/api/v1/stream/token")
        XCTAssertEqual(capabilities.routes["playbackSessions"], "/api/v1/playback/sessions")
        XCTAssertEqual(capabilities.routes["playbackSessionStop"], "/api/v1/playback/sessions/:sessionId/stop")
        XCTAssertEqual(capabilities.routes["movieProgress"], "/api/v1/playback/movies/:movieId/progress")
        XCTAssertEqual(capabilities.routes["movieProgressUpdate"], "/api/v1/playback/movies/:movieId/progress")
    }

    func testUnsupportedCapabilitiesDecodeAndAreNotCompatible() throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-unsupported")

        XCTAssertFalse(capabilities.isTvMVPCompatible)
        XCTAssertFalse(capabilities.playback.hls.movies)
    }

    func testServerConnectionTesterAcceptsBackendTVContractVersion() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        XCTAssertEqual(capabilities.api.version, "2026-05-tv")

        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.url?.path, "/api/v1/health")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            let data = #"{"status":"OK","app":"Lumina","version":"1.0.0"}"#.data(using: .utf8)!
            return (response, data)
        }
        defer { MockURLProtocol.handler = nil }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let tester = ServerConnectionTester(
            session: URLSession(configuration: configuration),
            apiClientFactory: { _, _ in FakeLuminaAPIClient(capabilities: capabilities) }
        )

        let validated = try await tester.validateServer(baseURL: URL(string: "http://lumina.local:3000")!)

        XCTAssertEqual(validated.api.version, "2026-05-tv")
        XCTAssertTrue(validated.isTvMVPCompatible)
    }

    func testNetServiceAddressResolverUsesNumericIPv4Address() throws {
        var ipv4 = sockaddr_in()
        ipv4.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        ipv4.sin_family = sa_family_t(AF_INET)
        ipv4.sin_port = in_port_t(3000).bigEndian
        XCTAssertEqual(inet_pton(AF_INET, "192.168.1.42", &ipv4.sin_addr), 1)

        let data = withUnsafeBytes(of: ipv4) { Data($0) }

        XCTAssertEqual(NetServiceAddressResolver.host(from: [data]), "192.168.1.42")
    }

    func testErrorEnvelopeDecodesSafeMessage() throws {
        let envelope = try decodeFixture(LuminaErrorEnvelope.self, name: "error-envelope-stream-token-expired")

        XCTAssertEqual(envelope.error.category, "stream_token")
        XCTAssertEqual(envelope.error.safeMessage, "The playback link expired. Try playing again.")
        XCTAssertTrue(envelope.error.retryable)
    }

    func testNoPlayableMediaEnvelopeDecodesSafeSupportDetails() throws {
        let envelope = try decodeFixture(LuminaErrorEnvelope.self, name: "error-envelope-no-playable-media")

        XCTAssertEqual(envelope.error.code, "NO_PLAYABLE_MOVIE")
        XCTAssertEqual(envelope.error.category, "missing_media")
        XCTAssertEqual(envelope.error.safeMessage, "No playable movie was found on this Lumina server.")
        XCTAssertEqual(envelope.error.correlationId, "support-no-playable-1")
        XCTAssertTrue(envelope.error.retryable)
    }

    func testBackendLoginResponseDecodesTokenAndUserShape() throws {
        let json = """
        {
          "message": "Login successful",
          "token": "sample-token",
          "user": {
            "id": 1,
            "email": "admin@example.test",
            "username": "mrtintin13",
            "firstname": "Martin",
            "lastname": "THOMAS"
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(LoginResponse.self, from: json)

        XCTAssertEqual(response.accessToken, "sample-token")
        XCTAssertEqual(response.user?.id, "1")
        XCTAssertEqual(response.user?.displayName, "Martin THOMAS")
    }

    func testCatalogMovieListDecodesFlexibleBackendShape() throws {
        let json = """
        {
          "items": [
            {
              "id": 42,
              "title": "Heat",
              "overview": "A playable movie.",
              "duration_seconds": 10200,
              "playback_readiness": {
                "has_playable_media": true
              },
              "progress": {
                "position_seconds": 120
              }
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(MovieListResponse.self, from: json)

        XCTAssertEqual(response.items.first?.id, "42")
        XCTAssertEqual(response.items.first?.title, "Heat")
        XCTAssertEqual(response.items.first?.durationSeconds, 10200)
        XCTAssertEqual(response.items.first?.resumePositionSeconds, 120)
        XCTAssertEqual(response.items.first?.hasPlayableMedia, true)
    }

    func testCatalogHomeDecodesPresentationArtworkPaths() throws {
        let json = """
        {
          "hero": {
            "title": "Featured",
            "presentation": {
              "layout": "cinematic_carousel",
              "autoplay": true
            },
            "items": [
              {
                "media_type": "movie",
                "id": 8,
                "title": "The Punisher One Last Kill",
                "year": 2026,
                "poster_path": "/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg",
                "backdrop_path": "/qO55CD8tgVL1T4WKn6zYFFiD6lL.jpg",
                "backdrop_with_text_path": "/etfKck6BHfGc4Q9ScDIECjomLYO.jpg",
                "progress": {
                  "progress_percent": 25
                },
                "playback_readiness": {
                  "has_playable_media": true
                }
              }
            ]
          },
          "sections": []
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(CatalogHomeResponse.self, from: json)
        let item = try XCTUnwrap(response.hero?.items.first)

        XCTAssertEqual(response.hero?.title, "Featured")
        XCTAssertEqual(response.hero?.presentation?.layout, "cinematic_carousel")
        XCTAssertEqual(response.hero?.presentation?.autoplay, true)
        XCTAssertEqual(item.id, "8")
        XCTAssertEqual(item.subtitle, "2026")
        XCTAssertEqual(item.posterPath, "/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg")
        XCTAssertEqual(item.backdropPath, "/etfKck6BHfGc4Q9ScDIECjomLYO.jpg")
        XCTAssertEqual(item.progressPercent, 25)
        XCTAssertEqual(item.hasPlayableMedia, true)
    }

    func testCatalogHomeDecodesPresentationSectionsAndGenreLinks() throws {
        let json = """
        {
          "hero": {
            "subtitle": "Hand-picked from your library",
            "items": []
          },
          "layout": {
            "version": "catalog-home-layout-v1",
            "generated_at": "2026-05-24T00:00:00.000Z"
          },
          "sections": [
            {
              "id": "recent_movies",
              "title": "Recent Movies",
              "type": "catalog_row",
              "media_type": "movie",
              "presentation": {
                "layout": "poster_rail",
                "emphasis": "standard",
                "theme": "default",
                "view_all": {
                  "label": "View All",
                  "href": "/movies"
                }
              },
              "items": [
                {
                  "id": 42,
                  "media_type": "movie",
                  "title": "Heat"
                }
              ]
            },
            {
              "id": "sci_fi_epics",
              "title": "Sci-Fi Epics",
              "type": "catalog_row",
              "media_type": "movie",
              "genre_id": 878,
              "eyebrow": "Journey's Beyond Imagination",
              "subtitle": "Epic worlds. Infinite possibilities.",
              "tags": ["Space Opera", "Dystopian Futures"],
              "presentation": {
                "layout": "cinematic_banner",
                "emphasis": "featured",
                "theme": "cool",
                "view_all": {
                  "label": "View All",
                  "href": "/editorial/sci_fi_epics"
                }
              },
              "items": [
                {
                  "id": 10,
                  "media_type": "movie",
                  "title": "Arrival",
                  "backdrop_path": "/arrival-bg.jpg"
                }
              ]
            },
            {
              "id": "genre_links",
              "title": "Genres",
              "type": "genre_links",
              "media_type": "mixed",
              "presentation": {
                "layout": "genre_pills",
                "emphasis": "utility",
                "theme": "default"
              },
              "items": [
                {
                  "id": 80,
                  "name": "Crime",
                  "count": 4,
                  "href": "/genres/80"
                }
              ]
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(CatalogHomeResponse.self, from: json)
        let mediaSection = try XCTUnwrap(response.sections.first)
        let editorialSection = try XCTUnwrap(response.sections.dropFirst().first)
        let genreSection = try XCTUnwrap(response.sections.last)
        let genre = try XCTUnwrap(genreSection.items.first)

        XCTAssertEqual(response.hero?.subtitle, "Hand-picked from your library")
        XCTAssertEqual(response.layout?.version, "catalog-home-layout-v1")
        XCTAssertEqual(response.layout?.generatedAt, "2026-05-24T00:00:00.000Z")
        XCTAssertEqual(mediaSection.type, "catalog_row")
        XCTAssertEqual(mediaSection.presentation?.layout, "poster_rail")
        XCTAssertEqual(mediaSection.presentation?.emphasis, "standard")
        XCTAssertEqual(mediaSection.presentation?.viewAll?.href, "/movies")
        XCTAssertEqual(editorialSection.id, "sci_fi_epics")
        XCTAssertEqual(editorialSection.genreId, 878)
        XCTAssertEqual(editorialSection.eyebrow, "Journey's Beyond Imagination")
        XCTAssertEqual(editorialSection.subtitle, "Epic worlds. Infinite possibilities.")
        XCTAssertEqual(editorialSection.tags, ["Space Opera", "Dystopian Futures"])
        XCTAssertEqual(editorialSection.presentation?.layout, "cinematic_banner")
        XCTAssertEqual(editorialSection.presentation?.viewAll?.href, "/editorial/sci_fi_epics")
        XCTAssertEqual(genreSection.type, "genre_links")
        XCTAssertEqual(genreSection.presentation?.layout, "genre_pills")
        XCTAssertEqual(genre.title, "Crime")
        XCTAssertEqual(genre.linkCount, 4)
        XCTAssertEqual(genre.href, "/genres/80")
    }

    func testHomeSectionLayoutFollowsPresentationLayout() {
        XCTAssertEqual(section(layout: "cinematic_carousel").homeLayout, .heroCarousel)
        XCTAssertEqual(section(layout: "continue_landscape").homeLayout, .continueLandscape)
        XCTAssertEqual(section(layout: "poster_rail").homeLayout, .posterRail)
        XCTAssertEqual(section(layout: "spotlight_rail").homeLayout, .landscapeRail)
        XCTAssertEqual(section(layout: "compact_rail").homeLayout, .compactRail)
        XCTAssertEqual(section(layout: "genre_pills").homeLayout, .genrePills)
        XCTAssertEqual(section(layout: "logo_card_rail").homeLayout, .logoCardRail)
        XCTAssertEqual(section(layout: "cinematic_banner").homeLayout, .editorialBanner)
        XCTAssertEqual(section(layout: nil).homeLayout, .posterRail)
    }

    func testCatalogMovieDetailDecodesNestedMetadata() throws {
        let json = """
        {
          "movie": {
            "id": 42,
            "media_type": "movie",
            "title": "Heat",
            "release_date": "1995-12-15",
            "runtime": 170,
            "rating": 8.3,
            "content_rating": "R",
            "genres": [{"name": "Crime"}, {"name": "Drama"}],
            "list_membership": {"in_watchlist": true, "is_favorite": false},
            "primary_trailer": {"name": "Official Trailer"},
            "credits": [
              {"person_id": 1, "name": "Al Pacino", "profile_path": "/al.jpg", "credit_type": "cast", "character": "Hanna"},
              {"person_id": 2, "name": "Michael Mann", "credit_type": "crew", "job": "Director"}
            ],
            "playback_readiness": {"has_playable_media": true}
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(CatalogDetailResponse.self, from: json)

        XCTAssertEqual(response.item.id, "42")
        XCTAssertEqual(response.item.year, 1995)
        XCTAssertEqual(response.item.runtimeMinutes, 170)
        XCTAssertEqual(response.item.rating, 8.3)
        XCTAssertEqual(response.item.contentRating, "R")
        XCTAssertEqual(response.item.genres, ["Crime", "Drama"])
        XCTAssertEqual(response.item.isWatchlisted, true)
        XCTAssertEqual(response.item.isFavorite, false)
        XCTAssertEqual(response.item.primaryTrailerTitle, "Official Trailer")
        XCTAssertEqual(response.item.cast.first?.name, "Al Pacino")
        XCTAssertEqual(response.item.cast.first?.role, "Hanna")
        XCTAssertEqual(response.item.cast.first?.creditType, "cast")
        XCTAssertEqual(response.item.crew.first?.name, "Michael Mann")
        XCTAssertEqual(response.item.hasPlayableMedia, true)
    }

    func testTVSeasonAndEpisodeListsDecodeFlexibleBackendShapes() throws {
        let seasonsJSON = """
        {
          "seasons": [
            {"season_number": 1, "title": "Season 1", "poster_path": "/season.jpg"}
          ]
        }
        """.data(using: .utf8)!
        let episodesJSON = """
        {
          "episodes": [
            {
              "id": "e1",
              "media_type": "episode",
              "title": "Secrets",
              "season_number": 1,
              "episode_number": 1,
              "progress": {"progress_percent": 25},
              "playback_readiness": {"has_playable_media": true}
            }
          ]
        }
        """.data(using: .utf8)!

        let seasons = try JSONDecoder().decode(TVSeasonListResponse.self, from: seasonsJSON)
        let episodes = try JSONDecoder().decode(TVEpisodeListResponse.self, from: episodesJSON)

        XCTAssertEqual(seasons.seasons.first?.seasonNumber, 1)
        XCTAssertEqual(seasons.seasons.first?.title, "Season 1")
        XCTAssertEqual(episodes.episodes.first?.mediaType, "episode")
        XCTAssertEqual(episodes.episodes.first?.progressPercent, 25)
        XCTAssertEqual(episodes.episodes.first?.hasPlayableMedia, true)
    }

    @MainActor
    func testArtworkURLResolvesTMDBAndServerPaths() {
        let resolver = ArtworkURLResolver(serverURL: URL(string: "https://lumina.example.test")!)

        XCTAssertEqual(
            resolver.url(for: "/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg", kind: .poster)?.absoluteString,
            "https://image.tmdb.org/t/p/w500/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg"
        )
        XCTAssertEqual(
            resolver.url(for: "/qO55CD8tgVL1T4WKn6zYFFiD6lL.jpg", kind: .backdrop)?.absoluteString,
            "https://image.tmdb.org/t/p/w1280/qO55CD8tgVL1T4WKn6zYFFiD6lL.jpg"
        )
        XCTAssertEqual(
            resolver.url(for: "/api/v1/artwork/poster.jpg", kind: .poster)?.absoluteString,
            "https://lumina.example.test/api/v1/artwork/poster.jpg"
        )
        XCTAssertEqual(
            resolver.url(for: "https://cdn.example.test/poster.jpg", kind: .poster)?.absoluteString,
            "https://cdn.example.test/poster.jpg"
        )
    }

    func testPlaybackSessionCreateEncodesRealSnakeCasePayload() throws {
        let request = PlaybackSessionCreateRequest(
            mediaType: "movie",
            mediaId: "42",
            positionSeconds: 12,
            playState: "playing",
            clientLabel: "Lumina tvOS"
        )
        let object = try encodedJSONObject(request)

        XCTAssertEqual(object["media_type"] as? String, "movie")
        XCTAssertEqual(object["media_id"] as? String, "42")
        XCTAssertEqual(object["position_seconds"] as? Double, 12)
        XCTAssertEqual(object["play_state"] as? String, "playing")
        XCTAssertEqual(object["client_label"] as? String, "Lumina tvOS")
        XCTAssertNil(object["mediaType"])
    }

    func testMovieProgressUpdateEncodesRealSnakeCasePayloadWithoutRouteOnlyFields() throws {
        let request = ProgressUpdateRequest(
            mediaId: "42",
            positionSeconds: 240,
            durationSeconds: 10200,
            playState: "paused"
        )
        let object = try encodedJSONObject(request)

        XCTAssertEqual(object["position_seconds"] as? Double, 240)
        XCTAssertEqual(object["duration_seconds"] as? Double, 10200)
        XCTAssertEqual(object["play_state"] as? String, "paused")
        XCTAssertNil(object["mediaId"])
        XCTAssertNil(object["media_id"])
    }

    func testStreamTokenResponseDecodesBackendVariants() throws {
        let json = #"{"stream_token":"scoped-token"}"#.data(using: .utf8)!

        let response = try JSONDecoder().decode(StreamTokenResponse.self, from: json)

        XCTAssertEqual(response.token, "scoped-token")
    }

    func testStreamTokenRequestEncodesBackendRequiredScope() throws {
        let request = StreamTokenRequest(mediaType: "movie", mediaId: "42")
        let object = try encodedJSONObject(request)

        XCTAssertEqual(object["media_type"] as? String, "movie")
        XCTAssertEqual(object["media_id"] as? String, "42")
        XCTAssertNil(object["mediaType"])
        XCTAssertNil(object["mediaId"])
    }

    func testPlaybackSessionResponseDecodesNestedBackendShape() throws {
        let json = """
        {
          "session": {
            "id": 77,
            "media_type": "movie",
            "media_id": 42
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(PlaybackSessionResponse.self, from: json)

        XCTAssertEqual(response.id, "77")
        XCTAssertEqual(response.mediaId, "42")
        XCTAssertEqual(response.mediaKind, "movie")
    }

    func testMovieHLSManifestURLAppendsStreamTokenAndPlaybackQueryForAVKit() {
        let client = URLSessionLuminaAPIClient(baseURL: URL(string: "https://lumina.example.test")!)
        let movie = PlayableMovie(id: "42", title: "Heat")

        let url = client.movieHLSManifestURL(
            movie: movie,
            streamToken: "scoped-token",
            sessionId: "77",
            startTime: 12.8,
            quality: "720p"
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://lumina.example.test/api/v1/stream/movies/42/hls/manifest.m3u8?quality=720p&t=12&stream_token=scoped-token&session_id=77"
        )
    }

    func testRouteTemplateResolverUsesCapabilitiesAndEncodesSegments() {
        let resolver = RouteTemplateResolver(routes: [
            "movieHlsManifest": "/api/v1/custom/movies/:id/:movieId/manifest.m3u8"
        ])

        let path = resolver.path(
            key: "movieHlsManifest",
            fallback: "/fallback/:movieId",
            parameters: [
                "id": "movie/42?#",
                "movieId": "movie/42?#"
            ]
        )

        XCTAssertEqual(path, "/api/v1/custom/movies/movie%2F42%3F%23/movie%2F42%3F%23/manifest.m3u8")
    }

    func testMovieHLSManifestURLUsesCapabilityRouteTemplate() throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let client = URLSessionLuminaAPIClient(
            baseURL: URL(string: "https://lumina.example.test")!,
            capabilities: capabilities
        )
        let movie = PlayableMovie(id: "movie/42?#", title: "Heat")

        let url = client.movieHLSManifestURL(
            movie: movie,
            streamToken: nil,
            sessionId: nil,
            startTime: 0,
            quality: "720p"
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://lumina.example.test/api/v1/stream/movies/movie%2F42%3F%23/hls/manifest.m3u8?quality=720p&t=0"
        )
    }

    func testMovieHLSManifestURLEncodesPathSegments() {
        let client = URLSessionLuminaAPIClient(baseURL: URL(string: "https://lumina.example.test")!)
        let movie = PlayableMovie(id: "movie/42?#", title: "Heat")

        let url = client.movieHLSManifestURL(
            movie: movie,
            streamToken: nil,
            sessionId: "session/77",
            startTime: 0,
            quality: "720p"
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://lumina.example.test/api/v1/stream/movies/movie%2F42%3F%23/hls/manifest.m3u8?quality=720p&t=0&session_id=session/77"
        )
    }

    func testMovieHLSManifestURLIgnoresExternalBackendManifestPath() {
        let client = URLSessionLuminaAPIClient(baseURL: URL(string: "https://lumina.example.test")!)
        let movie = PlayableMovie(
            id: "42",
            title: "Heat",
            hlsManifestPath: "https://evil.example.test/manifest.m3u8"
        )

        let url = client.movieHLSManifestURL(
            movie: movie,
            streamToken: nil,
            sessionId: nil,
            startTime: 0,
            quality: "720p"
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://lumina.example.test/api/v1/stream/movies/42/hls/manifest.m3u8?quality=720p&t=0"
        )
    }

    func testEpisodeHLSManifestURLAppendsPlaybackQueryForAVKit() throws {
        let client = URLSessionLuminaAPIClient(baseURL: URL(string: "https://lumina.example.test")!)
        let episode = PlayableMovie(
            id: "episode-99",
            mediaType: "episode",
            title: "Pilot",
            showId: "show/42?#",
            seasonNumber: 1,
            episodeNumber: 2
        )

        let url = try client.episodeHLSManifestURL(
            episode: episode,
            streamToken: "scoped-token",
            sessionId: "session-77",
            startTime: 41.9,
            quality: "720p"
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://lumina.example.test/api/v1/stream/tv/show%2F42%3F%23/seasons/1/episodes/2/hls/manifest.m3u8?quality=720p&t=41&stream_token=scoped-token&session_id=session-77"
        )
    }

    func testEpisodeCatalogItemDecodesPlaybackRouteIdentity() throws {
        let json = """
        {
          "id": 99,
          "media_type": "episode",
          "title": "Pilot",
          "show": {"id": 42, "title": "The Show"},
          "season_number": 1,
          "episode_number": 2,
          "playback_readiness": {"has_playable_media": true}
        }
        """.data(using: .utf8)!

        let episode = try JSONDecoder().decode(CatalogItem.self, from: json)

        XCTAssertEqual(episode.id, "99")
        XCTAssertEqual(episode.showId, "42")
        XCTAssertEqual(episode.seasonNumber, 1)
        XCTAssertEqual(episode.episodeNumber, 2)
        XCTAssertEqual(episode.playableMovie.playbackMediaType, "episode")
        XCTAssertEqual(episode.playableMovie.showId, "42")
    }

    func testWatchlistAddUsesCatalogActionBody() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/v1/catalog/watchlist")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
            let body = try XCTUnwrap(request.httpBody)
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertEqual(json?["media_type"] as? String, "movie")
            XCTAssertEqual(json?["media_id"] as? String, "42")
            return (
                HTTPURLResponse(url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }
        defer { MockURLProtocol.handler = nil }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let client = URLSessionLuminaAPIClient(
            baseURL: URL(string: "https://lumina.example.test")!,
            session: URLSession(configuration: configuration)
        )

        try await client.setWatchlisted(mediaType: "movie", mediaId: "42", isWatchlisted: true, token: "token")
    }

    func testFavoriteRemoveUsesCatalogActionQuery() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            XCTAssertEqual(request.url?.path, "/api/v1/catalog/favorites")
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            XCTAssertEqual(components?.queryItems?.first { $0.name == "media_type" }?.value, "tv_show")
            XCTAssertEqual(components?.queryItems?.first { $0.name == "media_id" }?.value, "show-7")
            XCTAssertNil(request.httpBody)
            return (
                HTTPURLResponse(url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }
        defer { MockURLProtocol.handler = nil }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let client = URLSessionLuminaAPIClient(
            baseURL: URL(string: "https://lumina.example.test")!,
            session: URLSession(configuration: configuration)
        )

        try await client.setFavorite(mediaType: "tv_show", mediaId: "show-7", isFavorite: false, token: "token")
    }

    func testHLSManifestInspectionCountsMediaRenditions() {
        let manifest = """
        #EXTM3U
        #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="English",DEFAULT=YES,URI="audio/audio-1.m3u8"
        #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="French",DEFAULT=NO,URI="subtitles/subtitle-3.m3u8"
        #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English CC",DEFAULT=NO,URI="/api/v1/playback/movies/42/subtitles/11"
        #EXT-X-STREAM-INF:BANDWIDTH=2000000,AUDIO="audio",SUBTITLES="subs"
        variant.m3u8
        """

        let inspection = URLSessionLuminaAPIClient.inspectHLSManifest(manifest)

        XCTAssertEqual(inspection.audioRenditionCount, 1)
        XCTAssertEqual(inspection.subtitleRenditionCount, 2)
        XCTAssertEqual(inspection.nonPlaylistSubtitleRenditionCount, 1)
    }

    func testBackendAuthErrorMapsToSafeServerError() throws {
        let json = """
        {
          "error": "Unauthorized",
          "message": "Invalid email or password"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(BackendErrorResponse.self, from: json)

        XCTAssertEqual(response.error, "Unauthorized")
        XCTAssertEqual(response.message, "Invalid email or password")
    }

    func testDiagnosticsRedactsSensitiveValues() {
        let message = """
        Authorization=Bearer abc.def.ghi password=hunter2 path=/Users/example/private file=file:///private/var/mobile/app.db json={"access_token":"secret","password":"hunter2"} url=https://server/hls.m3u8?stream_token=secret
        SELECT * FROM users WHERE email='private@example.test'
        Thread 1: Fatal error: backend stack trace
        #0 private symbol
        Command line invocation:
            raw subprocess output
        """
        let redacted = DiagnosticsRecorder.redact(message)

        XCTAssertFalse(redacted.contains("abc.def.ghi"))
        XCTAssertFalse(redacted.contains("hunter2"))
        XCTAssertFalse(redacted.contains("/Users/example"))
        XCTAssertFalse(redacted.contains("/private/var"))
        XCTAssertFalse(redacted.contains("access_token"))
        XCTAssertFalse(redacted.contains("stream_token=secret"))
        XCTAssertFalse(redacted.localizedCaseInsensitiveContains("select"))
        XCTAssertFalse(redacted.contains("Thread 1"))
        XCTAssertFalse(redacted.contains("#0"))
        XCTAssertFalse(redacted.contains("raw subprocess output"))
    }

    func testDiagnosticsRecordsStructuredSafeServerError() {
        let recorder = DiagnosticsRecorder()
        let error = LuminaClientError.server(
            LuminaErrorEnvelope.Body(
                code: "STREAM_TOKEN_EXPIRED",
                category: "stream_token",
                safeMessage: "The playback link expired. Try playing again.",
                retryable: true,
                correlationId: "req_123",
                details: nil
            )
        )

        recorder.record(error: error, operation: "load_playback_proof", phase: .playback, routeKey: "streamToken", statusCode: 410)

        XCTAssertEqual(recorder.events.count, 1)
        XCTAssertEqual(recorder.events.first?.operation, "load_playback_proof")
        XCTAssertEqual(recorder.events.first?.phase, .playback)
        XCTAssertEqual(recorder.events.first?.severity, .error)
        XCTAssertEqual(recorder.events.first?.category, "stream_token")
        XCTAssertEqual(recorder.events.first?.routeKey, "streamToken")
        XCTAssertEqual(recorder.events.first?.statusCode, 410)
        XCTAssertEqual(recorder.events.first?.correlationId, "req_123")
        XCTAssertEqual(recorder.events.first?.supportId, "req_123")
        XCTAssertEqual(recorder.events.first?.message, "The playback link expired. Try playing again.")
    }

    @MainActor
    func testSupportSummaryShowsSafeLocalSupportContext() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let recorder = DiagnosticsRecorder()
        recorder.record(
            operation: "load_playback_proof",
            phase: .playback,
            severity: .error,
            category: "stream_token",
            routeKey: "streamToken",
            statusCode: 410,
            correlationId: "req_123",
            message: "Authorization: Bearer abc.def.ghi at /Users/martin/private"
        )
        let model = AppModel(
            tokenStore: InMemoryTokenStore(),
            settingsStore: InMemoryServerSettingsStore(serverURLString: "https://lumina.example.test"),
            diagnostics: recorder,
            apiClientFactory: { _, _ in FakeLuminaAPIClient(capabilities: capabilities) },
            serverConnectionTester: FakeServerConnectionTester(capabilities: capabilities)
        )
        model.capabilities = capabilities
        model.currentUser = LuminaUser(id: "1", displayName: "Martin")

        let summary = model.supportSummary

        XCTAssertTrue(summary.serverSummary.contains("Lumina"))
        XCTAssertEqual(summary.validationSummary, "Compatible")
        XCTAssertEqual(summary.userDisplayName, "Martin")
        XCTAssertTrue(summary.diagnosticsSummary.contains("1 events"))
        XCTAssertEqual(summary.lastSupportId, "req_123")
        XCTAssertFalse(summary.lastSafeError.contains("abc.def.ghi"))
        XCTAssertFalse(summary.lastSafeError.contains("/Users/martin/private"))
    }

    func testURLSessionClientDefaultConfigurationIsExplicitForTV() {
        let session = URLSessionLuminaAPIClient.makeDefaultSession()
        let configuration = session.configuration

        XCTAssertEqual(configuration.timeoutIntervalForRequest, URLSessionLuminaAPIClient.requestTimeout)
        XCTAssertEqual(configuration.timeoutIntervalForResource, URLSessionLuminaAPIClient.resourceTimeout)
        XCTAssertEqual(configuration.requestCachePolicy, .reloadIgnoringLocalCacheData)
        XCTAssertFalse(configuration.waitsForConnectivity)
        XCTAssertEqual(configuration.urlCache?.memoryCapacity, 8 * 1024 * 1024)
        XCTAssertEqual(configuration.urlCache?.diskCapacity, 32 * 1024 * 1024)
    }

    func testCapabilities404ExplainsMissingRoute() {
        let error = LuminaClientError.fromHTTPStatus(404, path: "/api/v1/system/capabilities")

        XCTAssertEqual(
            error.safeMessage,
            "Server reached, but Lumina capabilities are missing. Add GET /api/v1/system/capabilities to the server."
        )
    }

    func testLogin404ExplainsAttemptedRoute() {
        let error = LuminaClientError.fromHTTPStatus(404, path: "/api/v1/auth/login")

        XCTAssertEqual(
            error.safeMessage,
            "Server reached, but the login route was not found. The app tried /api/v1/auth/login."
        )
    }

    func testUnauthorizedAndForbiddenExpireSession() {
        XCTAssertEqual(LuminaClientError.fromHTTPStatus(401, path: "/api/v1/auth/me"), .sessionExpired)
        XCTAssertEqual(LuminaClientError.fromHTTPStatus(403, path: "/api/v1/auth/me"), .sessionExpired)
    }

    @MainActor
    func testServerURLNormalizationDefaultsToHTTPS() {
        let model = AppModel(tokenStore: InMemoryTokenStore())

        XCTAssertEqual(model.normalizeServerURL("lumina.local:3000")?.absoluteString, "http://lumina.local:3000")
        XCTAssertEqual(model.normalizeServerURL("https://lumina.example.test")?.absoluteString, "https://lumina.example.test")
        XCTAssertNil(model.normalizeServerURL(" "))
    }

    @MainActor
    func testAppModelSignInStoresSessionAndLoadsCatalog() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let tokenStore = InMemoryTokenStore()
        let settingsStore = InMemoryServerSettingsStore()
        let hero = CatalogItem(id: "hero", title: "Hero")
        let client = FakeLuminaAPIClient(
            capabilities: capabilities,
            loginResponse: LoginResponse(accessToken: "session-token", user: LuminaUser(id: "1", displayName: "Martin")),
            user: LuminaUser(id: "1", displayName: "Martin"),
            catalogHome: try catalogHomeFixture(hero: hero),
            movies: [CatalogItem(id: "movie", title: "Movie")],
            tvShows: [CatalogItem(id: "show", mediaType: "tv_show", title: "Show")]
        )
        let model = AppModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: { _, _ in client },
            serverConnectionTester: FakeServerConnectionTester(capabilities: capabilities)
        )
        model.serverURLString = "lumina.example.test"
        model.email = "martin@example.test"
        model.password = "secret"

        await model.signIn()

        XCTAssertEqual(model.phase, .home)
        XCTAssertEqual(model.currentUser?.displayName, "Martin")
        XCTAssertEqual(try tokenStore.loadToken(), "session-token")
        XCTAssertEqual(settingsStore.serverURLString, "http://lumina.example.test")
        XCTAssertEqual(model.homeHeroItems, [hero])
        XCTAssertEqual(model.movies.first?.id, "movie")
        XCTAssertEqual(model.password, "")
    }

    @MainActor
    func testAppModelRestoreSessionExpiredClearsTokenAndReturnsToSignIn() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let tokenStore = InMemoryTokenStore()
        try tokenStore.saveToken("expired-token")
        let settingsStore = InMemoryServerSettingsStore(serverURLString: "https://lumina.example.test")
        let client = FakeLuminaAPIClient(
            capabilities: capabilities,
            currentUserError: .sessionExpired
        )
        let model = AppModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: { _, _ in client },
            serverConnectionTester: FakeServerConnectionTester(capabilities: capabilities)
        )

        await model.restoreSession()

        XCTAssertEqual(model.phase, .signIn)
        XCTAssertEqual(model.statusMessage, LuminaClientError.sessionExpired.safeMessage)
        XCTAssertNil(try tokenStore.loadToken())
        XCTAssertNil(model.currentUser)
    }

    @MainActor
    func testAppModelSignInMapsTokenStoreFailureToSafeMessage() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let tokenStore = FailingTokenStore(error: TokenStoreError.unexpectedStatus(errSecMissingEntitlement))
        let settingsStore = InMemoryServerSettingsStore()
        let client = FakeLuminaAPIClient(
            capabilities: capabilities,
            loginResponse: LoginResponse(accessToken: "session-token", user: LuminaUser(id: "1", displayName: "Martin")),
            user: LuminaUser(id: "1", displayName: "Martin")
        )
        let model = AppModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: { _, _ in client },
            serverConnectionTester: FakeServerConnectionTester(capabilities: capabilities)
        )
        model.serverURLString = "lumina.example.test"
        model.email = "martin@example.test"
        model.password = "secret"

        await model.signIn()

        XCTAssertEqual(model.phase, .signIn)
        XCTAssertEqual(model.statusMessage, LuminaClientError.secureStorageUnavailable.safeMessage)
        XCTAssertFalse(model.statusMessage?.contains("TokenStoreError") ?? true)
    }

    @MainActor
    func testAppModelRestoreShowsServerUnavailableWithoutClearingSavedServer() async throws {
        let tokenStore = InMemoryTokenStore()
        let settingsStore = InMemoryServerSettingsStore(serverURLString: "http://lumina.example.test")
        let model = AppModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            serverConnectionTester: FakeServerConnectionTester(error: .transport("Server offline."))
        )

        await model.restoreSession()

        XCTAssertEqual(model.phase, .serverUnavailable)
        XCTAssertEqual(model.statusMessage, "Server offline.")
        XCTAssertEqual(settingsStore.serverURLString, "http://lumina.example.test")
    }

    func testTokenStoreErrorHasUserSafeDescription() {
        XCTAssertEqual(
            TokenStoreError.unexpectedStatus(errSecMissingEntitlement).localizedDescription,
            "Secure token storage is unavailable."
        )
    }

    func testFallbackTokenStoreUsesMemoryWhenPrimaryFails() throws {
        let store = FallbackTokenStore(
            primary: FailingTokenStore(error: TokenStoreError.unexpectedStatus(errSecMissingEntitlement)),
            fallback: InMemoryTokenStore()
        )

        try store.saveToken("simulator-token")

        XCTAssertEqual(try store.loadToken(), "simulator-token")

        try store.clearToken()

        XCTAssertNil(try store.loadToken())
    }

    func testCatalogRepositoryBuildsHomeSnapshot() async throws {
        let hero = CatalogItem(id: "hero", title: "Hero")
        let sectionItem = CatalogItem(id: "fallback", title: "Fallback")
        let movie = CatalogItem(id: "movie", title: "Movie")
        let show = CatalogItem(id: "show", mediaType: "tv_show", title: "Show")
        let catalogHome = try JSONDecoder().decode(
            CatalogHomeResponse.self,
            from: """
            {
              "hero": {
                "items": [{"id": "hero", "title": "Hero", "media_type": "movie"}]
              },
              "sections": [
                {
                  "id": "continue",
                  "title": "Continue",
                  "items": [{"id": "fallback", "title": "Fallback", "media_type": "movie"}]
                }
              ]
            }
            """.data(using: .utf8)!
        )
        let client = FakeLuminaAPIClient(
            catalogHome: catalogHome,
            movies: [movie],
            tvShows: [show]
        )
        let repository = CatalogRepository(client: client, token: "token")

        let snapshot = try await repository.loadHome()

        XCTAssertEqual(snapshot.heroItems, [hero])
        XCTAssertEqual(snapshot.sections.first?.items, [sectionItem])
        XCTAssertEqual(snapshot.movies, [movie])
        XCTAssertEqual(snapshot.tvShows, [show])
    }

    func testCatalogRepositoryFetchesEditorialSection() async throws {
        let editorialSection = CatalogSection(
            id: "sci_fi_epics",
            title: "Sci-Fi Epics",
            type: "catalog_row",
            mediaType: "movie",
            eyebrow: "Journey's Beyond Imagination",
            subtitle: "Epic worlds. Infinite possibilities.",
            tags: ["Space Opera"],
            items: [CatalogItem(id: "movie", title: "Arrival")]
        )
        let client = FakeLuminaAPIClient(editorialSection: editorialSection)
        let repository = CatalogRepository(client: client, token: "token")

        let section = try await repository.editorialSection(sectionId: "sci_fi_epics")

        XCTAssertEqual(section.id, "sci_fi_epics")
        XCTAssertEqual(section.eyebrow, "Journey's Beyond Imagination")
        XCTAssertEqual(section.items.first?.title, "Arrival")
    }

    func testCatalogRepositoryBuildsTVShowDetailWithFirstSeasonEpisodes() async throws {
        let show = CatalogItem(id: "show-1", mediaType: "tv_show", title: "The Show")
        let season = try JSONDecoder().decode(
            TVSeasonSummary.self,
            from: #"{"season_number":2,"title":"Season 2"}"#.data(using: .utf8)!
        )
        let episode = CatalogItem(id: "episode-1", mediaType: "episode", title: "Episode")
        let client = FakeLuminaAPIClient(
            tvShowDetail: show,
            tvSeasons: [season],
            tvEpisodes: [episode]
        )
        let repository = CatalogRepository(client: client, token: "token")

        let snapshot = try await repository.tvShowDetail(showId: "show-1")

        XCTAssertEqual(snapshot.show, show)
        XCTAssertEqual(snapshot.seasons, [season])
        XCTAssertEqual(snapshot.selectedSeasonNumber, 2)
        XCTAssertEqual(snapshot.episodes, [episode])
    }

    @MainActor
    func testCatalogStateModelIgnoresStaleSearchResults() {
        let state = CatalogStateModel()
        state.searchQuery = "first"
        let first = state.beginSearch()
        state.searchQuery = "second"
        let second = state.beginSearch()
        let staleResult = CatalogItem(id: "stale", title: "Stale")
        let freshResult = CatalogItem(id: "fresh", title: "Fresh")

        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
        XCTAssertFalse(state.completeSearch(loadID: first!.loadID, results: [staleResult]))
        XCTAssertTrue(state.searchResults.isEmpty)
        XCTAssertTrue(state.completeSearch(loadID: second!.loadID, results: [freshResult]))
        XCTAssertEqual(state.searchResults, [freshResult])
        XCTAssertFalse(state.isCatalogLoading)
    }

    @MainActor
    func testCatalogStateModelResetInvalidatesDetailAndEditorialLoads() {
        let state = CatalogStateModel()
        let detailLoadID = state.beginDetail(CatalogItem(id: "movie", title: "Movie"))
        let editorialLoadID = state.beginEditorial(CatalogSection(id: "section", title: "Section"))

        state.reset()

        XCTAssertFalse(state.applyMovieDetail(loadID: detailLoadID, item: CatalogItem(id: "late", title: "Late")))
        XCTAssertFalse(state.completeEditorial(loadID: editorialLoadID, section: CatalogSection(id: "late-section", title: "Late")))
        XCTAssertNil(state.selectedCatalogItem)
        XCTAssertNil(state.selectedEditorialSection)
        XCTAssertFalse(state.isDetailLoading)
        XCTAssertFalse(state.isEditorialLoading)
    }

    @MainActor
    func testPlaybackStateModelIgnoresLateProofAndRedactsFailure() {
        let recorder = DiagnosticsRecorder()
        let state = PlaybackStateModel(playbackProofLoader: PlaybackProofLoader(), diagnostics: recorder)
        let firstLoadID = state.beginLoad()
        _ = state.beginLoad()
        let proof = PlaybackProof(
            movie: PlayableMovie(id: "movie", title: "Movie"),
            streamURL: URL(string: "https://lumina.example.test/movie.m3u8?token=secret")!,
            authorizationHeader: nil,
            sessionId: nil,
            tracks: nil,
            manifestInspection: nil
        )
        let result = PlaybackProofLoadResult(proof: proof, resumePositionSeconds: 0, session: nil)

        XCTAssertFalse(state.applyLoadedProof(result, loadID: firstLoadID))
        XCTAssertNil(state.playbackProof)

        let safeMessage = state.recordFailure("Authorization: Bearer abc.def.ghi at /Users/martin/private")

        XCTAssertFalse(safeMessage.contains("abc.def.ghi"))
        XCTAssertFalse(safeMessage.contains("/Users/martin/private"))
        XCTAssertEqual(recorder.events.first?.operation, "avkit_playback")
    }

    func testPlaybackProofLoaderPropagatesSessionExpiredFromProgress() async throws {
        let client = PlaybackProofFakeClient(movieProgressError: .sessionExpired)
        let loader = PlaybackProofLoader()

        do {
            _ = try await loader.loadMovieProof(movieOverride: nil, token: "token", client: client)
            XCTFail("Expected session expiration to propagate")
        } catch let error as LuminaClientError {
            XCTAssertEqual(error, .sessionExpired)
        }
    }

    func testPlaybackProofLoaderStopsCreatedSessionWhenPreflightFails() async throws {
        let client = PlaybackProofFakeClient(
            playbackSession: PlaybackSessionResponse(id: "session-1", mediaId: "movie", mediaKind: "movie"),
            preflightError: .transport("Manifest request returned HTTP 410.")
        )
        let loader = PlaybackProofLoader()

        do {
            _ = try await loader.loadMovieProof(movieOverride: nil, token: "token", client: client)
            XCTFail("Expected preflight failure")
        } catch let error as LuminaClientError {
            XCTAssertEqual(error.safeMessage, "Manifest request returned HTTP 410.")
        }

        XCTAssertEqual(client.stoppedSessionIds, ["session-1"])
        XCTAssertEqual(client.stoppedPositionSeconds, [123])
    }

    func testPlaybackProofLoaderStopsBeforeStreamTokenWhenMovieIsNotPlayable() async throws {
        let client = PlaybackProofFakeClient(
            playbackSession: PlaybackSessionResponse(id: "session-1", mediaId: "movie", mediaKind: "movie")
        )
        client.playableMovie = PlayableMovie(
            id: "movie",
            title: "Movie",
            resumePositionSeconds: 123,
            durationSeconds: 3600,
            hlsManifestPath: nil,
            hasPlayableMedia: false
        )
        let loader = PlaybackProofLoader()

        do {
            _ = try await loader.loadMovieProof(movieOverride: nil, token: "token", client: client)
            XCTFail("Expected missing playable media failure")
        } catch let error as LuminaClientError {
            XCTAssertEqual(error.safeMessage, "No playable movie was found on this Lumina server.")
        }

        XCTAssertEqual(client.streamTokenRequestCount, 0)
        XCTAssertEqual(client.stoppedSessionIds, [])
    }

    func testPlaybackProofLoaderCarriesMovieTracksWhenAvailable() async throws {
        let tracksJSON = """
        {
          "tracks": {
            "audio": [
              {
                "source_index": 1,
                "source_kind": "embedded",
                "track_type": "audio",
                "codec": "aac",
                "language": "eng",
                "title": "English",
                "channels": 2,
                "is_default": true,
                "is_forced": false,
                "delivery_mode": "hls_audio"
              }
            ],
            "subtitles": {
              "embedded": [],
              "external": [
                {
                  "id": 11,
                  "source_kind": "external",
                  "format": "vtt",
                  "language": "eng",
                  "title": "English CC",
                  "is_default": false,
                  "is_forced": false,
                  "deliverable": true,
                  "delivery_mode": "external_file"
                }
              ]
            }
          },
          "probe": {"status": "ok", "error": null, "updated_at": "2026-06-06T10:00:00.000Z"},
          "subtitle_probe": {"status": "ok", "error": null, "updated_at": "2026-06-06T10:00:00.000Z"}
        }
        """.data(using: .utf8)!
        let client = PlaybackProofFakeClient(
            playbackSession: PlaybackSessionResponse(id: "session-1", mediaId: "movie", mediaKind: "movie")
        )
        client.movieTracks = try JSONDecoder().decode(MediaTrackListing.self, from: tracksJSON)
        client.manifestInspection = HLSManifestInspection(
            audioRenditionCount: 1,
            subtitleRenditionCount: 1,
            nonPlaylistSubtitleRenditionCount: 1,
            checkedVariantPlaylist: true,
            checkedFirstSegment: true
        )
        let loader = PlaybackProofLoader()

        let result = try await loader.loadMovieProof(movieOverride: nil, token: "token", client: client)

        XCTAssertEqual(result.proof.tracks?.tracks.audio.first?.language, "eng")
        XCTAssertEqual(result.proof.tracks?.tracks.subtitles.external.first?.id, "11")
        XCTAssertEqual(result.proof.manifestInspection?.audioRenditionCount, 1)
        XCTAssertEqual(result.proof.manifestInspection?.nonPlaylistSubtitleRenditionCount, 1)
    }

    @MainActor
    func testAppModelPlaybackExitPreservesProofUntilFinalStop() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let tokenStore = InMemoryTokenStore()
        try tokenStore.saveToken("session-token")
        let settingsStore = InMemoryServerSettingsStore(serverURLString: "https://lumina.example.test")
        let client = PlaybackProofFakeClient(
            playbackSession: PlaybackSessionResponse(id: "session-1", mediaId: "movie", mediaKind: "movie")
        )
        let model = AppModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: { _, _ in client },
            serverConnectionTester: FakeServerConnectionTester(capabilities: capabilities)
        )
        model.serverURLString = "https://lumina.example.test"
        model.phase = .home

        await model.loadPlaybackProof()

        guard case .playback = model.phase else {
            XCTFail("Expected playback phase after proof load")
            return
        }
        XCTAssertNotNil(model.playbackProof)

        model.requestPlaybackExit()

        XCTAssertEqual(model.phase, .home)
        XCTAssertNotNil(model.playbackProof)

        await model.finishPlayback(positionSeconds: 240, event: "exit")

        XCTAssertNil(model.playbackProof)
        XCTAssertEqual(model.phase, .home)
        XCTAssertEqual(client.progressUpdates.first?.positionSeconds, 240)
        XCTAssertEqual(client.progressUpdates.first?.playState, "paused")
        XCTAssertEqual(client.stoppedSessionIds, ["session-1"])
        XCTAssertEqual(client.stoppedPositionSeconds, [240])
    }

    @MainActor
    func testAppModelFinishPlaybackReturnsToSignInWhenProgressTokenExpires() async throws {
        let capabilities = try decodeFixture(ServerCapabilities.self, name: "capabilities-supported")
        let tokenStore = InMemoryTokenStore()
        try tokenStore.saveToken("session-token")
        let settingsStore = InMemoryServerSettingsStore(serverURLString: "https://lumina.example.test")
        let client = PlaybackProofFakeClient(
            playbackSession: PlaybackSessionResponse(id: "session-1", mediaId: "movie", mediaKind: "movie")
        )
        client.progressReportError = .sessionExpired
        let model = AppModel(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: { _, _ in client },
            serverConnectionTester: FakeServerConnectionTester(capabilities: capabilities)
        )
        model.serverURLString = "https://lumina.example.test"
        model.phase = .home

        await model.loadPlaybackProof()
        await model.finishPlayback(positionSeconds: 240, event: "exit")

        XCTAssertNil(model.playbackProof)
        XCTAssertEqual(model.phase, .signIn)
        XCTAssertThrowsError(try tokenStore.loadToken())
    }

    private func decodeFixture<T: Decodable>(_ type: T.Type, name: String) throws -> T {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func encodedJSONObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func catalogHomeFixture(hero: CatalogItem) throws -> CatalogHomeResponse {
        let json = """
        {
          "hero": {
            "items": [{"id": "\(hero.id)", "title": "\(hero.title)", "media_type": "\(hero.mediaType)"}]
          },
          "sections": []
        }
        """.data(using: .utf8)!
        return try JSONDecoder().decode(CatalogHomeResponse.self, from: json)
    }

    private func section(layout: String?) -> CatalogSection {
        CatalogSection(
            id: layout ?? "fallback",
            title: "Section",
            presentation: CatalogPresentation(
                layout: layout,
                emphasis: nil,
                theme: nil,
                autoplay: nil,
                viewAll: nil
            )
        )
    }
}

private final class InMemoryServerSettingsStore: ServerSettingsStore {
    var serverURLString: String?

    init(serverURLString: String? = nil) {
        self.serverURLString = serverURLString
    }
}

private final class FailingTokenStore: TokenStore {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    func loadToken() throws -> String? {
        throw error
    }

    func saveToken(_ token: String) throws {
        throw error
    }

    func clearToken() throws {
        throw error
    }
}

private final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: LuminaClientError.transport("missing mock handler"))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private struct FakeServerConnectionTester: ServerConnectionTesting {
    var capabilities: ServerCapabilities?
    var error: LuminaClientError?

    func validateServer(baseURL: URL) async throws -> ServerCapabilities {
        if let error {
            throw error
        }
        guard let capabilities else {
            throw LuminaClientError.unsupportedServer
        }
        return capabilities
    }

    func fetchHealth(baseURL: URL) async throws -> LuminaHealthResponse {
        if let error {
            throw error
        }
        return LuminaHealthResponse(status: "ok", app: "Lumina", version: "1.0.0")
    }
}

private final class PlaybackProofFakeClient: LuminaAPIClient {
    var playableMovie = PlayableMovie(
        id: "movie",
        title: "Movie",
        resumePositionSeconds: 123,
        durationSeconds: 3600,
        hlsManifestPath: nil,
        hasPlayableMedia: true
    )
    var movieProgress = MovieProgressResponse(positionSeconds: 123, durationSeconds: 3600, playState: "paused")
    var movieTracks: MediaTrackListing?
    var movieProgressError: LuminaClientError?
    var progressReportError: LuminaClientError?
    var playbackSession: PlaybackSessionResponse?
    var preflightError: LuminaClientError?
    var manifestInspection = HLSManifestInspection(
        audioRenditionCount: 0,
        subtitleRenditionCount: 0,
        nonPlaylistSubtitleRenditionCount: 0,
        checkedVariantPlaylist: true,
        checkedFirstSegment: true
    )
    var progressUpdates: [ProgressUpdateRequest] = []
    var updatedSessionEvents: [(sessionId: String, positionSeconds: Double, playState: String)] = []
    var streamTokenRequestCount = 0
    var stoppedSessionIds: [String] = []
    var stoppedPositionSeconds: [Double] = []

    init(
        movieProgressError: LuminaClientError? = nil,
        playbackSession: PlaybackSessionResponse? = nil,
        preflightError: LuminaClientError? = nil
    ) {
        self.movieProgressError = movieProgressError
        self.playbackSession = playbackSession
        self.preflightError = preflightError
    }

    func fetchCapabilities() async throws -> ServerCapabilities {
        throw LuminaClientError.unsupportedServer
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        throw LuminaClientError.missingToken
    }

    func currentUser(token: String) async throws -> LuminaUser {
        throw LuminaClientError.missingToken
    }

    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse {
        CatalogHomeResponse(hero: nil, sections: [])
    }

    func fetchEditorialSection(sectionId: String, token: String) async throws -> CatalogSection {
        CatalogSection(id: sectionId, title: "Editorial")
    }

    func fetchMovies(token: String) async throws -> [CatalogItem] {
        []
    }

    func fetchTVShows(token: String) async throws -> [CatalogItem] {
        []
    }

    func searchCatalog(query: String, token: String) async throws -> [CatalogItem] {
        []
    }

    func fetchMovieDetail(movieId: String, token: String) async throws -> CatalogItem {
        throw LuminaClientError.decoding
    }

    func fetchTVShowDetail(showId: String, token: String) async throws -> CatalogItem {
        throw LuminaClientError.decoding
    }

    func fetchTVSeasons(showId: String, token: String) async throws -> [TVSeasonSummary] {
        []
    }

    func fetchTVEpisodes(showId: String, seasonNumber: Int, token: String) async throws -> [CatalogItem] {
        []
    }

    func setWatchlisted(mediaType: String, mediaId: String, isWatchlisted: Bool, token: String) async throws {}

    func setFavorite(mediaType: String, mediaId: String, isFavorite: Bool, token: String) async throws {}

    func fetchPlayableMovie(token: String) async throws -> PlayableMovie {
        playableMovie
    }

    func fetchMovieProgress(movieId: String, token: String) async throws -> MovieProgressResponse {
        if let movieProgressError {
            throw movieProgressError
        }
        return movieProgress
    }

    func fetchMovieTracks(movieId: String, token: String) async throws -> MediaTrackListing {
        guard let movieTracks else {
            throw LuminaClientError.transport("Track listing endpoint unavailable.")
        }
        return movieTracks
    }

    func fetchEpisodeProgress(showId: String, seasonNumber: Int, episodeNumber: Int, token: String) async throws -> MovieProgressResponse {
        movieProgress
    }

    func fetchEpisodeTracks(showId: String, seasonNumber: Int, episodeNumber: Int, token: String) async throws -> MediaTrackListing {
        guard let movieTracks else {
            throw LuminaClientError.transport("Track listing endpoint unavailable.")
        }
        return movieTracks
    }

    func createPlaybackSession(mediaType: String, mediaId: String, positionSeconds: Double, token: String) async throws -> PlaybackSessionResponse {
        guard let playbackSession else {
            throw LuminaClientError.transport("Playback session endpoint unavailable.")
        }
        return playbackSession
    }

    func requestStreamToken(mediaType: String, mediaId: String, token: String) async throws -> String? {
        streamTokenRequestCount += 1
        return "stream-token"
    }

    func movieHLSManifestURL(movie: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String) -> URL {
        URL(string: "https://lumina.example.test/manifest.m3u8")!
    }

    func episodeHLSManifestURL(episode: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String) throws -> URL {
        URL(string: "https://lumina.example.test/episode-manifest.m3u8")!
    }

    func preflightHLSManifest(url: URL) async throws -> HLSManifestInspection {
        if let preflightError {
            throw preflightError
        }
        return manifestInspection
    }

    func reportProgress(_ update: ProgressUpdateRequest, token: String) async throws {
        if let progressReportError {
            throw progressReportError
        }
        progressUpdates.append(update)
    }

    func updatePlaybackSession(sessionId: String, positionSeconds: Double, playState: String, token: String) async throws {
        updatedSessionEvents.append((sessionId, positionSeconds, playState))
    }

    func stopPlaybackSession(sessionId: String, positionSeconds: Double, token: String) async throws {
        stoppedSessionIds.append(sessionId)
        stoppedPositionSeconds.append(positionSeconds)
    }
}

private struct FakeLuminaAPIClient: LuminaAPIClient {
    var capabilities: ServerCapabilities?
    var loginResponse: LoginResponse?
    var user: LuminaUser?
    var currentUserError: LuminaClientError?
    var catalogHome = CatalogHomeResponse(hero: nil, sections: [])
    var editorialSection: CatalogSection?
    var movies: [CatalogItem] = []
    var tvShows: [CatalogItem] = []
    var searchResults: [CatalogItem] = []
    var movieDetail: CatalogItem?
    var tvShowDetail: CatalogItem?
    var tvSeasons: [TVSeasonSummary] = []
    var tvEpisodes: [CatalogItem] = []
    var playableMovie = PlayableMovie(id: "movie", title: "Movie")
    var movieProgress = MovieProgressResponse(positionSeconds: nil, durationSeconds: nil, playState: nil)
    var movieTracks: MediaTrackListing?
    var playbackSession: PlaybackSessionResponse?
    var streamToken: String?
    var manifestInspection = HLSManifestInspection(
        audioRenditionCount: 0,
        subtitleRenditionCount: 0,
        nonPlaylistSubtitleRenditionCount: 0,
        checkedVariantPlaylist: true,
        checkedFirstSegment: true
    )

    func fetchCapabilities() async throws -> ServerCapabilities {
        guard let capabilities else { throw LuminaClientError.unsupportedServer }
        return capabilities
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        guard let loginResponse else { throw LuminaClientError.missingToken }
        return loginResponse
    }

    func currentUser(token: String) async throws -> LuminaUser {
        if let currentUserError {
            throw currentUserError
        }
        guard let user else { throw LuminaClientError.missingToken }
        return user
    }

    func fetchCatalogHome(token: String) async throws -> CatalogHomeResponse {
        catalogHome
    }

    func fetchEditorialSection(sectionId: String, token: String) async throws -> CatalogSection {
        guard let editorialSection else { throw LuminaClientError.decoding }
        return editorialSection
    }

    func fetchMovies(token: String) async throws -> [CatalogItem] {
        movies
    }

    func fetchTVShows(token: String) async throws -> [CatalogItem] {
        tvShows
    }

    func searchCatalog(query: String, token: String) async throws -> [CatalogItem] {
        searchResults
    }

    func fetchMovieDetail(movieId: String, token: String) async throws -> CatalogItem {
        guard let movieDetail else { throw LuminaClientError.decoding }
        return movieDetail
    }

    func fetchTVShowDetail(showId: String, token: String) async throws -> CatalogItem {
        guard let tvShowDetail else { throw LuminaClientError.decoding }
        return tvShowDetail
    }

    func fetchTVSeasons(showId: String, token: String) async throws -> [TVSeasonSummary] {
        tvSeasons
    }

    func fetchTVEpisodes(showId: String, seasonNumber: Int, token: String) async throws -> [CatalogItem] {
        tvEpisodes
    }

    func setWatchlisted(mediaType: String, mediaId: String, isWatchlisted: Bool, token: String) async throws {}

    func setFavorite(mediaType: String, mediaId: String, isFavorite: Bool, token: String) async throws {}

    func fetchPlayableMovie(token: String) async throws -> PlayableMovie {
        playableMovie
    }

    func fetchMovieProgress(movieId: String, token: String) async throws -> MovieProgressResponse {
        movieProgress
    }

    func fetchMovieTracks(movieId: String, token: String) async throws -> MediaTrackListing {
        guard let movieTracks else { throw LuminaClientError.decoding }
        return movieTracks
    }

    func fetchEpisodeProgress(showId: String, seasonNumber: Int, episodeNumber: Int, token: String) async throws -> MovieProgressResponse {
        movieProgress
    }

    func fetchEpisodeTracks(showId: String, seasonNumber: Int, episodeNumber: Int, token: String) async throws -> MediaTrackListing {
        guard let movieTracks else { throw LuminaClientError.decoding }
        return movieTracks
    }

    func createPlaybackSession(mediaType: String, mediaId: String, positionSeconds: Double, token: String) async throws -> PlaybackSessionResponse {
        guard let playbackSession else { throw LuminaClientError.decoding }
        return playbackSession
    }

    func requestStreamToken(mediaType: String, mediaId: String, token: String) async throws -> String? {
        streamToken
    }

    func movieHLSManifestURL(movie: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String) -> URL {
        URL(string: "https://lumina.example.test/manifest.m3u8")!
    }

    func episodeHLSManifestURL(episode: PlayableMovie, streamToken: String?, sessionId: String?, startTime: Double, quality: String) throws -> URL {
        URL(string: "https://lumina.example.test/episode-manifest.m3u8")!
    }

    func preflightHLSManifest(url: URL) async throws -> HLSManifestInspection {
        manifestInspection
    }

    func reportProgress(_ update: ProgressUpdateRequest, token: String) async throws {}

    func updatePlaybackSession(sessionId: String, positionSeconds: Double, playState: String, token: String) async throws {}

    func stopPlaybackSession(sessionId: String, positionSeconds: Double, token: String) async throws {}
}
