//
//  CatalogScreens.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct HomeShellView: View {
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
