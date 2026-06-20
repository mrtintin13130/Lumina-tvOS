//
//  SetupScreens.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct ServerSetupView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var discovery = LuminaServerDiscovery()
    @FocusState private var focusedItem: ServerSetupFocus?

    enum ServerSetupFocus: Hashable {
        case retry
        case serverAddress
        case validate
        case clear
        case email
        case password
        case signIn
        case changeServer
    }

    var body: some View {
        let isServerReady = appModel.capabilities != nil
        let isBusy = appModel.phase == .validating || appModel.phase == .signingIn

        SetupExperienceShell(
            icon: "play.tv.fill",
            eyebrow: L10n.text("Apple TV Setup"),
            title: L10n.text("Connect to Lumina"),
            subtitle: L10n.text("Enter your server address, then sign in with your Lumina account."),
            statusMessage: appModel.statusMessage,
            content: AnyView(
                VStack(alignment: .leading, spacing: 30) {
                    if isServerReady {
                        SignInPanel(
                            focusedItem: $focusedItem,
                            emailFocus: .email,
                            passwordFocus: .password,
                            signInFocus: .signIn,
                            changeServerFocus: .changeServer
                        )
                    } else {
                        ManualServerEntryView(
                            focusedItem: $focusedItem,
                            addressFocus: .serverAddress,
                            validateFocus: .validate
                        )
                        .disabled(appModel.phase == .signingIn)

                        discoveryContent
                    }
                }
            )
        )
        .task {
            if !isServerReady {
                discovery.startSearching()
            }
        }
        .onDisappear {
            discovery.stopSearching()
        }
        .onChange(of: isServerReady) { _, ready in
            if ready {
                discovery.stopSearching()
                focusedItem = .email
            } else if !isBusy {
                discovery.startSearching()
            }
        }
        .defaultFocus(
            $focusedItem,
            isServerReady ? .email : .serverAddress
        )
    }

    @ViewBuilder
    private var discoveryContent: some View {
        if appModel.phase == .validating {
            SetupProgressRow(text: L10n.text("Validating"))
        } else if !discovery.discoveredServers.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                SetupSectionHeader(
                    title: L10n.text("Servers Found"),
                    subtitle: L10n.text("Choose a discovered server or keep the address above.")
                )

                ForEach(discovery.discoveredServers) { server in
                    Button {
                        Task { await appModel.chooseDiscoveredServer(server) }
                    } label: {
                        HStack(spacing: 18) {
                            Image(systemName: "server.rack")
                                .font(.system(size: 36, weight: .semibold))
                                .frame(width: 58)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(server.name)
                                    .font(.system(size: 32, weight: .bold))
                                Text(server.displayAddress)
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.72))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .frame(width: TVLayout.setupFieldWidth, height: 116, alignment: .leading)
                    }
                    .buttonStyle(.card)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 18) {
                if discovery.isSearching {
                    SetupProgressRow(text: L10n.text("Searching for your Lumina server..."))
                } else {
                    Text(L10n.text("No Lumina server found."))
                        .font(.system(size: 29, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.78))
                }

                if let message = discovery.errorMessage {
                    Text(message)
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))
                }

                Button {
                    discovery.startSearching()
                } label: {
                    Label(L10n.text("Retry"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(LuminaActionButtonStyle(size: .compact, isFocused: focusedItem == .retry))
                .focused($focusedItem, equals: .retry)
            }
            .frame(minWidth: TVLayout.setupFieldWidth, maxWidth: TVLayout.setupFieldWidth, minHeight: 118, alignment: .topLeading)
        }
    }
}

