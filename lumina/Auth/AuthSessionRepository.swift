//
//  AuthSessionRepository.swift
//  lumina
//

import Foundation

struct AuthSession: Equatable {
    let serverURL: URL
    let token: String
    let capabilities: ServerCapabilities
    let user: LuminaUser
}

struct AuthSessionRepository {
    let tokenStore: TokenStore
    let settingsStore: ServerSettingsStore
    let apiClientFactory: (URL, ServerCapabilities?) -> LuminaAPIClient

    func restore(normalizeServerURL: (String) -> URL?) async throws -> AuthSession? {
        guard let storedServer = settingsStore.serverURLString,
              let serverURL = normalizeServerURL(storedServer) else {
            return nil
        }
        let storedToken: String?
        do {
            storedToken = try tokenStore.loadToken()
        } catch {
            throw LuminaClientError.secureStorageUnavailable
        }
        guard let token = storedToken else {
            return nil
        }
        do {
            let capabilities = try await validateServer(serverURL)
            let user = try await apiClientFactory(serverURL, capabilities).currentUser(token: token)
            return AuthSession(
                serverURL: serverURL,
                token: token,
                capabilities: capabilities,
                user: user
            )
        } catch LuminaClientError.sessionExpired {
            try? tokenStore.clearToken()
            throw LuminaClientError.sessionExpired
        }
    }

    func validateServer(_ serverURL: URL) async throws -> ServerCapabilities {
        let capabilities = try await apiClientFactory(serverURL, nil).fetchCapabilities()
        guard capabilities.isTvMVPCompatible else {
            throw LuminaClientError.unsupportedServer
        }
        settingsStore.serverURLString = serverURL.absoluteString
        return capabilities
    }

    func signIn(serverURL: URL, email: String, password: String) async throws -> AuthSession {
        let capabilities = try await validateServer(serverURL)
        let capabilityClient = apiClientFactory(serverURL, capabilities)
        let response = try await capabilityClient.login(email: email, password: password)
        do {
            try tokenStore.saveToken(response.accessToken)
        } catch {
            throw LuminaClientError.secureStorageUnavailable
        }
        let user = try await currentUser(from: response, token: response.accessToken, client: capabilityClient)
        return AuthSession(
            serverURL: serverURL,
            token: response.accessToken,
            capabilities: capabilities,
            user: user
        )
    }

    func signOut() {
        try? tokenStore.clearToken()
    }

    func token() throws -> String {
        let storedToken: String?
        do {
            storedToken = try tokenStore.loadToken()
        } catch {
            throw LuminaClientError.secureStorageUnavailable
        }
        guard let token = storedToken else {
            throw LuminaClientError.missingToken
        }
        return token
    }

    private func currentUser(
        from response: LoginResponse,
        token: String,
        client: LuminaAPIClient
    ) async throws -> LuminaUser {
        if let user = response.user {
            return user
        }
        do {
            return try await client.currentUser(token: token)
        } catch LuminaClientError.sessionExpired {
            try? tokenStore.clearToken()
            throw LuminaClientError.sessionExpired
        }
    }
}
