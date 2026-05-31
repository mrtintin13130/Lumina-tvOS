//
//  luminaTests.swift
//  luminaTests
//
//  Created by Martin Thomas on 29/05/2026.
//

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

    func testErrorEnvelopeDecodesSafeMessage() throws {
        let envelope = try decodeFixture(LuminaErrorEnvelope.self, name: "error-envelope-stream-token-expired")

        XCTAssertEqual(envelope.error.category, "stream_token")
        XCTAssertEqual(envelope.error.safeMessage, "The playback link expired. Try playing again.")
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

        XCTAssertEqual(item.id, "8")
        XCTAssertEqual(item.subtitle, "2026")
        XCTAssertEqual(item.posterPath, "/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg")
        XCTAssertEqual(item.backdropPath, "/etfKck6BHfGc4Q9ScDIECjomLYO.jpg")
        XCTAssertEqual(item.progressPercent, 25)
        XCTAssertEqual(item.hasPlayableMedia, true)
    }

    @MainActor
    func testArtworkURLResolvesTMDBAndServerPaths() {
        let model = AppModel(tokenStore: InMemoryTokenStore())
        model.serverURLString = "https://lumina.example.test"

        XCTAssertEqual(
            model.artworkURL(for: "/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg", kind: .poster)?.absoluteString,
            "https://image.tmdb.org/t/p/w500/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg"
        )
        XCTAssertEqual(
            model.artworkURL(for: "/qO55CD8tgVL1T4WKn6zYFFiD6lL.jpg", kind: .backdrop)?.absoluteString,
            "https://image.tmdb.org/t/p/w1280/qO55CD8tgVL1T4WKn6zYFFiD6lL.jpg"
        )
        XCTAssertEqual(
            model.artworkURL(for: "/api/v1/artwork/poster.jpg", kind: .poster)?.absoluteString,
            "https://lumina.example.test/api/v1/artwork/poster.jpg"
        )
        XCTAssertEqual(
            model.artworkURL(for: "https://cdn.example.test/poster.jpg", kind: .poster)?.absoluteString,
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
        let message = "Authorization=Bearer abc.def.ghi password=hunter2 path=/Users/example/private url=https://server/hls.m3u8?stream_token=secret"
        let redacted = DiagnosticsRecorder.redact(message)

        XCTAssertFalse(redacted.contains("abc.def.ghi"))
        XCTAssertFalse(redacted.contains("hunter2"))
        XCTAssertFalse(redacted.contains("/Users/example"))
        XCTAssertFalse(redacted.contains("stream_token=secret"))
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

    @MainActor
    func testServerURLNormalizationDefaultsToHTTPS() {
        let model = AppModel(tokenStore: InMemoryTokenStore())

        XCTAssertEqual(model.normalizeServerURL("lumina.local")?.absoluteString, "https://lumina.local")
        XCTAssertNil(model.normalizeServerURL(" "))
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
}
