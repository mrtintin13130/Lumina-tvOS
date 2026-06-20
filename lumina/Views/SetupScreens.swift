//
//  SetupScreens.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

private enum SignInFocus: Hashable {
    case email
    case password
    case signIn
    case discover
    case serverAddress
    case validateServer
    case discoveredServer(String)
}

struct SignInView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var discovery = LuminaServerDiscovery()
    @FocusState private var focusedItem: SignInFocus?

    var body: some View {
        ZStack {
            Image("LoginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.88),
                    .black.opacity(0.58),
                    .black.opacity(0.80)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()

            SetupExperienceShell(
                statusMessage: appModel.statusMessage,
                content: AnyView(
                    SignInPanel(
                        discovery: discovery,
                        focusedItem: $focusedItem,
                        emailFocus: .email,
                        passwordFocus: .password,
                        signInFocus: .signIn,
                        discoverFocus: .discover,
                        serverAddressFocus: .serverAddress,
                        validateServerFocus: .validateServer
                    )
                )
            )
        }
        .defaultFocus($focusedItem, .email)
        .onAppear {
            if !discovery.isSearching && discovery.discoveredServers.isEmpty {
                discovery.startSearching()
            }
        }
        .onDisappear {
            discovery.stopSearching()
        }
    }
}

private struct SignInPanel: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject var discovery: LuminaServerDiscovery
    @FocusState.Binding var focusedItem: SignInFocus?
    let emailFocus: SignInFocus
    let passwordFocus: SignInFocus
    let signInFocus: SignInFocus
    let discoverFocus: SignInFocus
    let serverAddressFocus: SignInFocus
    let validateServerFocus: SignInFocus

    var body: some View {
        let isSigningIn = appModel.phase == .signingIn
        let isValidating = appModel.phase == .validating

        VStack(alignment: .leading, spacing: 22) {
            Text(L10n.text("Sign In").uppercased())
                .font(.system(size: 22, weight: .semibold))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.76))

            NativeSetupTextField(
                title: L10n.text("Email"),
                systemImage: "envelope",
                isFocused: focusedItem == emailFocus
            ) {
                TextField(L10n.text("Email"), text: $appModel.email)
                    .textFieldStyle(.plain)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .font(.system(size: 30, weight: .medium))
                    .disabled(isSigningIn)
                    .focused($focusedItem, equals: emailFocus)
            }

            NativeSetupTextField(
                title: L10n.text("Password"),
                systemImage: "lock",
                isFocused: focusedItem == passwordFocus
            ) {
                SecureField(L10n.text("Password"), text: $appModel.password)
                    .textFieldStyle(.plain)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .font(.system(size: 30, weight: .medium))
                    .disabled(isSigningIn)
                    .focused($focusedItem, equals: passwordFocus)
                    .onSubmit {
                        Task { await appModel.signIn() }
                    }
            }

            Button {
                Task { await appModel.signIn() }
            } label: {
                HStack {
                    Spacer()
                    Text(isSigningIn ? L10n.text("Signing In") : L10n.text("Sign In"))
                    Spacer()
                }
            }
            .buttonStyle(NativeSetupButtonStyle(role: .primary, isFocused: focusedItem == signInFocus))
            .disabled(isSigningIn || isValidating)
            .focused($focusedItem, equals: signInFocus)

            SetupDividerLabel(title: L10n.text("Server").uppercased())

            ServerConnectionPanel(
                discovery: discovery,
                focusedItem: $focusedItem,
                discoverFocus: discoverFocus,
                serverAddressFocus: serverAddressFocus,
                validateServerFocus: validateServerFocus,
                isBusy: isSigningIn || isValidating
            )

            StatusBanner(message: discovery.errorMessage)
        }
    }
}

private struct SetupExperienceShell: View {
    let statusMessage: String?
    let content: AnyView

    var body: some View {
        HStack(alignment: .center, spacing: 120) {
            VStack(alignment: .center, spacing: 34) {
                PlaceholderBrandMark()

                StatusBanner(message: statusMessage)
            }
            .frame(width: 590, alignment: .center)

            VStack(alignment: .leading, spacing: 30) {
                content
            }
            .frame(width: 820, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, TVLayout.safeHorizontalPadding)
        .padding(.top, TVLayout.safeTopPadding)
        .padding(.bottom, TVLayout.contentBottomPadding)
    }
}

private struct PlaceholderBrandMark: View {
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.08))
                    .frame(width: 116, height: 116)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.20), lineWidth: 1)
                    }

                Image(systemName: "photo")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .accessibilityLabel(L10n.text("Logo placeholder"))

            VStack(spacing: 14) {
                Text("LUMINA")
                    .font(.system(size: 48, weight: .medium))
                    .tracking(18)
                    .foregroundStyle(.white.opacity(0.92))

                Text(L10n.text("Your movies. Your way.").uppercased())
                    .font(.system(size: 21, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(Color(red: 0.86, green: 0.68, blue: 0.42))
            }

            Text(L10n.text("Sign in to access your movies and TV shows library. Connect to your Lumina server to get started."))
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(.white.opacity(0.70))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .frame(maxWidth: 470)
        }
    }
}

private struct NativeSetupTextField<Field: View>: View {
    let title: String
    let systemImage: String
    let isFocused: Bool
    @ViewBuilder var field: () -> Field

