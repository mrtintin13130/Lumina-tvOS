//
//  Auth.swift
//  lumina
//

import Foundation

struct LuminaUser: Decodable, Equatable, Identifiable {
    let id: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case username
        case email
        case firstname
        case lastname
    }

    init(id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .id))
        }

        if let displayName = try container.decodeIfPresent(String.self, forKey: .displayName), !displayName.isEmpty {
            self.displayName = displayName
            return
        }

        let firstname = try container.decodeIfPresent(String.self, forKey: .firstname)
        let lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
        let fullName = [firstname, lastname]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !fullName.isEmpty {
            displayName = fullName
            return
        }

        displayName = try container.decodeIfPresent(String.self, forKey: .username)
            ?? container.decodeIfPresent(String.self, forKey: .email)
            ?? "Lumina user"
    }
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable, Equatable {
    let accessToken: String
    let user: LuminaUser?

    enum CodingKeys: String, CodingKey {
        case accessToken
        case token
        case user
    }

    init(accessToken: String, user: LuminaUser?) {
        self.accessToken = accessToken
        self.user = user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
            ?? container.decode(String.self, forKey: .token)
        user = try container.decodeIfPresent(LuminaUser.self, forKey: .user)
    }
}

struct BackendErrorResponse: Decodable, Equatable {
    let error: String
    let message: String
}
