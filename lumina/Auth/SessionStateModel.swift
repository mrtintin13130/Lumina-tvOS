//
//  SessionStateModel.swift
//  lumina
//

import Foundation

@MainActor
final class SessionStateModel {
    var serverURLString: String
    var email: String = ""
    var password: String = ""
    var statusMessage: String?
    var capabilities: ServerCapabilities?
    var currentUser: LuminaUser?

    private let tokenStore: TokenStore
    private let settingsStore: ServerSettingsStore
    private let apiClientFactory: (URL, ServerCapabilities?) -> LuminaAPIClient
    private let serverConnectionTester: ServerConnectionTesting

    init(
        tokenStore: TokenStore,
        settingsStore: ServerSettingsStore,
        apiClientFactory: @escaping (URL, ServerCapabilities?) -> LuminaAPIClient,
        serverConnectionTester: ServerConnectionTesting
    ) {
        self.tokenStore = tokenStore
        self.settingsStore = settingsStore
        self.apiClientFactory = apiClientFactory
        self.serverConnectionTester = serverConnectionTester
        self.serverURLString = settingsStore.serverURLString ?? ""
    }

    func restore(normalizeServerURL: (String) -> URL?) async throws -> AuthSession? {
        guard let storedServer = settingsStore.serverURLString,
              let storedServerURL = normalizeServerURL(storedServer) else {
            return nil
        }
        serverURLString = storedServerURL.absoluteString
        capabilities = try await serverConnectionTester.validateServer(baseURL: storedServerURL)
        guard let session = try await repository().restore(normalizeServerURL: normalizeServerURL) else {
            return nil
        }
        apply(session)
        statusMessage = nil
        return session
    }

    func validateServer(_ url: URL) async throws {
        let capabilities = try await serverConnectionTester.validateServer(baseURL: url)
        settingsStore.serverURLString = url.absoluteString
        self.capabilities = capabilities
        serverURLString = url.absoluteString
        statusMessage = nil
    }

    func signIn(serverURL: URL) async throws -> AuthSession {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            throw LuminaClientError.transport(L10n.text("Enter your Lumina email and password."))
        }

        let session = try await repository().signIn(
            serverURL: serverURL,
            email: trimmedEmail,
            password: password
        )
        apply(session)
        password = ""
        statusMessage = nil
        return session
    }

    func retrySavedServer() -> Bool {
        guard let storedServer = settingsStore.serverURLString else {
            return false
        }
        serverURLString = storedServer
        return true
    }

    func signOut(message: String? = L10n.text("Signed out.")) {
        repository().signOut()
        currentUser = nil
        password = ""
        statusMessage = message
    }

    func resetServer() {
        try? tokenStore.clearToken()
        settingsStore.serverURLString = nil
        capabilities = nil
        currentUser = nil
        serverURLString = ""
        email = ""
        password = ""
        statusMessage = nil
    }

    func token() throws -> String {
        try repository().token()
    }

    func applySessionError(_ error: LuminaClientError) {
        if error == .sessionExpired || error == .missingToken {
            signOut(message: error.safeMessage)
        } else {
            statusMessage = error.safeMessage
        }
    }

    private func apply(_ session: AuthSession) {
        serverURLString = session.serverURL.absoluteString
        capabilities = session.capabilities
        currentUser = session.user
    }

    private func repository() -> AuthSessionRepository {
        AuthSessionRepository(
            tokenStore: tokenStore,
            settingsStore: settingsStore,
            apiClientFactory: apiClientFactory,
            serverConnectionTester: serverConnectionTester
        )
    }
}
