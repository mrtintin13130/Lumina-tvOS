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
    let tracks: MediaTrackListing?
    let manifestInspection: HLSManifestInspection?
}

struct HLSManifestInspection: Equatable {
    let audioRenditionCount: Int
    let subtitleRenditionCount: Int
    let nonPlaylistSubtitleRenditionCount: Int
    let checkedVariantPlaylist: Bool
    let checkedFirstSegment: Bool
}

struct MediaTrackListing: Decodable, Equatable {
    let tracks: MediaTrackGroups
    let probe: MediaProbeStatus?
    let subtitleProbe: MediaProbeStatus?

    enum CodingKeys: String, CodingKey {
        case tracks
        case probe
        case subtitleProbe = "subtitle_probe"
    }
}

struct MediaTrackGroups: Decodable, Equatable {
    let audio: [MediaTrack]
    let subtitles: MediaSubtitleGroups
}

struct MediaSubtitleGroups: Decodable, Equatable {
    let embedded: [MediaTrack]
    let external: [ExternalSubtitleTrack]
}

struct MediaTrack: Decodable, Equatable {
    let sourceIndex: Int?
    let sourceKind: String?
    let trackType: String?
    let codec: String?
    let language: String?
    let title: String?
    let channels: Int?
    let isDefault: Bool
    let isForced: Bool
    let isHearingImpaired: Bool
    let deliverable: Bool?
    let deliveryMode: String?

    enum CodingKeys: String, CodingKey {
        case sourceIndex = "source_index"
        case sourceKind = "source_kind"
        case trackType = "track_type"
        case codec
        case language
        case title
        case channels
        case isDefault = "is_default"
        case isForced = "is_forced"
        case isHearingImpaired = "is_hearing_impaired"
        case deliverable
        case deliveryMode = "delivery_mode"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sourceIndex = try container.decodeFlexibleIntIfPresent(forKey: .sourceIndex)
        sourceKind = try container.decodeIfPresent(String.self, forKey: .sourceKind)
        trackType = try container.decodeIfPresent(String.self, forKey: .trackType)
        codec = try container.decodeIfPresent(String.self, forKey: .codec)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        channels = try container.decodeFlexibleIntIfPresent(forKey: .channels)
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
        isForced = try container.decodeIfPresent(Bool.self, forKey: .isForced) ?? false
        isHearingImpaired = try container.decodeIfPresent(Bool.self, forKey: .isHearingImpaired) ?? false
        deliverable = try container.decodeIfPresent(Bool.self, forKey: .deliverable)
        deliveryMode = try container.decodeIfPresent(String.self, forKey: .deliveryMode)
    }
}

struct ExternalSubtitleTrack: Decodable, Equatable {
    let id: String
    let sourceKind: String?
    let format: String?
    let language: String?
    let title: String?
    let isDefault: Bool
    let isForced: Bool
    let deliverable: Bool?
    let deliveryMode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sourceKind = "source_kind"
        case format
        case language
        case title
        case isDefault = "is_default"
        case isForced = "is_forced"
        case deliverable
        case deliveryMode = "delivery_mode"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            id = ""
        }
        sourceKind = try container.decodeIfPresent(String.self, forKey: .sourceKind)
        format = try container.decodeIfPresent(String.self, forKey: .format)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
        isForced = try container.decodeIfPresent(Bool.self, forKey: .isForced) ?? false
        deliverable = try container.decodeIfPresent(Bool.self, forKey: .deliverable)
        deliveryMode = try container.decodeIfPresent(String.self, forKey: .deliveryMode)
    }
}

struct MediaProbeStatus: Decodable, Equatable {
    let status: String
    let error: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case status
        case error
        case updatedAt = "updated_at"
    }
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

private extension KeyedDecodingContainer {
    func decodeFlexibleIntIfPresent(forKey key: Key) throws -> Int? {
        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        }
        return nil
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
