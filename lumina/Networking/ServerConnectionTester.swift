//
//  ServerConnectionTester.swift
//  lumina
//

import Foundation

protocol ServerConnectionTesting {
    func validateServer(baseURL: URL) async throws -> ServerCapabilities
    func fetchHealth(baseURL: URL) async throws -> LuminaHealthResponse
}

struct LuminaHealthResponse: Decodable, Equatable {
    let status: String
    let app: String
    let version: String
}

struct ServerConnectionTester: ServerConnectionTesting {
    let session: URLSession
    let apiClientFactory: (URL, ServerCapabilities?) -> LuminaAPIClient

    init(
        session: URLSession = URLSessionLuminaAPIClient.makeDefaultSession(),
        apiClientFactory: @escaping (URL, ServerCapabilities?) -> LuminaAPIClient = {
            URLSessionLuminaAPIClient(baseURL: $0, capabilities: $1)
        }
    ) {
        self.session = session
        self.apiClientFactory = apiClientFactory
    }

    func validateServer(baseURL: URL) async throws -> ServerCapabilities {
        let health = try await fetchHealth(baseURL: baseURL)
        guard health.status == "ok", health.app == "Lumina", !health.version.isEmpty else {
            throw LuminaClientError.unsupportedServer
        }

        let capabilities = try await apiClientFactory(baseURL, nil).fetchCapabilities()
        guard capabilities.server.name == "Lumina", capabilities.api.version == "v1" else {
            throw LuminaClientError.unsupportedServer
        }
        guard capabilities.isTvMVPCompatible else {
            throw LuminaClientError.unsupportedServer
        }
        return capabilities
    }

    func fetchHealth(baseURL: URL) async throws -> LuminaHealthResponse {
        let url = URL(string: "/api/v1/health", relativeTo: baseURL)?.absoluteURL
            ?? baseURL.appending(path: "/api/v1/health")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = URLSessionLuminaAPIClient.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw LuminaClientError.transport("missing HTTP response")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw LuminaClientError.fromHTTPStatus(http.statusCode, path: "/api/v1/health")
            }
            do {
                return try JSONDecoder().decode(LuminaHealthResponse.self, from: data)
            } catch {
                throw LuminaClientError.decoding
            }
        } catch let error as LuminaClientError {
            throw error
        } catch {
            throw LuminaClientError.fromTransport(error)
        }
    }
}

enum ServerURLNormalizer {
    static func normalize(_ value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let candidate = trimmed.contains("://") ? trimmed : "http://\(trimmed)"
        guard let url = URL(string: candidate), url.host != nil else {
            return nil
        }
        return url
    }
}
