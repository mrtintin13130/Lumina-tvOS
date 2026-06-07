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

enum TokenStoreFactory {
    static func defaultStore() -> TokenStore {
        #if targetEnvironment(simulator)
        return FallbackTokenStore(
            primary: KeychainTokenStore(),
            fallback: InMemoryTokenStore()
        )
        #else
        return KeychainTokenStore()
        #endif
    }
}

enum TokenStoreError: LocalizedError, Equatable {
    case unexpectedStatus(OSStatus)
    case invalidTokenData

    var errorDescription: String? {
        switch self {
        case .unexpectedStatus:
            return L10n.text("Secure token storage is unavailable.")
        case .invalidTokenData:
            return L10n.text("Stored sign-in data could not be read.")
        }
    }
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
        guard status == errSecSuccess else {
            throw TokenStoreError.unexpectedStatus(status)
        }
        guard let data = item as? Data, let token = String(data: data, encoding: .utf8) else {
            throw TokenStoreError.invalidTokenData
        }
        return token
    }

    func saveToken(_ token: String) throws {
        let attributes = [kSecValueData as String: Data(token.utf8)]
        let updateStatus = SecItemUpdate(baseQuery() as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }
        if updateStatus == errSecItemNotFound {
            var item = baseQuery()
            item[kSecValueData as String] = Data(token.utf8)
            item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw TokenStoreError.unexpectedStatus(addStatus)
            }
            return
        }
        throw TokenStoreError.unexpectedStatus(updateStatus)
    }

    func clearToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.unexpectedStatus(status)
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

final class FallbackTokenStore: TokenStore {
    private let primary: TokenStore
    private let fallback: TokenStore
    private var isUsingFallback = false

    init(primary: TokenStore, fallback: TokenStore) {
        self.primary = primary
        self.fallback = fallback
    }

    func loadToken() throws -> String? {
        if isUsingFallback {
            return try fallback.loadToken()
        }
        do {
            return try primary.loadToken()
        } catch {
            isUsingFallback = true
            return try fallback.loadToken()
        }
    }

    func saveToken(_ token: String) throws {
        if isUsingFallback {
            try fallback.saveToken(token)
            return
        }
        do {
            try primary.saveToken(token)
            try? fallback.clearToken()
        } catch {
            isUsingFallback = true
            try fallback.saveToken(token)
        }
    }

    func clearToken() throws {
        let wasUsingFallback = isUsingFallback
        let primaryResult = Result { try primary.clearToken() }
        let fallbackResult = Result { try fallback.clearToken() }
        isUsingFallback = false
        if case .failure(let fallbackError) = fallbackResult {
            throw fallbackError
        }
        if wasUsingFallback {
            return
        }
        if case .failure(let primaryError) = primaryResult {
            throw primaryError
        }
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
