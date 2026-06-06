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

            if case .home = appModel.phase,
               let detail = appModel.selectedCatalogItem {
                CatalogDetailPage(item: detail)
                    .transition(.opacity)
                    .zIndex(10)
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
            ProgressView("Restoring Lumina")
        case .setup, .validating:
            ServerSetupView()
        case .signIn, .signingIn:
            SignInView()
        case .home:
            HomeShellView()
        case .loadingPlayback:
            VStack(spacing: 24) {
                ProgressView("Preparing playback")
                Button {
                    appModel.exitPlayback()
                } label: {
                    Label("Cancel", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 90)
            .padding(.vertical, 56)
        case .playback(let proof):
            PlaybackProofView(proof: proof)
        }
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
                appModel.exitPlayback()
            }
        .background(Color.black.ignoresSafeArea())
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Settings")
                .font(.system(size: 48, weight: .bold))

            ContractBadge(title: "Server", value: appModel.serverURLString)
            ContractBadge(title: "User", value: appModel.currentUser?.displayName ?? "Unknown")
            ContractBadge(title: "Validation", value: appModel.capabilities?.isTvMVPCompatible == true ? "Compatible" : "Not validated")

            HStack(spacing: 18) {
                Button {
                    Task { await appModel.validateServer() }
                } label: {
                    Label("Revalidate", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    appModel.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(70)
        .foregroundStyle(.white)
        .background(Color.black.ignoresSafeArea())
    }
}
