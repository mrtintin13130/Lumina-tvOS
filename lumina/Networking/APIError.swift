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
