//
//  ContentView.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
        case .restoring:
            ProgressView(L10n.text("Restoring Lumina"))
        case .setup, .validating, .signIn, .signingIn:
            ServerSetupView()
        case .serverUnavailable:
            ServerUnavailableView()
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

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedAction: SettingsFocus?
    let topPadding: CGFloat

    private enum SettingsFocus: Hashable {
        case revalidate
        case signOut
    }

    var body: some View {
        let summary = appModel.supportSummary

        TVTabPageLayout(topPadding: topPadding, spacing: 24, horizontalPadding: 70, bottomPadding: 70) {
            Text("Settings")
                .font(.system(size: 48, weight: .bold))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 330), spacing: 16)], spacing: 16) {
                ContractBadge(title: L10n.text("App Build"), value: summary.appBuild)
                ContractBadge(title: L10n.text("Server"), value: summary.serverSummary)
                ContractBadge(title: L10n.text("API"), value: summary.apiSummary)
                ContractBadge(title: L10n.text("Validation"), value: summary.validationSummary)
                ContractBadge(title: L10n.text("User"), value: summary.userDisplayName)
                ContractBadge(title: L10n.text("Diagnostics"), value: summary.diagnosticsSummary)
                ContractBadge(title: L10n.text("Last Error"), value: summary.lastSafeError)
                ContractBadge(title: L10n.text("Support ID"), value: summary.lastSupportId)
            }

            LuminaActionRow {
                Button {
                    Task { await appModel.validateServer() }
                } label: {
                    Label(L10n.text("Revalidate"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(LuminaActionButtonStyle(isFocused: focusedAction == .revalidate))
                .focused($focusedAction, equals: .revalidate)

                Button(role: .destructive) {
                    appModel.signOut()
                } label: {
                    Label(L10n.text("Sign Out"), systemImage: "rectangle.portrait.and.arrow.right")
                }
                .buttonStyle(LuminaActionButtonStyle(role: .destructive, isFocused: focusedAction == .signOut))
                .focused($focusedAction, equals: .signOut)
            }
        }
        .foregroundStyle(.white)
        .background(Color.black.ignoresSafeArea())
        .defaultFocus($focusedAction, .revalidate)
    }
}