struct ManualServerEntryView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var focusedItem: ServerSetupView.ServerSetupFocus?
    let addressFocus: ServerSetupView.ServerSetupFocus
    let validateFocus: ServerSetupView.ServerSetupFocus

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SetupSectionHeader(
                title: L10n.text("Server"),
                subtitle: L10n.text("Use the address your Lumina library uses at home.")
            )

            SetupInputField(
                title: L10n.text("Server Address"),
                systemImage: "network"
            ) {
                TextField("192.168.0.50:3000", text: $appModel.serverURLString)
                    .textFieldStyle(.plain)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .font(.system(size: 32, weight: .semibold))
                    .focused($focusedItem, equals: addressFocus)
                    .onSubmit {
                        Task { await appModel.validateServer() }
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Label(L10n.text("Dictation works well for server addresses."), systemImage: "mic.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))

                if let normalizedServerAddress {
                    Label(normalizedServerAddress, systemImage: "checkmark.circle")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.74))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }

            LuminaActionRow {
                Button {
                    Task { await appModel.validateServer() }
                } label: {
                    Label(appModel.phase == .validating ? L10n.text("Validating") : L10n.text("Validate Server"), systemImage: "checkmark.shield")
                }
                .buttonStyle(LuminaActionButtonStyle(role: .primary, size: .wide, isFocused: focusedItem == validateFocus))
                .disabled(appModel.phase == .validating)
                .focused($focusedItem, equals: validateFocus)

                Button {
                    appModel.resetServer()
                } label: {
                    Label(L10n.text("Clear"), systemImage: "xmark.circle")
                }
                .buttonStyle(LuminaActionButtonStyle(size: .compact, isFocused: focusedItem == .clear))
                .focused($focusedItem, equals: .clear)
            }
        }
    }

    private var normalizedServerAddress: String? {
        guard !appModel.serverURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = appModel.normalizeServerURL(appModel.serverURLString) else {
            return nil
        }
        return L10n.format("Will connect to %@", url.absoluteString)
    }
}

