//
//  System.swift
//  lumina
//

import Foundation

struct ServerCapabilities: Codable, Equatable {
    static let supportedAPIVersions: Set<String> = ["2026-05-tv"]

    struct Server: Codable, Equatable {
        let name: String
        let id: String?
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

    struct Discovery: Codable, Equatable {
        let serviceType: String
        let apiPath: String
        let capabilitiesRoute: String
        let secure: Bool
    }

    let server: Server
    let api: API
    let auth: Auth
    let playback: Playback
    let library: Library
    let diagnostics: Diagnostics
    let routes: [String: String]
    let limits: Limits
    let discovery: Discovery?

    var isTvMVPCompatible: Bool {
        Self.supportedAPIVersions.contains(api.version)
        && auth.modes.contains("password_jwt")
        && !auth.sessionValidationRoute.isEmpty
        && playback.hls.movies
        && playback.progress.supported
        && routes["catalogHome"] != nil
        && routes["movieHlsManifest"] != nil
        && (routes["movieProgressUpdate"] != nil || routes["progressUpdate"] != nil)
    }
}
