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
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                content
            }
            .foregroundStyle(.white)
            .task {
                await appModel.restoreSession()
            }
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
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(proof.movie.title)
                        .font(.system(size: 42, weight: .bold))
                    Text("HLS playback proof")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer()

                Button {
                    Task { await appModel.reportPlaybackProgress(positionSeconds: proof.movie.resumePositionSeconds ?? 0, event: "exit") }
                    appModel.exitPlayback()
                } label: {
                    Label("Exit", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
            }

            AVKitPlayerView(proof: proof)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            StatusText(message: appModel.statusMessage)
        }
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
