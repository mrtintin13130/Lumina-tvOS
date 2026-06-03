//
//  Playback.swift
//  lumina
//

import Foundation

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
