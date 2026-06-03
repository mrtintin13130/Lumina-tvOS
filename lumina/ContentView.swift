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

private struct ServerSetupView: View {
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
                    .font(.title3)
                    .padding(18)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: 760)

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

private struct SignInView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Sign in to Lumina")
                .font(.system(size: 48, weight: .bold))

            Text(appModel.serverURLString)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.68))

            TextField("Username", text: $appModel.username)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(18)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 640)

            SecureField("Password", text: $appModel.password)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(18)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 640)

            HStack(spacing: 18) {
                Button {
                    Task { await appModel.signIn() }
                } label: {
                    Label(appModel.phase == .signingIn ? "Signing In" : "Sign In", systemImage: "person.badge.key")
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.phase == .signingIn)

                Button {
                    appModel.resetServer()
                } label: {
                    Label("Change Server", systemImage: "server.rack")
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

private struct HomeShellView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ZStack {
            TabView {
                CatalogHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                CatalogGridView(title: "Movies", items: appModel.movies, emptyTitle: "No movies found")
                    .tabItem {
                        Label("Movies", systemImage: "film")
                    }

                CatalogGridView(title: "TV Shows", items: appModel.tvShows, emptyTitle: "No TV shows found")
                    .tabItem {
                        Label("TV Shows", systemImage: "tv")
                    }

                CatalogSearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }

            if let detail = appModel.selectedCatalogItem {
                CatalogDetailOverlay(item: detail)
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
                    .zIndex(20)
            }
        }
        .task {
            await appModel.loadCatalog()
        }
    }
}

private struct CatalogHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                CatalogHeader(
                    title: "Home",
                    subtitle: "Signed in as \(appModel.currentUser?.displayName ?? "Lumina user")"
                )

                if appModel.isCatalogLoading && appModel.homeSections.isEmpty {
                    ProgressView("Loading catalog")
                }

                if let hero = appModel.homeHeroItems.first {
                    FeaturedCatalogButton(item: hero)
                }

                ForEach(appModel.homeSections.filter { !$0.items.isEmpty }) { section in
                    CatalogShelfView(title: section.title, items: section.items)
                }

                if appModel.homeSections.isEmpty && !appModel.isCatalogLoading {
                    EmptyCatalogState(title: "No catalog shelves yet")
                }

                StatusText(message: appModel.statusMessage)
            }
            .padding(.horizontal, 72)
            .padding(.vertical, 36)
        }
    }
}

private struct CatalogGridView: View {
    @EnvironmentObject private var appModel: AppModel
    let title: String
    let items: [CatalogItem]
    let emptyTitle: String

    private let columns = [
        GridItem(.adaptive(minimum: 220, maximum: 240), spacing: 30)
    ]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 30) {
                CatalogHeader(title: title, subtitle: "\(items.count) titles")

                if items.isEmpty && appModel.isCatalogLoading {
                    ProgressView("Loading \(title.lowercased())")
                } else if items.isEmpty {
                    EmptyCatalogState(title: emptyTitle)
                } else {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                        ForEach(items) { item in
                            CatalogPosterButton(item: item)
                        }
                    }
                }

                StatusText(message: appModel.statusMessage)
            }
            .padding(.horizontal, 72)
            .padding(.vertical, 46)
        }
    }
}

private struct CatalogSearchView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 28) {
                CatalogHeader(title: "Search", subtitle: "Find movies and TV shows")

                HStack(spacing: 18) {
                    TextField("Search your library", text: $appModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .padding(18)
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: 680)
                        .onSubmit {
                            Task { await appModel.runSearch() }
                        }

                    Button {
                        Task { await appModel.runSearch() }
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if appModel.isCatalogLoading && appModel.searchResults.isEmpty {
                    ProgressView("Searching")
                } else if appModel.searchResults.isEmpty {
                    EmptyCatalogState(title: "Search results appear here")
                } else {
                    CatalogShelfView(title: "Results", items: appModel.searchResults)
                }

                StatusText(message: appModel.statusMessage)
            }
            .padding(.horizontal, 72)
            .padding(.vertical, 46)
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

private struct SettingsView: View {
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

private struct HomeActionCard: View {
    let title: String
    let systemImage: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 44, weight: .semibold))
                Text(title)
                    .font(.title2.bold())
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 330, height: 210, alignment: .leading)
            .padding(24)
        }
        .buttonStyle(.bordered)
    }
}

private struct ContractBadge: View {
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
