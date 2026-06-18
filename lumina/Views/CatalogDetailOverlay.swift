//
//  CatalogDetailOverlay.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct CatalogDetailPage: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedAction: DetailAction?

    let item: CatalogItem

    var body: some View {
        ZStack(alignment: .topLeading) {
            DetailBackdropImage(url: appModel.artworkURL(for: item.backdropPath ?? item.posterPath, kind: .backdrop))
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.9),
                    .black.opacity(0.42),
                    .black.opacity(0.05)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.48),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 42) {
                    DetailHero(focusedAction: $focusedAction, item: item)
                        .padding(.top, TVLayout.detailHeroTopPadding)
                        .padding(.horizontal, TVLayout.safeHorizontalPadding)
                        .frame(maxWidth: TVLayout.detailContentMaxWidth, alignment: .leading)

                    DetailPeopleShelves(item: item)
                        .padding(.horizontal, TVLayout.safeHorizontalPadding)

                    VStack(alignment: .leading, spacing: 42) {
                        if item.mediaType == "tv_show" {
                            TVSeasonEpisodeSection()
                        }

                        if appModel.isDetailLoading {
                            ProgressView(L10n.text("Loading details"))
                                .font(.headline)
                                .padding(.vertical, 8)
                        }

                        StatusText(message: appModel.statusMessage)
                    }
                    .padding(.horizontal, TVLayout.safeHorizontalPadding)
                    .frame(maxWidth: TVLayout.detailContentMaxWidth, alignment: .leading)
                }
                .padding(.bottom, TVLayout.contentBottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            DetailMainMenu()
                .padding(.top, TVLayout.detailMenuTopPadding)
                .padding(.horizontal, TVLayout.safeHorizontalPadding)
        }
        .ignoresSafeArea(.container, edges: .horizontal)
        .background(Color.black.ignoresSafeArea())
        .onExitCommand {
            appModel.closeCatalogDetail()
        }
        .onAppear {
            if isPlayableMovie {
                focusedAction = .play
            }
        }
        .defaultFocus($focusedAction, .play)
    }

    private var isPlayableMovie: Bool {
        item.mediaType == "movie" && item.hasPlayableMedia != false
    }
}

private struct DetailMainMenu: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focusedTab: HomeTab?

    private let items: [(tab: HomeTab, title: String, systemImage: String)] = [
        (.home, L10n.text("Home"), "house"),
        (.movies, L10n.text("Movies"), "film"),
        (.tvShows, L10n.text("TV Shows"), "tv"),
        (.search, L10n.text("Search"), "magnifyingglass"),
        (.settings, L10n.text("Settings"), "gearshape")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(items, id: \.tab) { item in
                Button {
                    appModel.openHomeTab(item.tab)
                } label: {
                    Label(item.title, systemImage: item.systemImage)
                        .font(.system(size: 23, weight: .semibold))
                        .labelStyle(.titleAndIcon)
                        .frame(minWidth: item.tab == .tvShows ? 158 : 128)
                }
                .buttonStyle(DetailMenuButtonStyle(isSelected: appModel.selectedHomeTab == item.tab))
                .focused($focusedTab, equals: item.tab)
                .modifier(DetailMenuFocusModifier(isFocused: focusedTab == item.tab))
            }
        }
        .padding(8)
        .background(.black.opacity(0.34), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct DetailMenuButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? .black : .white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                isSelected ? .white.opacity(configuration.isPressed ? 0.74 : 0.9) : .white.opacity(configuration.isPressed ? 0.18 : 0.08),
                in: Capsule()
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct DetailMenuFocusModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isFocused ? 1.05 : 1)
            .shadow(color: .white.opacity(isFocused ? 0.28 : 0), radius: 14, x: 0, y: 0)
            .animation(.easeOut(duration: 0.16), value: isFocused)
    }
}

private enum DetailAction: Hashable {
    case play
    case watchlist
    case favorite
}

