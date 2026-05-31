//
//  ContentView.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import AVKit
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

private struct CatalogHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 56, weight: .bold))
            Text(subtitle)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.68))
        }
    }
}

private struct FeaturedCatalogButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let heroHeight: CGFloat = 660
    private let cornerRadius: CGFloat = 18
    private let focusedScale: CGFloat = 1.025

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CatalogArtwork(
                url: appModel.artworkURL(
                    for: item.backdropPath ?? item.posterPath,
                    kind: .backdrop
                ),
                aspectRatio: 16 / 9
            )
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight)

            LinearGradient(
                colors: [
                    .black.opacity(0.75),
                    .black.opacity(0.25),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.82)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(item.title)
                    .font(.system(size: 44, weight: .bold))
                    .lineLimit(2)
                    .frame(maxWidth: 780, alignment: .leading)

                if let overview = item.overview {
                    Text(overview)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(2)
                        .frame(maxWidth: 860, alignment: .leading)
                }

                Label("Play", systemImage: "play.fill")
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.16), in: Capsule())
                    .padding(.top, 4)
            }
            .padding(34)
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    isFocused ? .white.opacity(0.85) : .white.opacity(0.08),
                    lineWidth: isFocused ? 3 : 1
                )
        }
        .shadow(
            color: .black.opacity(isFocused ? 0.55 : 0.25),
            radius: isFocused ? 26 : 14,
            x: 0,
            y: isFocused ? 16 : 8
        )
        .scaleEffect(isFocused ? focusedScale : 1)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focusable(true)
        .focused($isFocused)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onTapGesture {
            Task { await appModel.playCatalogMovie(item) }
        }
    }
}

private struct CatalogShelfView: View {
    let title: String
    let items: [CatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 26) {
                    ForEach(items) { item in
                        CatalogPosterButton(item: item)
                    }
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 8)
            }
            .scrollClipDisabled()
        }
    }
}

private struct CatalogPosterButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let cardWidth: CGFloat = 220
    private let cardHeight: CGFloat = 330
    private let focusedScale: CGFloat = 1.06
    private let cornerRadius: CGFloat = 12

    var body: some View {
        posterCard
            .frame(width: cardWidth, height: cardHeight)
            .scaleEffect(isFocused ? focusedScale : 1)
            .shadow(
                color: .black.opacity(isFocused ? 0.65 : 0.25),
                radius: isFocused ? 22 : 10,
                x: 0,
                y: isFocused ? 14 : 6
            )
            .zIndex(isFocused ? 10 : 0)
            .animation(.easeOut(duration: 0.16), value: isFocused)
            .focusable(true)
            .focused($isFocused)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onTapGesture {
                Task { await appModel.playCatalogMovie(item) }
            }
    }

    private var posterCard: some View {
        ZStack(alignment: .bottomLeading) {
            CatalogArtwork(
                url: appModel.artworkURL(
                    for: item.posterPath ?? item.backdropPath,
                    kind: .poster
                ),
                aspectRatio: 2 / 3
            )
            .frame(width: cardWidth, height: cardHeight)

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.12),
                    .black.opacity(0.86)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.subtitle ?? item.mediaTypeDisplayName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)

                if item.progressPercent > 0 {
                    ProgressView(value: min(max(item.progressPercent / 100, 0), 1))
                        .progressViewStyle(.linear)
                        .frame(height: 5)
                        .padding(.top, 5)
                }
            }
            .padding(14)
            .frame(width: cardWidth, alignment: .leading)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    isFocused ? .white.opacity(0.95) : .white.opacity(0.08),
                    lineWidth: isFocused ? 3 : 1
                )
        }
    }
}

private struct CatalogArtwork: View {
    let url: URL?
    let aspectRatio: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.14),
                            .white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        placeholderIcon("photo")

                    case .empty:
                        ProgressView()

                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderIcon("play.rectangle")
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fill)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private func placeholderIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 54, weight: .semibold))
            .foregroundStyle(.white.opacity(0.42))
    }
}

private struct EmptyCatalogState: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
    }
}

private extension CatalogItem {
    var mediaTypeDisplayName: String {
        switch mediaType {
        case "tv_show":
            return "TV Show"
        case "episode":
            return "Episode"
        default:
            return "Movie"
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

private struct AVKitPlayerView: UIViewControllerRepresentable {
    @EnvironmentObject private var appModel: AppModel
    let proof: PlaybackProof

    func makeCoordinator() -> Coordinator {
        Coordinator(appModel: appModel, proof: proof)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let asset: AVURLAsset
        if let authorizationHeader = proof.authorizationHeader {
            asset = AVURLAsset(
                url: proof.streamURL,
                options: ["AVURLAssetHTTPHeaderFieldsKey": ["Authorization": authorizationHeader]]
            )
        } else {
            asset = AVURLAsset(url: proof.streamURL)
        }
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        controller.player = player
        context.coordinator.attach(player: player, item: item)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    final class Coordinator {
        private let appModel: AppModel
        private let proof: PlaybackProof
        private weak var player: AVPlayer?
        private weak var item: AVPlayerItem?
        private var itemStatusObservation: NSKeyValueObservation?
        private var playerErrorObservation: NSKeyValueObservation?
        private var didStartPlayback = false

        init(appModel: AppModel, proof: PlaybackProof) {
            self.appModel = appModel
            self.proof = proof
        }

        func attach(player: AVPlayer, item: AVPlayerItem) {
            self.player = player
            self.item = item

            itemStatusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] observedItem, _ in
                guard let self else { return }
                let status = observedItem.status
                Task { @MainActor in
                    switch status {
                    case .readyToPlay:
                        self.startPlaybackIfNeeded()
                    case .failed:
                        self.reportFailure()
                    case .unknown:
                        break
                    @unknown default:
                        break
                    }
                }
            }

            playerErrorObservation = player.observe(\.error, options: [.new]) { [weak self] _, _ in
                guard let self else { return }
                Task { @MainActor in
                    self.reportFailure()
                }
            }
        }

        @MainActor
        private func startPlaybackIfNeeded() {
            guard !didStartPlayback, let player else { return }
            didStartPlayback = true
            let resume = max(0, proof.movie.resumePositionSeconds ?? 0)
            let target = CMTime(seconds: resume, preferredTimescale: 600)
            player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                player.play()
            }
        }

        @MainActor
        private func reportFailure() {
            let error = item?.error ?? player?.error
            let statusError = item?.errorLog()?.events.last
            let statusMessage = statusError.map { "Playback failed with status \($0.errorStatusCode)." }
            let message = error?.localizedDescription
                ?? statusError?.errorComment
                ?? statusMessage
                ?? "Playback failed before media became ready."
            appModel.recordPlaybackFailure(message)
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

private struct StatusText: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.headline)
                .foregroundStyle(.yellow)
                .accessibilityIdentifier("status-message")
        }
    }
}
