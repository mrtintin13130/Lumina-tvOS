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
                topPadding: TVLayout.contentTopPadding
            )
            .tag(HomeTab.movies)
            .tabItem {
                Label(L10n.text("Movies"), systemImage: "film")
            }

            CatalogGridView(
                title: L10n.text("TV Shows"),
                items: appModel.tvShows,
                emptyTitle: L10n.text("No TV shows found"),
                topPadding: TVLayout.contentTopPadding
            )
            .tag(HomeTab.tvShows)
            .tabItem {
                Label(L10n.text("TV Shows"), systemImage: "tv")
            }

            CatalogSearchView(topPadding: TVLayout.contentTopPadding)
                .tag(HomeTab.search)
                .tabItem {
                    Label(L10n.text("Search"), systemImage: "magnifyingglass")
                }

            SettingsView(topPadding: TVLayout.safeTopPadding)
                .tag(HomeTab.settings)
                .tabItem {
                    Label(L10n.text("Settings"), systemImage: "gearshape")
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
        .task {
            if appModel.automaticCatalogRefreshEnabled {
                await appModel.loadCatalog()
            }
        }
    }
}

private struct CatalogHomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedHeroItem: CatalogItem?

    private enum Layout {
        static let horizontalPadding: CGFloat = TVLayout.safeHorizontalPadding
        static let shelfSpacing: CGFloat = TVLayout.shelfSpacing
        static let heroShelfSpacing: CGFloat = TVLayout.heroShelfSpacing
        static let topPadding: CGFloat = TVLayout.contentTopPadding
        static let bottomPadding: CGFloat = TVLayout.contentBottomPadding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if appModel.isCatalogLoading && appModel.homeSections.isEmpty {
                ProgressView(L10n.text("Loading catalog"))
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.top, Layout.topPadding)
            }

            if let selectedHeroItem {
                ContextualHomeHeroView(item: selectedHeroItem)
            }

            ScrollView(.vertical) {
                shelvesContent
                    .padding(.top, selectedHeroItem == nil ? Layout.shelfSpacing : Layout.heroShelfSpacing)
                    .padding(.bottom, Layout.bottomPadding)
            }
            .contentMargins(.all, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
        .onAppear {
            resetHeroSelectionIfNeeded()
        }
        .onChange(of: appModel.homeSections) { _, _ in
            resetHeroSelectionIfNeeded()
        }
    }

    private var shelvesContent: some View {
        VStack(alignment: .leading, spacing: 40) {
            ForEach(displayedHomeSections) { section in
                HomeCatalogSectionView(
                    section: section,
                    onItemFocus: selectHeroItem,
                    contentHorizontalInset: Layout.horizontalPadding
                )
            }

            if displayedHomeSections.isEmpty && !appModel.isCatalogLoading {
                EmptyCatalogState(title: L10n.text("No catalog shelves yet"))
                    .padding(.horizontal, Layout.horizontalPadding)
            }

            StatusText(message: appModel.statusMessage)
                .padding(.horizontal, Layout.horizontalPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var displayedHomeSections: [CatalogSection] {
        appModel.homeSections.filter { section in
            !section.items.isEmpty && section.homeLayout != .heroCarousel
        }
    }

    private var heroControllingSection: CatalogSection? {
        displayedHomeSections.first(where: isContinueWatchingSection)
            ?? displayedHomeSections.first(where: isNextUpSection)
            ?? displayedHomeSections.first(where: isRecentlyAddedMovieSection)
            ?? displayedHomeSections.first(where: isRecentlyAddedShowSection)
            ?? displayedHomeSections.first
    }

    private func resetHeroSelectionIfNeeded() {
        guard let firstItem = heroControllingSection?.items.first else {
            selectedHeroItem = nil
            return
        }
        guard let selectedHeroItem else {
            self.selectedHeroItem = firstItem
            return
        }
        if heroControllingSection?.items.contains(selectedHeroItem) != true {
            self.selectedHeroItem = firstItem
        }
    }

    private func selectHeroItem(_ item: CatalogItem) {
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedHeroItem = item
        }
    }

    private func isContinueWatchingSection(_ section: CatalogSection) -> Bool {
        section.homeLayout == .continueLandscape
            || section.matchesHomeSectionKeywords(["continue", "watching", "resume"])
    }

    private func isNextUpSection(_ section: CatalogSection) -> Bool {
        section.matchesHomeSectionKeywords(["next", "up"])
    }

    private func isRecentlyAddedMovieSection(_ section: CatalogSection) -> Bool {
        section.mediaType == "movie"
            && section.matchesHomeSectionKeywords(["recently", "added"])
    }

    private func isRecentlyAddedShowSection(_ section: CatalogSection) -> Bool {
        (section.mediaType == "tv_show" || section.mediaType == "show")
            && section.matchesHomeSectionKeywords(["recently", "added"])
    }
}

private extension CatalogSection {
    func matchesHomeSectionKeywords(_ keywords: [String]) -> Bool {
        let values = [id, title, type, mediaType]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")
        return keywords.allSatisfy { values.contains($0) }
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
            .padding(.horizontal, TVLayout.safeHorizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, TVLayout.contentBottomPadding)
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
            .padding(.horizontal, TVLayout.safeHorizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, TVLayout.contentBottomPadding)
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
