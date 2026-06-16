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
    @State private var backgroundPalette = HomeBackgroundPalette.default
    @State private var backgroundPaletteTask: Task<Void, Never>?

    private enum Layout {
        static let horizontalPadding: CGFloat = TVLayout.safeHorizontalPadding
        static let shelfSpacing: CGFloat = TVLayout.shelfSpacing
        static let heroShelfSpacing: CGFloat = TVLayout.heroShelfSpacing
        static let topPadding: CGFloat = TVLayout.contentTopPadding
        static let bottomPadding: CGFloat = TVLayout.contentBottomPadding
        static let backgroundDebounceNanoseconds: UInt64 = 320_000_000
    }

    var body: some View {
        GeometryReader { geometry in
            homeContent(availableHeight: geometry.size.height)
        }
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
        .onAppear {
            resetHeroSelectionIfNeeded()
        }
        .onChange(of: appModel.homeSections) { _, _ in
            resetHeroSelectionIfNeeded()
        }
        .onDisappear {
            backgroundPaletteTask?.cancel()
        }
    }

    private func homeContent(availableHeight: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            HomeDynamicBackground(palette: backgroundPalette)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                if appModel.isCatalogLoading && appModel.homeSections.isEmpty {
                    ProgressView(L10n.text("Loading catalog"))
                        .padding(.horizontal, Layout.horizontalPadding)
                        .padding(.top, Layout.topPadding)
                }

                if let selectedHeroItem {
                    ContextualHomeHeroView(item: selectedHeroItem, availableHeight: availableHeight)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            scheduleBackgroundPaletteUpdate(for: nil)
            return
        }
        guard let selectedHeroItem else {
            self.selectedHeroItem = firstItem
            scheduleBackgroundPaletteUpdate(for: firstItem, debounce: false)
            return
        }
        if heroControllingSection?.items.contains(selectedHeroItem) != true {
            self.selectedHeroItem = firstItem
            scheduleBackgroundPaletteUpdate(for: firstItem, debounce: false)
        }
    }

    private func selectHeroItem(_ item: CatalogItem) {
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedHeroItem = item
        }
        scheduleBackgroundPaletteUpdate(for: item)
    }

    private func scheduleBackgroundPaletteUpdate(for item: CatalogItem?, debounce: Bool = true) {
        let palette = HomeBackgroundPalette(item: item)
        backgroundPaletteTask?.cancel()
        backgroundPaletteTask = Task {
            if debounce {
                try? await Task.sleep(nanoseconds: Layout.backgroundDebounceNanoseconds)
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeInOut(duration: 1.45)) {
                    backgroundPalette = palette
                }
            }
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

private struct HomeDynamicBackground: View {
    let palette: HomeBackgroundPalette

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    palette.background,
                    palette.backgroundSecondary,
                    .black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    palette.accent.opacity(0.34),
                    palette.accent.opacity(0.12),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 120,
                endRadius: 980
            )

            LinearGradient(
                colors: [
                    .black.opacity(0.18),
                    .black.opacity(0.56)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .animation(.easeInOut(duration: 1.45), value: palette)
    }
}

private struct HomeBackgroundPalette: Equatable {
    let backgroundHex: String?
    let backgroundSecondaryHex: String?
    let accentHex: String?

    static let `default` = HomeBackgroundPalette(
        backgroundHex: "#000000",
        backgroundSecondaryHex: "#050507",
        accentHex: "#101014"
    )

    init(
        backgroundHex: String?,
        backgroundSecondaryHex: String?,
        accentHex: String?
    ) {
        self.backgroundHex = backgroundHex
        self.backgroundSecondaryHex = backgroundSecondaryHex
        self.accentHex = accentHex
    }

    init(item: CatalogItem?) {
        guard let colors = item?.colors else {
            self = .default
            return
        }
        self.backgroundHex = colors.background
        self.backgroundSecondaryHex = colors.backgroundSecondary
        self.accentHex = colors.accent
    }

    var background: Color {
        Color(hex: backgroundHex) ?? .black
    }

    var backgroundSecondary: Color {
        Color(hex: backgroundSecondaryHex) ?? Color(red: 0.02, green: 0.02, blue: 0.03)
    }

    var accent: Color {
        Color(hex: accentHex) ?? Color(red: 0.08, green: 0.08, blue: 0.09)
    }
}

private extension Color {
    init?(hex: String?) {
        guard let hex else {
            return nil
        }

        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
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
        GridItem(.adaptive(minimum: 250, maximum: 270), spacing: 34)
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
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 34) {
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
                        .font(.system(size: 31, weight: .medium))
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
                            .font(.system(size: 31, weight: .semibold))
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
