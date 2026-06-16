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
    @State private var showManualEntry = false
    @FocusState private var focusedItem: ServerSetupFocus?

    enum ServerSetupFocus: Hashable {
        case retry
        case manualToggle
        case serverAddress
        case validate
    }

    var body: some View {
        SetupExperienceShell(
            icon: "play.tv.fill",
            eyebrow: L10n.text("Apple TV Setup"),
            title: L10n.text("Connect to Lumina"),
            subtitle: L10n.text("Choose a discovered server or enter the address your Lumina library uses at home."),
            content: AnyView(
                VStack(alignment: .leading, spacing: 28) {
                    discoveryContent

                    HStack(spacing: 18) {
                        Button {
                            discovery.startSearching()
                        } label: {
                            Label(L10n.text("Retry"), systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .secondary))
                        .focused($focusedItem, equals: .retry)

                        Button {
                            showManualEntry.toggle()
                        } label: {
                            Label(showManualEntry ? L10n.text("Hide Manual Entry") : L10n.text("Add Manually"), systemImage: "keyboard")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .primary))
                        .focused($focusedItem, equals: .manualToggle)
                    }

                    if showManualEntry || discovery.discoveredServers.isEmpty {
                        ManualServerEntryView(
                            focusedItem: $focusedItem,
                            addressFocus: .serverAddress,
                            validateFocus: .validate
                        )
                    }

                    StatusText(message: appModel.statusMessage)
                }
            )
        )
        .task {
            discovery.startSearching()
        }
        .onDisappear {
            discovery.stopSearching()
        }
        .defaultFocus(
            $focusedItem,
            showManualEntry || discovery.discoveredServers.isEmpty ? .serverAddress : .manualToggle
        )
    }

    @ViewBuilder
    private var discoveryContent: some View {
        if appModel.phase == .validating {
            HStack(spacing: 16) {
                ProgressView()
                Text(L10n.text("Validating"))
                    .font(.system(size: 32, weight: .semibold))
            }
            .frame(maxWidth: 820, minHeight: 144, alignment: .leading)
        } else if !discovery.discoveredServers.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.text("Servers Found"))
                    .font(.system(size: 34, weight: .bold))

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
                        .frame(width: 820, height: 124, alignment: .leading)
                    }
                    .buttonStyle(SetupCardButtonStyle())
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 16) {
                    if discovery.isSearching {
                        ProgressView()
                    }

                    Text(discovery.isSearching ? L10n.text("Searching for your Lumina server...") : L10n.text("No Lumina server found."))
                        .font(.system(size: 32, weight: .semibold))
                }

                if let message = discovery.errorMessage {
                    Text(message)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: 820, minHeight: 144, alignment: .leading)
        }
    }
}

struct ManualServerEntryView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var focusedItem: ServerSetupView.ServerSetupFocus?
    let addressFocus: ServerSetupView.ServerSetupFocus
    let validateFocus: ServerSetupView.ServerSetupFocus

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SetupInputField(title: L10n.text("Server Address"), systemImage: "network") {
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
                Text(L10n.text("Tip: Siri dictation works well for server addresses."))
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))

                if let normalizedServerAddress {
                    Label(normalizedServerAddress, systemImage: "checkmark.circle")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.74))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }

            HStack(spacing: 18) {
                Button {
                    Task { await appModel.validateServer() }
                } label: {
                    Label(appModel.phase == .validating ? L10n.text("Validating") : L10n.text("Validate Server"), systemImage: "checkmark.shield")
                }
                .buttonStyle(SetupActionButtonStyle(prominence: .primary))
                .disabled(appModel.phase == .validating)
                .focused($focusedItem, equals: validateFocus)

                Button {
                    appModel.resetServer()
                } label: {
                    Label(L10n.text("Clear"), systemImage: "xmark.circle")
                }
                .buttonStyle(SetupActionButtonStyle(prominence: .secondary))
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
            content: AnyView(
                VStack(alignment: .leading, spacing: 28) {
                    CurrentServerPill(value: appModel.serverURLString)

                    HStack(spacing: 18) {
                        Button {
                            Task { await appModel.retrySavedServer() }
                        } label: {
                            Label(L10n.text("Retry"), systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .primary))
                        .focused($focusedAction, equals: .retry)

                        Button {
                            appModel.searchForServer()
                        } label: {
                            Label(L10n.text("Search Servers"), systemImage: "dot.radiowaves.left.and.right")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .secondary))
                        .focused($focusedAction, equals: .search)

                        Button {
                            appModel.resetServer()
                        } label: {
                            Label(L10n.text("Change Server"), systemImage: "server.rack")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .secondary))
                        .focused($focusedAction, equals: .changeServer)
                    }

                    StatusText(message: appModel.statusMessage)
                }
            )
        )
        .defaultFocus($focusedAction, .retry)
    }
}

