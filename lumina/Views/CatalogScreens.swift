//
//  CatalogScreens.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct HomeShellView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedChrome: HomeChromeFocus?

    var body: some View {
        ZStack(alignment: .top) {
            selectedTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            LinearGradient(
                colors: [.black.opacity(0.78), .black.opacity(0.42), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 170)
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            HomeTopNavigationBar(
                selection: $appModel.selectedHomeTab,
                focusedChrome: $focusedChrome
            )
            .padding(.horizontal, 72)
            .padding(.top, 36)
            .zIndex(20)
        }
        .task {
            if appModel.automaticCatalogRefreshEnabled {
                await appModel.loadCatalog()
            }
        }
    }

    @ViewBuilder
    private var selectedTabContent: some View {
        switch appModel.selectedHomeTab {
        case .home:
            CatalogHomeView(focusTopNavigation: focusSelectedTab)
        case .movies:
            CatalogGridView(
                title: L10n.text("Movies"),
                items: appModel.movies,
                emptyTitle: L10n.text("No movies found"),
                topPadding: 148
            )
        case .tvShows:
            CatalogGridView(
                title: L10n.text("TV Shows"),
                items: appModel.tvShows,
                emptyTitle: L10n.text("No TV shows found"),
                topPadding: 148
            )
        case .search:
            CatalogSearchView(topPadding: 148)
        case .settings:
            SettingsView(topPadding: 148)
        }
    }

    private func focusSelectedTab() {
        focusedChrome = .tab(appModel.selectedHomeTab)
    }
}

private enum HomeChromeFocus: Hashable {
    case tab(HomeTab)
}

private struct HomeTopNavigationBar: View {
    @Binding var selection: HomeTab
    @FocusState.Binding var focusedChrome: HomeChromeFocus?

    private let tabs: [HomeTab] = [.home, .movies, .tvShows, .search, .settings]

    var body: some View {
        HStack(spacing: 14) {
            ForEach(tabs, id: \.self) { tab in
                HomeTopNavigationButton(
                    tab: tab,
                    isSelected: selection == tab,
                    isFocused: focusedChrome == .tab(tab)
                ) {
                    selection = tab
                }
                .focused($focusedChrome, equals: .tab(tab))
            }
        }
        .padding(8)
        .background(.black.opacity(0.42), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HomeTopNavigationButton: View {
    let tab: HomeTab
    let isSelected: Bool
    let isFocused: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(L10n.text(tab.titleKey), systemImage: tab.systemImage)
                .font(.system(size: 27, weight: .bold))
                .labelStyle(.titleAndIcon)
                .foregroundStyle(isSelected ? .black : .white.opacity(0.86))
                .padding(.horizontal, 22)
                .frame(height: 58)
                .background(
                    isSelected ? .white.opacity(0.94) : .white.opacity(isFocused ? 0.18 : 0.06),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(isFocused ? .white.opacity(0.95) : .white.opacity(0.08), lineWidth: isFocused ? 3 : 1)
                }
        }
        .buttonStyle(.plain)
        .focusEffectDisabled()
        .scaleEffect(isFocused ? 1.06 : 1)
        .shadow(color: .black.opacity(isFocused ? 0.45 : 0), radius: 16, x: 0, y: 8)
        .animation(.easeOut(duration: 0.15), value: isFocused)
        .accessibilityLabel(L10n.text(tab.titleKey))
    }
}

private extension HomeTab {
    var titleKey: String.LocalizationValue {
        switch self {
        case .home: return "Home"
        case .movies: return "Movies"
        case .tvShows: return "TV Shows"
        case .search: return "Search"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .movies: return "film"
        case .tvShows: return "tv"
        case .search: return "magnifyingglass"
        case .settings: return "gearshape"
        }
    }
}

private struct CatalogHomeView: View {
    @EnvironmentObject private var appModel: AppModel
    let focusTopNavigation: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 32) {
                    if appModel.isCatalogLoading && appModel.homeSections.isEmpty {
                        ProgressView(L10n.text("Loading catalog"))
                            .padding(.horizontal, 72)
                            .padding(.top, 72)
                    }

                    if !appModel.homeHeroItems.isEmpty {
                        FeaturedHeroCarousel(
                            items: appModel.homeHeroItems,
                            heroHeight: heroHeight(for: proxy),
                            focusTopNavigation: focusTopNavigation
                        )
                            .frame(width: proxy.size.width)
                            .padding(.top, -proxy.safeAreaInsets.top)
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
                    .padding(.horizontal, 72)
                    .padding(.bottom, 46)
                }
            }
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
        }
    }

    private func heroHeight(for proxy: GeometryProxy) -> CGFloat {
        min(max(proxy.size.height * 0.7, 580), 760)
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