private struct DetailHero: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var focusedAction: DetailAction?

    let item: CatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 16) {
                DetailTitleMark(item: item)

                DetailMetadataRow(values: item.detailMetadata)
            }

            if let overview = item.overview, !overview.isEmpty {
                Text(overview)
                    .font(.system(size: 29, weight: .regular))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(4)
                    .lineSpacing(5)
                    .frame(maxWidth: 960, alignment: .leading)
            }

            DetailHeroProgress(item: item)
            DetailMembershipRow(item: item)

            HStack(alignment: .center, spacing: 14) {
                if item.mediaType == "movie" {
                    Button {
                        Task { await appModel.playCatalogMovie(item) }
                    } label: {
                        Label(item.primaryActionTitle, systemImage: "play.fill")
                            .font(.system(size: 29, weight: .bold))
                            .frame(minWidth: 192)
                    }
                    .buttonStyle(DetailActionButtonStyle(isPrimary: true))
                    .disabled(item.hasPlayableMedia == false)
                    .focused($focusedAction, equals: .play)
                    .modifier(DetailActionFocusModifier(isFocused: focusedAction == .play))
                    .accessibilityHint(L10n.text("Starts playback"))
                }

                if appModel.canToggleWatchlist(for: item) {
                    Button {
                        Task { await appModel.toggleWatchlist(item) }
                    } label: {
                        Label(item.watchlistActionTitle, systemImage: item.isWatchlisted == true ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 29, weight: .bold))
                            .frame(minWidth: 220)
                    }
                    .buttonStyle(DetailActionButtonStyle(isPrimary: false))
                    .focused($focusedAction, equals: .watchlist)
                    .modifier(DetailActionFocusModifier(isFocused: focusedAction == .watchlist))
                    .accessibilityHint(L10n.text("Updates watchlist"))
                }

                if appModel.canToggleFavorite(for: item) {
                    Button {
                        Task { await appModel.toggleFavorite(item) }
                    } label: {
                        Label(item.favoriteActionTitle, systemImage: item.isFavorite == true ? "heart.fill" : "heart")
                            .font(.system(size: 29, weight: .bold))
                            .frame(minWidth: 210)
                    }
                    .buttonStyle(DetailActionButtonStyle(isPrimary: false))
                    .focused($focusedAction, equals: .favorite)
                    .modifier(DetailActionFocusModifier(isFocused: focusedAction == .favorite))
                    .accessibilityHint(L10n.text("Updates favorites"))
                }

                TrailerUnavailableLabel(isVisible: item.primaryTrailerTitle != nil)
            }
        }
        .frame(maxWidth: 1040, alignment: .leading)
    }
}

private struct TrailerUnavailableLabel: View {
    let isVisible: Bool

    var body: some View {
        if isVisible {
            Label(L10n.text("Trailer unavailable"), systemImage: "film.stack")
                .font(.system(size: 29, weight: .bold))
                .foregroundStyle(.white.opacity(0.64))
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(.white.opacity(0.08), in: Capsule())
                .accessibilityLabel(L10n.text("Trailer unavailable"))
        }
    }
}

private struct DetailBackdropImage: View {
    let url: URL?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)

            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.28))
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "play.rectangle")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

private struct DetailTitleMark: View {
    @EnvironmentObject private var appModel: AppModel
    let item: CatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let logoURL = appModel.artworkURL(for: item.logoPath, kind: .logo) {
                AsyncImage(url: logoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        titleText
                    }
                }
                .frame(maxWidth: 620, maxHeight: 180, alignment: .leading)
            } else {
                titleText
            }

            Text(item.mediaTypeDisplayName.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.58))
                .tracking(1.6)
        }
    }

    private var titleText: some View {
        Text(item.title)
            .font(.system(size: 68, weight: .bold))
            .lineLimit(2)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: 960, alignment: .leading)
    }
}

private struct DetailMembershipRow: View {
    let item: CatalogItem

    var body: some View {
        if item.isWatchlisted == true || item.isFavorite == true {
            HStack(spacing: 10) {
                if item.isWatchlisted == true {
                    Label(L10n.text("Watchlist"), systemImage: "bookmark.fill")
                }

                if item.isFavorite == true {
                    Label(L10n.text("Favorite"), systemImage: "heart.fill")
                }
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white.opacity(0.72))
            .labelStyle(.titleAndIcon)
        }
    }
}

private struct DetailHeroProgress: View {
    let item: CatalogItem

    var body: some View {
        if item.progressPercent > 0 {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.watchedPercent(Int(item.progressPercent.rounded())))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))

                ProgressView(value: min(max(item.progressPercent / 100, 0), 1))
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .frame(width: 420)
            }
            .padding(.top, 2)
        }
    }
}

private struct DetailPeopleShelves: View {
    let item: CatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 34) {
            if !item.cast.isEmpty {
                DetailPersonShelf(
                    title: L10n.text("Cast"),
                    people: item.cast,
                    textStyle: .cast
                )
            }

            if !item.behindTheScenesPeople.isEmpty {
                DetailPersonShelf(
                    title: L10n.text("Behind the Scenes"),
                    people: item.behindTheScenesPeople,
                    textStyle: .crew
                )
            }

            if item.cast.isEmpty && item.behindTheScenesPeople.isEmpty {
                DetailEmptyPeopleShelf()
            }
        }
    }
}

