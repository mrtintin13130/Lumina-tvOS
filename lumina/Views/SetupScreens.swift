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

    var body: some View {
        HStack(spacing: 70) {
            VStack(alignment: .leading, spacing: 28) {
                Label("Lumina", systemImage: "play.tv")
                    .font(.system(size: 48, weight: .bold))

                Text(L10n.text("Connect this Apple TV to your Lumina server."))
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.74))

                discoveryContent

                HStack(spacing: 18) {
                    Button {
                        discovery.startSearching()
                    } label: {
                        Label(L10n.text("Retry"), systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        showManualEntry.toggle()
                    } label: {
                        Label(L10n.text("Add Manually"), systemImage: "keyboard")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if showManualEntry || discovery.discoveredServers.isEmpty {
                    ManualServerEntryView()
                }

                StatusText(message: appModel.statusMessage)
            }

            VStack(alignment: .leading, spacing: 18) {
                ContractBadge(title: L10n.text("Discovery"), value: "Bonjour")
                ContractBadge(title: L10n.text("Validation"), value: "/health + capabilities")
                ContractBadge(title: L10n.text("Fallback"), value: L10n.text("Manual URL"))
                ContractBadge(title: L10n.text("Auth"), value: L10n.text("Password JWT"))
            }
            .frame(width: 360, alignment: .leading)
        }
        .padding(.horizontal, 90)
        .padding(.vertical, 56)
        .task {
            discovery.startSearching()
        }
        .onDisappear {
            discovery.stopSearching()
        }
    }

    @ViewBuilder
    private var discoveryContent: some View {
        if appModel.phase == .validating {
            HStack(spacing: 14) {
                ProgressView()
                Text(L10n.text("Validating"))
                    .font(.title3.weight(.semibold))
            }
            .frame(maxWidth: 760, minHeight: 120, alignment: .leading)
        } else if !discovery.discoveredServers.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.text("Servers Found"))
                    .font(.title3.weight(.bold))

                ForEach(discovery.discoveredServers) { server in
                    Button {
                        Task { await appModel.chooseDiscoveredServer(server) }
                    } label: {
                        HStack(spacing: 18) {
                            Image(systemName: "server.rack")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(server.name)
                                    .font(.title3.weight(.bold))
                                Text(server.displayAddress)
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.72))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.headline.weight(.bold))
                        }
                        .frame(width: 760, height: 108, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    if discovery.isSearching {
                        ProgressView()
                    }
                    Text(discovery.isSearching ? L10n.text("Searching for your Lumina server...") : L10n.text("No Lumina server found."))
                        .font(.title3.weight(.semibold))
                }

                if let message = discovery.errorMessage {
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: 760, minHeight: 120, alignment: .leading)
        }
    }
}

struct ManualServerEntryView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("192.168.0.50:3000", text: $appModel.serverURLString)
                .textFieldStyle(.plain)
                .textContentType(.URL)
                .keyboardType(.URL)
                .submitLabel(.go)
                .font(.title3)
                .padding(18)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 760)
                .onSubmit {
                    Task { await appModel.validateServer() }
                }

            HStack(spacing: 18) {
                Button {
                    Task { await appModel.validateServer() }
                } label: {
                    Label(appModel.phase == .validating ? L10n.text("Validating") : L10n.text("Validate Server"), systemImage: "checkmark.shield")
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.phase == .validating)

                Button {
                    appModel.resetServer()
                } label: {
                    Label(L10n.text("Clear"), systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct ServerUnavailableView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            Label(L10n.text("Server Unavailable"), systemImage: "wifi.exclamationmark")
                .font(.system(size: 48, weight: .bold))

            Text(L10n.text("Your saved Lumina server could not be reached."))
                .font(.title2)
                .foregroundStyle(.white.opacity(0.74))

            ContractBadge(title: L10n.text("Last Server"), value: appModel.serverURLString)
                .frame(width: 760)

            HStack(spacing: 18) {
                Button {
                    Task { await appModel.retrySavedServer() }
                } label: {
                    Label(L10n.text("Retry"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    appModel.searchForServer()
                } label: {
                    Label(L10n.text("Search Servers"), systemImage: "dot.radiowaves.left.and.right")
                }
                .buttonStyle(.bordered)

                Button {
                    appModel.resetServer()
                } label: {
                    Label(L10n.text("Change Server"), systemImage: "server.rack")
                }
                .buttonStyle(.bordered)
            }

            StatusText(message: appModel.statusMessage)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 90)
        .padding(.vertical, 56)
    }
}

struct SignInView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        let isSigningIn = appModel.phase == .signingIn

        VStack(alignment: .leading, spacing: 24) {
            Text("Sign in to Lumina")
                .font(.system(size: 48, weight: .bold))

            Text(appModel.serverURLString)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.68))

            TextField(L10n.text("Email"), text: $appModel.email)
                .textFieldStyle(.plain)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .font(.title3)
                .padding(18)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 640)
                .disabled(isSigningIn)

            SecureField(L10n.text("Password"), text: $appModel.password)
                .textFieldStyle(.plain)
                .textContentType(.password)
                .submitLabel(.go)
                .font(.title3)
                .padding(18)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 640)
                .disabled(isSigningIn)
                .onSubmit {
                    Task { await appModel.signIn() }
                }

            HStack(spacing: 18) {
                Button {
                    Task { await appModel.signIn() }
                } label: {
                    Label(isSigningIn ? L10n.text("Signing In") : L10n.text("Sign In"), systemImage: "person.badge.key")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSigningIn)

                Button {
                    appModel.resetServer()
                } label: {
                    Label(L10n.text("Change Server"), systemImage: "server.rack")
                }
                .buttonStyle(.bordered)
                .disabled(isSigningIn)

                if isSigningIn {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Signing in...")
                            .font(.title3.weight(.semibold))
                    }
                    .foregroundStyle(.white.opacity(0.82))
                    .accessibilityElement(children: .combine)
                }
            }

            StatusText(message: isSigningIn ? L10n.text("Signing in...") : appModel.statusMessage)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 90)
        .padding(.vertical, 56)
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
