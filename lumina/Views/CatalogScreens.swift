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
        TabView(selection: $appModel.selectedHomeTab) {
            CatalogHomeView()
                .tag(HomeTab.home)
                .tabItem {
                    Label(L10n.text("Home"), systemImage: "house")
                }

            CatalogGridView(
                title: L10n.text("Movies"),
                items: appModel.movies,
                emptyTitle: L10n.text("No movies found"),
                topPadding: 46
            )
            .tag(HomeTab.movies)
            .tabItem {
                Label(L10n.text("Movies"), systemImage: "film")
            }

            CatalogGridView(
                title: L10n.text("TV Shows"),
                items: appModel.tvShows,
                emptyTitle: L10n.text("No TV shows found"),
                topPadding: 46
            )
            .tag(HomeTab.tvShows)
            .tabItem {
                Label(L10n.text("TV Shows"), systemImage: "tv")
            }

            CatalogSearchView(topPadding: 46)
                .tag(HomeTab.search)
                .tabItem {
                    Label(L10n.text("Search"), systemImage: "magnifyingglass")
                }

            SettingsView(topPadding: 70)
                .tag(HomeTab.settings)
                .tabItem {
                    Label(L10n.text("Settings"), systemImage: "gearshape")
                }
        }
        .task {
            if appModel.automaticCatalogRefreshEnabled {
                await appModel.loadCatalog()
            }
        }
    }
}

private struct CatalogHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    private enum Layout {
        static let horizontalPadding: CGFloat = 72
        static let shelfPeekHeight: CGFloat = 420
        static let minimumHeroHeight: CGFloat = 520
        static let maximumHeroHeight: CGFloat = 650
        static let shelfSpacing: CGFloat = 28
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: Layout.shelfSpacing) {
                    if appModel.isCatalogLoading && appModel.homeSections.isEmpty {
                        ProgressView(L10n.text("Loading catalog"))
                            .padding(.horizontal, Layout.horizontalPadding)
                            .padding(.top, 72)
                    }

                    if !appModel.homeHeroItems.isEmpty {
                        FeaturedHeroCarousel(
                            items: appModel.homeHeroItems,
                            heroHeight: heroHeight(for: proxy)
                        )
                            .frame(width: proxy.size.width)
                            .ignoresSafeArea(.container, edges: [.top, .horizontal])
                    }

                    VStack(alignment: .leading, spacing: 40) {
                        ForEach(appModel.homeSections.filter { !$0.items.isEmpty }) { section in
                            HomeCatalogSectionView(section: section)
                        }

                        if appModel.homeSections.isEmpty && !appModel.isCatalogLoading {
                            EmptyCatalogState(title: L10n.text("No catalog shelves yet"))
                        }

                        StatusText(message: appModel.statusMessage)
                    }
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.bottom, 46)
                }
            }
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
        }
    }

    private func heroHeight(for proxy: GeometryProxy) -> CGFloat {
        min(
            max(proxy.size.height - Layout.shelfPeekHeight, Layout.minimumHeroHeight),
            Layout.maximumHeroHeight
        )
    }
}

private struct CatalogGridView: View {
    @EnvironmentObject private var appModel: AppModel
    let title: String
    let items: [CatalogItem]
    let emptyTitle: String
    let topPadding: CGFloat

    private let columns = [
        GridItem(.adaptive(minimum: 220, maximum: 240), spacing: 30)
    ]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 30) {
                CatalogHeader(title: title, subtitle: L10n.titleCount(items.count))

                if items.isEmpty && appModel.isCatalogLoading {
                    ProgressView(L10n.loading(title))
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
            .padding(.top, topPadding)
            .padding(.bottom, 46)
        }
    }
}

private struct CatalogSearchView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedField: SearchFocus?
    let topPadding: CGFloat

    private enum SearchFocus: Hashable {
        case query
        case submit
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 28) {
                CatalogHeader(title: L10n.text("Search"), subtitle: L10n.text("Find movies and TV shows"))

                HStack(spacing: 18) {
                    TextField(L10n.text("Search your library"), text: $appModel.searchQuery)
                        .textFieldStyle(.plain)
                        .textContentType(.none)
                        .submitLabel(.search)
                        .font(.title3)
                        .padding(18)
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: 680)
                        .focused($focusedField, equals: .query)
                        .onSubmit {
                            Task { await appModel.runSearch() }
                        }

                    Button {
                        Task { await appModel.runSearch() }
                    } label: {
                        Label(L10n.text("Search"), systemImage: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                    .focused($focusedField, equals: .submit)
                }

                if appModel.isCatalogLoading && appModel.searchResults.isEmpty {
                    ProgressView(L10n.text("Searching"))
                } else if appModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    SearchSuggestionState()
                } else if appModel.searchResults.isEmpty {
                    EmptyCatalogState(title: L10n.text("No results yet. Try a title, actor, or genre."))
                } else {
                    CatalogShelfView(title: L10n.text("Results"), items: appModel.searchResults)
                }

                StatusText(message: appModel.statusMessage)
            }
            .padding(.horizontal, 72)
            .padding(.top, topPadding)
            .padding(.bottom, 46)
        }
        .defaultFocus($focusedField, .query)
    }
}

private struct SearchSuggestionState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.text("Search results appear here"))
                .font(.system(size: 31, weight: .medium))
            Text(L10n.text("Use dictation or the remote keyboard, then press Search."))
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
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
