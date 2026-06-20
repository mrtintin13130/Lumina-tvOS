//
//  ContentView.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            content

            if case .home = appModel.phase,
               let section = appModel.selectedEditorialSection {
                CatalogEditorialPage(section: section)
                    .transition(.opacity)
                    .zIndex(9)
            }

        }
        .foregroundStyle(.white)
        .animation(.easeOut(duration: 0.16), value: appModel.selectedEditorialSection?.id)
        .animation(.easeOut(duration: 0.16), value: appModel.selectedCatalogItem?.id)
        .task {
            await appModel.restoreSession()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appModel.phase {
        case .restoring, .setup, .validating, .serverUnavailable, .signIn, .signingIn:
            SignInView()
        case .home:
            HomeShellView()
        case .loadingPlayback:
            LoadingPlaybackView()
        case .playback(let proof):
            PlaybackProofView(proof: proof)
        }
    }
}

private struct LoadingPlaybackView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isCancelFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(L10n.text("Preparing playback"))
            Button {
                appModel.exitPlayback()
            } label: {
                Label(L10n.text("Cancel"), systemImage: "xmark.circle")
            }
            .buttonStyle(LuminaActionButtonStyle(size: .compact, isFocused: isCancelFocused))
            .focused($isCancelFocused)
        }
        .padding(.horizontal, 90)
        .padding(.vertical, 56)
        .defaultFocus($isCancelFocused, true)
    }
}

private struct PlaybackProofView: View {
    @EnvironmentObject private var appModel: AppModel
    let proof: PlaybackProof

    var body: some View {
        AVKitPlayerView(proof: proof)
            .ignoresSafeArea()
            .background(Color.black)
            .onExitCommand {
                appModel.requestPlaybackExit()
            }
        .background(Color.black.ignoresSafeArea())
    }
}

struct ProfileView: View {
    @EnvironmentObject private var appModel: AppModel
    @AppStorage("show_advanced_diagnostics") private var showsAdvancedDiagnostics = false
    let topPadding: CGFloat

    private var settingsURL: URL? {
        URL(string: UIApplication.openSettingsURLString)
    }

    var body: some View {
        let summary = appModel.supportSummary

        ZStack(alignment: .topLeading) {
            CatalogBrowseBackground()
                .ignoresSafeArea()

            TVTabPageLayout(topPadding: topPadding, spacing: 34, horizontalPadding: 92, bottomPadding: 76) {
                ProfileHeader(summary: summary)

                ProfileActions(
                    settingsURL: settingsURL,
                    testConnection: {
                        Task { await appModel.validateServer() }
                    },
                    changeServer: {
                        appModel.resetServer()
                    },
                    signOut: {
                        appModel.signOut()
                    }
                )

                if showsAdvancedDiagnostics {
                    ProfileDiagnostics(summary: summary)
                }
            }
        }
        .foregroundStyle(.white)
    }
}

private struct ProfileHeader: View {
    let summary: SupportSummary

    var body: some View {
        HStack(alignment: .center, spacing: 34) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 118, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.92))

            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.text("Profile"))
                    .font(.system(size: 58, weight: .bold))

                Text(summary.userDisplayName)
                    .font(.system(size: 38, weight: .semibold))

                Label(summary.serverSummary, systemImage: "server.rack")
                    .font(.system(size: 29, weight: .medium))
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProfileActions: View {
    let settingsURL: URL?
    let testConnection: () -> Void
    let changeServer: () -> Void
    let signOut: () -> Void

    var body: some View {
        HStack(spacing: 22) {
            if let settingsURL {
                Link(destination: settingsURL) {
                    ProfileActionLabel(
                        title: L10n.text("Open Apple TV Settings"),
                        systemImage: "gearshape"
                    )
                }
                .buttonStyle(.card)
            }

            Button(action: testConnection) {
                ProfileActionLabel(title: L10n.text("Test Connection"), systemImage: "arrow.clockwise")
            }
            .buttonStyle(.card)

            Button(action: changeServer) {
                ProfileActionLabel(title: L10n.text("Change Server"), systemImage: "server.rack")
            }
            .buttonStyle(.card)

            Button(role: .destructive, action: signOut) {
                ProfileActionLabel(title: L10n.text("Sign Out"), systemImage: "rectangle.portrait.and.arrow.right")
            }
            .buttonStyle(.card)
        }
    }
}

private struct ProfileActionLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))

            Text(title)
                .font(.system(size: 30, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(width: 270, height: 150, alignment: .leading)
        .padding(20)
    }
}

private struct ProfileDiagnostics: View {
    let summary: SupportSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Label(L10n.text("Diagnostics"), systemImage: "stethoscope")
                .font(.system(size: 31, weight: .bold))

            HStack(alignment: .top, spacing: 24) {
                SettingsValueRow(title: L10n.text("App Build"), value: summary.appBuild, systemImage: "app.badge")
                SettingsValueRow(title: L10n.text("Support ID"), value: summary.lastSupportId, systemImage: "number")
                SettingsValueRow(title: L10n.text("Last Error"), value: summary.lastSafeError, systemImage: "exclamationmark.triangle")
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SettingsValueRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.58))

                Text(value)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
