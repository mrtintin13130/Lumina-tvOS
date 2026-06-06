//
//  SetupScreens.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct ServerSetupView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        HStack(spacing: 70) {
            VStack(alignment: .leading, spacing: 26) {
                Label("Lumina", systemImage: "play.tv")
                    .font(.system(size: 48, weight: .bold))

                Text("Connect this Apple TV to your Lumina server.")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.74))

                TextField("https://lumina.local:3000", text: $appModel.serverURLString)
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
                        Label(appModel.phase == .validating ? "Validating" : "Validate Server", systemImage: "checkmark.shield")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(appModel.phase == .validating)

                    Button {
                        appModel.resetServer()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                }

                StatusText(message: appModel.statusMessage)
            }

            VStack(alignment: .leading, spacing: 18) {
                ContractBadge(title: "Manual URL", value: "MVP")
                ContractBadge(title: "Auth", value: "Password JWT")
                ContractBadge(title: "Playback", value: "HLS Preferred")
                ContractBadge(title: "Storage", value: "Keychain Tokens")
            }
            .frame(width: 360, alignment: .leading)
        }
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

            TextField("Email", text: $appModel.email)
                .textFieldStyle(.plain)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .font(.title3)
                .padding(18)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 640)
                .disabled(isSigningIn)

            SecureField("Password", text: $appModel.password)
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
                    Label(isSigningIn ? "Signing In" : "Sign In", systemImage: "person.badge.key")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSigningIn)

                Button {
                    appModel.resetServer()
                } label: {
                    Label("Change Server", systemImage: "server.rack")
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

            StatusText(message: isSigningIn ? "Signing in..." : appModel.statusMessage)
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
