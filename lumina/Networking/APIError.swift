//
//  APIError.swift
//  lumina
//

import Foundation

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
    case sessionExpired
    case secureStorageUnavailable

    var safeMessage: String {
        switch self {
        case .invalidServerURL:
            return L10n.text("Enter a valid Lumina server URL.")
        case .unsupportedServer:
            return L10n.text("This Lumina server does not support Apple TV playback yet.")
        case .server(let body):
            return DiagnosticsRecorder.redact(body.safeMessage)
        case .transport(let message):
            return message.isEmpty ? L10n.text("The server could not be reached. Check the address and try again.") : DiagnosticsRecorder.redact(message)
        case .decoding:
            return L10n.text("The server response was not compatible with this Apple TV app.")
        case .routeNotFound(let path):
            if path == "/api/v1/system/capabilities" {
                return L10n.text("Server reached, but Lumina capabilities are missing. Add GET /api/v1/system/capabilities to the server.")
            }
            if path.contains("login") {
                return L10n.routeNotFound(path)
            }
            if path.contains("me") {
                return L10n.text("Server reached, but the session route was not found.")
            }
            return L10n.text("Server reached, but the required API route was not found.")
        case .missingToken:
            return L10n.text("Sign in again to continue.")
        case .sessionExpired:
            return L10n.text("Sign in again to continue.")
        case .secureStorageUnavailable:
            return L10n.text("Apple TV secure storage is unavailable. Restart the app and try signing in again.")
        }
    }

    static func fromTransport(_ error: Error) -> LuminaClientError {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
            return .transport(L10n.text("Plain HTTP is blocked by App Transport Security. Allow local networking in the app or use HTTPS."))
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorNotConnectedToInternet {
            return .transport(L10n.text("Apple TV is not connected to the network."))
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCannotConnectToHost {
            return .transport(L10n.text("The Lumina server refused the connection."))
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorTimedOut {
            return .transport(L10n.text("The Lumina server did not respond in time."))
        }
        return .transport(error.localizedDescription)
    }

    static func fromHTTPStatus(_ statusCode: Int, path: String) -> LuminaClientError {
        if statusCode == 401 || statusCode == 403 {
            return .sessionExpired
        }
        if statusCode == 404 {
            return .routeNotFound(path)
        }
        return .transport(L10n.httpStatus(statusCode))
    }
}