struct SignInView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedItem: SignInFocus?

    private enum SignInFocus: Hashable {
        case email
        case password
        case signIn
        case changeServer
    }

    var body: some View {
        let isSigningIn = appModel.phase == .signingIn

        SetupExperienceShell(
            icon: "person.badge.key.fill",
            eyebrow: L10n.text("Secure Sign In"),
            title: L10n.text("Sign in to Lumina"),
            subtitle: L10n.text("Use your Lumina account for this server."),
            content: AnyView(
                VStack(alignment: .leading, spacing: 22) {
                    CurrentServerPill(value: appModel.serverURLString)

                    SetupInputField(title: L10n.text("Email"), systemImage: "envelope.fill") {
                        TextField(L10n.text("Email"), text: $appModel.email)
                            .textFieldStyle(.plain)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .font(.system(size: 32, weight: .semibold))
                            .disabled(isSigningIn)
                            .focused($focusedItem, equals: .email)
                    }

                    SetupInputField(title: L10n.text("Password"), systemImage: "lock.fill") {
                        SecureField(L10n.text("Password"), text: $appModel.password)
                            .textFieldStyle(.plain)
                            .textContentType(.password)
                            .submitLabel(.go)
                            .font(.system(size: 32, weight: .semibold))
                            .disabled(isSigningIn)
                            .focused($focusedItem, equals: .password)
                            .onSubmit {
                                Task { await appModel.signIn() }
                            }
                    }

                    HStack(spacing: 18) {
                        Button {
                            Task { await appModel.signIn() }
                        } label: {
                            Label(isSigningIn ? L10n.text("Signing In") : L10n.text("Sign In"), systemImage: "person.badge.key")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .primary))
                        .disabled(isSigningIn)
                        .focused($focusedItem, equals: .signIn)

                        Button {
                            appModel.resetServer()
                        } label: {
                            Label(L10n.text("Change Server"), systemImage: "server.rack")
                        }
                        .buttonStyle(SetupActionButtonStyle(prominence: .secondary))
                        .disabled(isSigningIn)
                        .focused($focusedItem, equals: .changeServer)

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

                    StatusText(message: isSigningIn ? L10n.text("Signing in...") : appModel.statusMessage)
                }
            )
        )
        .defaultFocus($focusedItem, .email)
    }
}

private struct SetupExperienceShell: View {
    let icon: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let content: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 34) {
            VStack(alignment: .leading, spacing: 18) {
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
                    .font(.system(size: 66, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .font(.system(size: 31, weight: .medium))
                    .foregroundStyle(.white.opacity(0.74))
                    .lineSpacing(4)
                    .lineLimit(3)
                    .frame(maxWidth: 940, alignment: .leading)
            }

            content
        }
        .frame(maxWidth: TVLayout.setupContentMaxWidth, alignment: .leading)
        .padding(.horizontal, TVLayout.safeHorizontalPadding)
        .padding(.vertical, TVLayout.contentBottomPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .padding(.horizontal, 24)
                .frame(width: 820, height: 78, alignment: .leading)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 2)
                }
                .accessibilityLabel(title)
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
            .frame(maxWidth: 820, minHeight: 56, alignment: .leading)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        }
}

private enum SetupActionProminence {
    case primary
    case secondary
}

private struct SetupActionButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused
    let prominence: SetupActionProminence

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 30, weight: .bold))
            .foregroundStyle(foregroundColor)
            .labelStyle(.titleAndIcon)
            .padding(.horizontal, 26)
            .frame(minWidth: 214, minHeight: 72)
            .background(background, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: isFocused ? 4 : 2)
            }
            .scaleEffect(isFocused ? 1.06 : configuration.isPressed ? 0.98 : 1)
            .shadow(color: .black.opacity(isFocused ? 0.36 : 0.18), radius: isFocused ? 24 : 10, y: isFocused ? 14 : 6)
            .animation(.easeOut(duration: 0.16), value: isFocused)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        prominence == .primary ? .black : .white
    }

    private var background: AnyShapeStyle {
        switch prominence {
        case .primary:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white, Color(red: 0.75, green: 0.93, blue: 0.96)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .secondary:
            return AnyShapeStyle(Color.white.opacity(isFocused ? 0.18 : 0.1))
        }
    }

    private var borderColor: Color {
        isFocused ? Color.white.opacity(0.82) : Color.white.opacity(0.16)
    }
}

private struct SetupCardButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .background(Color.white.opacity(isFocused ? 0.17 : 0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isFocused ? Color.white.opacity(0.82) : Color.white.opacity(0.14), lineWidth: isFocused ? 4 : 2)
            }
            .scaleEffect(isFocused ? 1.035 : configuration.isPressed ? 0.985 : 1)
            .shadow(color: .black.opacity(isFocused ? 0.34 : 0.16), radius: isFocused ? 24 : 10, y: isFocused ? 14 : 6)
            .animation(.easeOut(duration: 0.16), value: isFocused)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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