private struct SignInPanel: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var focusedItem: ServerSetupView.ServerSetupFocus?
    let emailFocus: ServerSetupView.ServerSetupFocus
    let passwordFocus: ServerSetupView.ServerSetupFocus
    let signInFocus: ServerSetupView.ServerSetupFocus
    let changeServerFocus: ServerSetupView.ServerSetupFocus

    var body: some View {
        let isSigningIn = appModel.phase == .signingIn

        VStack(alignment: .leading, spacing: 18) {
            SetupSectionHeader(
                title: L10n.text("Sign in to Lumina"),
                subtitle: L10n.text("Use your Lumina account for this server.")
            )

            CurrentServerPill(value: appModel.serverURLString)

            SetupInputField(
                title: L10n.text("Email"),
                systemImage: "envelope.fill"
            ) {
                TextField(L10n.text("Email"), text: $appModel.email)
                    .textFieldStyle(.plain)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .font(.system(size: 32, weight: .semibold))
                    .disabled(isSigningIn)
                    .focused($focusedItem, equals: emailFocus)
            }

            SetupInputField(
                title: L10n.text("Password"),
                systemImage: "lock.fill"
            ) {
                SecureField(L10n.text("Password"), text: $appModel.password)
                    .textFieldStyle(.plain)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .font(.system(size: 32, weight: .semibold))
                    .disabled(isSigningIn)
                    .focused($focusedItem, equals: passwordFocus)
                    .onSubmit {
                        Task { await appModel.signIn() }
                    }
            }

            LuminaActionRow {
                Button {
                    Task { await appModel.signIn() }
                } label: {
                    Label(isSigningIn ? L10n.text("Signing In") : L10n.text("Sign In"), systemImage: "person.badge.key")
                }
                .buttonStyle(LuminaActionButtonStyle(role: .primary, isFocused: focusedItem == signInFocus))
                .disabled(isSigningIn)
                .focused($focusedItem, equals: signInFocus)

                Button {
                    appModel.resetServer()
                } label: {
                    Label(L10n.text("Change Server"), systemImage: "server.rack")
                }
                .buttonStyle(LuminaActionButtonStyle(size: .wide, isFocused: focusedItem == changeServerFocus))
                .disabled(isSigningIn)
                .focused($focusedItem, equals: changeServerFocus)

                if isSigningIn {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text(L10n.text("Signing in..."))
                            .font(.system(size: 29, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.82))
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

struct ServerUnavailableView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedAction: ServerUnavailableFocus?

    private enum ServerUnavailableFocus: Hashable {
        case retry
        case search
        case changeServer
    }

    var body: some View {
        SetupExperienceShell(
            icon: "wifi.exclamationmark",
            eyebrow: L10n.text("Server"),
            title: L10n.text("Server Unavailable"),
            subtitle: L10n.text("Your saved Lumina server could not be reached."),
            statusMessage: appModel.statusMessage,
            content: AnyView(
                VStack(alignment: .leading, spacing: 28) {
                    CurrentServerPill(value: appModel.serverURLString)

                    LuminaActionRow {
                        Button {
                            Task { await appModel.retrySavedServer() }
                        } label: {
                            Label(L10n.text("Retry"), systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(LuminaActionButtonStyle(role: .primary, size: .compact, isFocused: focusedAction == .retry))
                        .focused($focusedAction, equals: .retry)

                        Button {
                            appModel.searchForServer()
                        } label: {
                            Label(L10n.text("Search Servers"), systemImage: "dot.radiowaves.left.and.right")
                        }
                        .buttonStyle(LuminaActionButtonStyle(isFocused: focusedAction == .search))
                        .focused($focusedAction, equals: .search)

                        Button {
                            appModel.resetServer()
                        } label: {
                            Label(L10n.text("Change Server"), systemImage: "server.rack")
                        }
                        .buttonStyle(LuminaActionButtonStyle(isFocused: focusedAction == .changeServer))
                        .focused($focusedAction, equals: .changeServer)
                    }
                }
            )
        )
        .defaultFocus($focusedAction, .retry)
    }
}

private struct SetupExperienceShell: View {
    let icon: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let statusMessage: String?
    let content: AnyView

    var body: some View {
        HStack(alignment: .top, spacing: 96) {
            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 18) {
                    Image(systemName: icon)
                        .font(.system(size: 38, weight: .semibold))
                        .frame(width: 72, height: 72)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.22, green: 0.66, blue: 0.78),
                                    Color(red: 0.88, green: 0.58, blue: 0.26)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18)
                        )

                    Text(eyebrow.uppercased())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white.opacity(0.64))
                }

                Text(title)
                    .font(.system(size: 74, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(subtitle)
                    .font(.system(size: 31, weight: .medium))
                    .foregroundStyle(.white.opacity(0.74))
                    .lineSpacing(4)
                    .lineLimit(3)
                    .frame(maxWidth: 640, alignment: .leading)

                StatusBanner(message: statusMessage)

                Spacer(minLength: 0)
            }
            .frame(width: 650, alignment: .leading)

            VStack(alignment: .leading, spacing: 30) {
                content
            }
            .padding(.horizontal, 42)
            .padding(.vertical, 38)
            .frame(width: 900, alignment: .topLeading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, TVLayout.safeHorizontalPadding)
        .padding(.top, TVLayout.safeTopPadding)
        .padding(.bottom, TVLayout.contentBottomPadding)
    }
}

private struct SetupInputField<Field: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var field: () -> Field

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.white.opacity(0.66))

            field()
                .frame(width: TVLayout.setupFieldWidth, height: 78, alignment: .leading)
                .accessibilityLabel(title)
        }
    }
}

private struct SetupProgressRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            ProgressView()

            Text(text)
                .font(.system(size: 29, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct StatusBanner: View {
    let message: String?

    var body: some View {
        if let message {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 29, weight: .semibold))
                .foregroundStyle(.yellow)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("status-message")
        }
    }
}

private struct SetupSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 34, weight: .bold))
            Text(subtitle)
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(.white.opacity(0.64))
                .lineLimit(2)
        }
    }
}

private struct CurrentServerPill: View {
    let value: String

    var body: some View {
        Label(value, systemImage: "server.rack")
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(.white.opacity(0.82))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 20)
            .frame(minWidth: TVLayout.setupFieldWidth, maxWidth: TVLayout.setupFieldWidth, minHeight: 56, alignment: .leading)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ContractBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.headline)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}
