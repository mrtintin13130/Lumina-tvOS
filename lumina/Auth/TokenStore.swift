//
//  TokenStore.swift
//  lumina
//

import Foundation
import Security

protocol TokenStore {
    func loadToken() throws -> String?
    func saveToken(_ token: String) throws
    func clearToken() throws
}

final class KeychainTokenStore: TokenStore {
    private let service = "com.nitramator.lumina.auth"
    private let account = "jwt"

    func loadToken() throws -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = item as? Data else {
            throw LuminaClientError.missingToken
        }
        return String(data: data, encoding: .utf8)
    }

    func saveToken(_ token: String) throws {
        try clearToken()
        var item = baseQuery()
        item[kSecValueData as String] = Data(token.utf8)
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LuminaClientError.missingToken
        }
    }

    func clearToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw LuminaClientError.missingToken
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

final class InMemoryTokenStore: TokenStore {
    private var token: String?

    func loadToken() throws -> String? {
        token
    }

    func saveToken(_ token: String) throws {
        self.token = token
    }

    func clearToken() throws {
        token = nil
    }
}

protocol ServerSettingsStore: AnyObject {
    var serverURLString: String? { get set }
}

final class UserDefaultsServerSettingsStore: ServerSettingsStore {
    private let defaults: UserDefaults
    private let key = "lumina.serverURL"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var serverURLString: String? {
        get { defaults.string(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}