private struct DetailActionButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isPrimary ? .black : .white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                isPrimary ? .white.opacity(configuration.isPressed ? 0.78 : 0.94) : .white.opacity(0.1),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(.white.opacity(isPrimary ? 0 : 0.14), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct DetailActionFocusModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isFocused ? 1.06 : 1)
            .shadow(color: .white.opacity(isFocused ? 0.34 : 0), radius: 18, x: 0, y: 0)
            .animation(.easeOut(duration: 0.16), value: isFocused)
    }
}

private struct DetailPersonShelf: View {
    let title: String
    let people: [CatalogPersonCredit]
    let textStyle: PersonCreditCardTextStyle

    var body: some View {
        VStack(alignment: .leading, spacing: TVLayout.shelfTitleSpacing) {
            Text(title)
                .tvSectionTitle()

            ScrollView(.horizontal) {
                LazyHStack(spacing: 24) {
                    ForEach(people.prefix(18)) { person in
                        PersonCreditButton(person: person, textStyle: textStyle)
                    }
                }
                .padding(.vertical, TVLayout.compactShelfFocusGutter)
                .padding(.leading, TVLayout.safeHorizontalPadding)
                .padding(.trailing, TVLayout.safeHorizontalPadding)
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .scrollClipDisabled()
            .padding(.horizontal, -TVLayout.safeHorizontalPadding)
        }
    }
}

private struct DetailEmptyPeopleShelf: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .tvSectionTitle()

            Text("Cast and behind-the-scenes credits are not available for this title yet.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.62))
                .padding(.vertical, 18)
        }
    }
}

private struct DetailMetadataRow: View {
    let values: [String]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
                    .lineLimit(1)

                if value != values.last {
                    Circle()
                        .fill(.white.opacity(0.36))
                        .frame(width: 5, height: 5)
                }
            }
        }
    }
}

private struct TVSeasonEpisodeSection: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Seasons")
                .tvSectionTitle()

            if appModel.selectedTVSeasons.isEmpty && !appModel.isDetailLoading {
                EmptyCatalogState(title: L10n.text("No seasons found"))
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 14) {
                        ForEach(appModel.selectedTVSeasons) { season in
                            DetailSeasonButton(
                                season: season,
                                isSelected: appModel.selectedSeasonNumber == season.seasonNumber
                            )
                        }
                    }
                    .padding(.vertical, 6)
                }
                .scrollClipDisabled()
            }

            if !appModel.selectedTVEpisodes.isEmpty {
                CatalogShelfView(
                    title: L10n.text("Episodes"),
                    items: appModel.selectedTVEpisodes,
                    contentHorizontalInset: TVLayout.safeHorizontalPadding
                )
                .padding(.horizontal, -TVLayout.safeHorizontalPadding)
            } else if appModel.selectedSeasonNumber != nil && !appModel.isDetailLoading {
                EmptyCatalogState(title: L10n.text("No episodes found"))
            }
        }
    }
}

private struct DetailSeasonButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let season: TVSeasonSummary
    let isSelected: Bool

    var body: some View {
        Button {
            Task { await appModel.selectTVSeason(season) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "rectangle.stack")
                    .font(.headline.weight(.semibold))
                Text(season.title)
                    .font(.headline.weight(.semibold))
            }
            .frame(minWidth: 150)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                isSelected ? .white.opacity(0.2) : .white.opacity(0.08),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(
                        isFocused ? .white.opacity(0.34) : .white.opacity(isSelected ? 0.38 : 0.12),
                        lineWidth: 1
                    )
            }
        }
        .tvMediaCatalogButton()
        .focused($isFocused)
    }
}

private extension CatalogItem {
    var primaryActionTitle: String {
        if progressPercent > 0 {
            return L10n.text("Resume")
        }
        return L10n.text("Play")
    }

    var trailerActionTitle: String {
        L10n.text("Trailer")
    }

    var watchlistActionTitle: String {
        isWatchlisted == true ? L10n.text("Remove") : L10n.text("Watchlist")
    }

    var favoriteActionTitle: String {
        isFavorite == true ? L10n.text("Unfavorite") : L10n.text("Favorite")
    }

    var behindTheScenesPeople: [CatalogPersonCredit] {
        crew.filter { credit in
            guard let label = credit.role?.lowercased() ?? credit.department?.lowercased() else {
                return true
            }
            return !label.contains("cast")
        }
    }
}