    var body: some View {
        HStack(spacing: 22) {
            Image(systemName: systemImage)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 34)

            field()
                .accessibilityLabel(title)
        }
        .padding(.horizontal, 24)
        .frame(width: TVLayout.setupFieldWidth, height: 80, alignment: .leading)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
        }
        .shadow(color: .white.opacity(isFocused ? 0.22 : 0), radius: isFocused ? 18 : 0, x: 0, y: 0)
        .scaleEffect(isFocused ? 1.025 : 1)
        .foregroundStyle(fieldColor)
        .animation(.easeOut(duration: 0.16), value: isFocused)
    }

    private var backgroundColor: Color {
        isFocused ? .white.opacity(0.16) : .white.opacity(0.11)
    }

    private var borderColor: Color {
        isFocused ? .white.opacity(0.46) : .white.opacity(0.10)
    }

    private var iconColor: Color {
        isFocused ? .white.opacity(0.92) : .white.opacity(0.70)
    }

    private var fieldColor: Color {
        isFocused ? .black.opacity(0.88) : .white.opacity(0.82)
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

private struct SetupDividerLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 24) {
            Rectangle()
                .fill(.white.opacity(0.20))
                .frame(height: 1)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.58))
                .lineLimit(1)

            Rectangle()
                .fill(.white.opacity(0.20))
                .frame(height: 1)
        }
        .frame(width: TVLayout.setupFieldWidth)
    }
}

private struct ServerConnectionPanel: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject var discovery: LuminaServerDiscovery
    @FocusState.Binding var focusedItem: SignInFocus?
    let discoverFocus: SignInFocus
    let serverAddressFocus: SignInFocus
    let validateServerFocus: SignInFocus
    let isBusy: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Text(L10n.text("Connect to Server").uppercased())
                    .font(.system(size: 22, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.76))

                if appModel.phase == .validating {
                    ProgressView()
                }
            }

            Button {
                discovery.startSearching()
            } label: {
                NativeSetupServerRow(
                    systemImage: "wifi",
                    title: L10n.text("Search Servers"),
                    subtitle: discoveryStatusText,
                    showsProgress: discovery.isSearching
                )
            }
            .buttonStyle(NativeSetupButtonStyle(isFocused: focusedItem == discoverFocus))
            .disabled(isBusy)
            .focused($focusedItem, equals: discoverFocus)

            ForEach(discovery.discoveredServers.prefix(3)) { server in
                let focus = SignInFocus.discoveredServer(server.id)
                Button {
                    Task { await appModel.chooseDiscoveredServer(server) }
                } label: {
                    NativeSetupServerRow(
                        systemImage: "server.rack",
                        title: server.name,
                        subtitle: server.displayAddress,
                        showsProgress: false
                    )
                }
                .buttonStyle(NativeSetupButtonStyle(isFocused: focusedItem == focus))
                .disabled(isBusy)
                .focused($focusedItem, equals: focus)
            }

            NativeSetupTextField(
                title: L10n.text("Server Address"),
                systemImage: "network",
                isFocused: focusedItem == serverAddressFocus
            ) {
                TextField(L10n.text("Server Address"), text: $appModel.serverURLString)
                    .textFieldStyle(.plain)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .font(.system(size: 30, weight: .medium))
                    .disabled(isBusy)
                    .focused($focusedItem, equals: serverAddressFocus)
                    .onSubmit {
                        Task { await appModel.validateServer() }
                    }
            }

            Button {
                Task { await appModel.validateServer() }
            } label: {
                HStack {
                    Spacer()
                    Label(L10n.text("Validate Server"), systemImage: "checkmark.circle")
                    Spacer()
                }
            }
            .buttonStyle(NativeSetupButtonStyle(isFocused: focusedItem == validateServerFocus))
            .disabled(isBusy)
            .focused($focusedItem, equals: validateServerFocus)

            Text(L10n.text("Ensure your server is on the same network and Bonjour is enabled."))
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.white.opacity(0.46))
                .frame(width: TVLayout.setupFieldWidth, alignment: .center)
        }
    }

    private var discoveryStatusText: String {
        if discovery.isSearching {
            return L10n.text("Searching for your Lumina server...")
        }
        if discovery.discoveredServers.isEmpty {
            return L10n.text("No Lumina server found.")
        }
        return String.localizedStringWithFormat(
            L10n.text("%d servers found"),
            discovery.discoveredServers.count
        )
    }
}

private struct NativeSetupServerRow: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let showsProgress: Bool

    var body: some View {
        HStack(spacing: 22) {
            Image(systemName: systemImage)
                .font(.system(size: 32, weight: .medium))
                .frame(width: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 27, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 21, weight: .regular))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 18)

            if showsProgress {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct NativeSetupButtonStyle: ButtonStyle {
    enum Role {
        case primary
        case secondary
    }

    let role: Role
    let isFocused: Bool

    @Environment(\.isEnabled) private var isEnabled

    init(role: Role = .secondary, isFocused: Bool = false) {
        self.role = role
        self.isFocused = isFocused
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: role == .primary ? 29 : 27, weight: .semibold))
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, 24)
            .frame(width: TVLayout.setupFieldWidth)
            .frame(minHeight: role == .primary ? 80 : 76)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(isFocused ? 0.42 : 0.10), lineWidth: isFocused ? 2 : 1)
            }
            .shadow(color: .white.opacity(isFocused ? 0.28 : 0), radius: isFocused ? 18 : 0, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.98 : isFocused ? 1.035 : 1)
            .opacity(isEnabled ? 1 : 0.46)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.16), value: isFocused)
    }

    private var foregroundStyle: Color {
        guard isEnabled else { return .white.opacity(0.60) }

        switch role {
        case .primary:
            return .black.opacity(0.90)
        case .secondary:
            return .white.opacity(0.92)
        }
    }

    private func background(isPressed: Bool) -> Color {
        guard isEnabled else { return .white.opacity(0.10) }

        switch role {
        case .primary:
            return .white.opacity(isPressed ? 0.74 : 0.90)
        case .secondary:
            return .white.opacity(isPressed ? 0.14 : isFocused ? 0.18 : 0.12)
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
