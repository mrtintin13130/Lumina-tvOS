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
        TVMediaDetailLayout {
            HomeDynamicBackground(
                palette: HomeBackgroundPalette(item: item),
                animates: false
            )
                .ignoresSafeArea()
        } content: {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 42) {
                    DetailContextualHero(focusedAction: $focusedAction, item: item)

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
        }
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

private struct DetailContextualHero: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var focusedAction: DetailAction?

    let item: CatalogItem

    private let artworkTopBleedHeight: CGFloat = 120
    private let artworkBottomBleedHeight: CGFloat = 60
    private let topFadeHeight: CGFloat = 210
    private let minBottomFadeHeight: CGFloat = 300
    private let maxBottomFadeHeight: CGFloat = 520
    private let bottomFadeHeightRatio: CGFloat = 0.66

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear

            DetailContextualHeroBackdrop(
                url: appModel.artworkURL(
                    for: item.heroBackdropPath,
                    kind: .backdrop
                ),
                topFadeHeight: topFadeHeight,
                bottomFadeHeight: artworkBottomFadeHeight
            )
            .frame(width: heroArtworkWidth, height: heroArtworkHeight, alignment: .topTrailing)
            .frame(maxWidth: .infinity, maxHeight: heroArtworkHeight, alignment: .topTrailing)
            .frame(height: heroHeight, alignment: .top)
            .offset(y: -artworkTopBleedHeight)
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .accessibilityHidden(true)

            DetailHero(focusedAction: $focusedAction, item: item)
                .padding(.horizontal, TVLayout.safeHorizontalPadding)
                .padding(.bottom, 66)
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .focusSection()
    }

    private var heroHeight: CGFloat {
        TVLayout.detailContextualHeroHeight
    }

    private var artworkBottomFadeHeight: CGFloat {
        let proposedHeight = heroArtworkHeight * bottomFadeHeightRatio
        return min(max(proposedHeight, minBottomFadeHeight), maxBottomFadeHeight)
    }

    private var heroArtworkWidth: CGFloat {
        heroArtworkHeight * 16 / 9
    }

    private var heroArtworkHeight: CGFloat {
        heroHeight + artworkTopBleedHeight + artworkBottomBleedHeight
    }
}

private enum DetailAction: Hashable {
    case play
    case watchlist
    case favorite
    case trailer
}

private struct DetailHero: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var focusedAction: DetailAction?

    let item: CatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
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
            }
            .frame(maxWidth: TVLayout.detailContentMaxWidth, alignment: .leading)

            LuminaActionRow(spacing: 16) {
                if item.mediaType == "movie" {
                    Button {
                        Task { await appModel.playCatalogMovie(item) }
                    } label: {
                        Label(item.primaryActionTitle, systemImage: "play.fill")
                    }
                    .buttonStyle(detailActionButtonStyle(role: .primary, action: .play))
                    .disabled(item.hasPlayableMedia == false)
                    .focused($focusedAction, equals: .play)
                    .accessibilityLabel(item.primaryActionTitle)
                    .accessibilityHint(L10n.text("Starts playback"))
                }

                if appModel.canToggleWatchlist(for: item) {
                    Button {
                        Task { await appModel.toggleWatchlist(item) }
                    } label: {
                        Label(item.watchlistActionTitle, systemImage: item.isWatchlisted == true ? "bookmark.fill" : "bookmark")
                    }
                    .buttonStyle(detailActionButtonStyle(role: .secondary, action: .watchlist))
                    .focused($focusedAction, equals: .watchlist)
                    .accessibilityLabel(item.watchlistActionTitle)
                    .accessibilityHint(L10n.text("Updates watchlist"))
                }

                if appModel.canToggleFavorite(for: item) {
                    Button {
                        Task { await appModel.toggleFavorite(item) }
                    } label: {
                        Label(item.favoriteActionTitle, systemImage: item.isFavorite == true ? "heart.fill" : "heart")
                    }
                    .buttonStyle(detailActionButtonStyle(role: .secondary, action: .favorite))
                    .focused($focusedAction, equals: .favorite)
                    .accessibilityLabel(item.favoriteActionTitle)
                    .accessibilityHint(L10n.text("Updates favorites"))
                }

                TrailerUnavailableButton(
                    isVisible: item.primaryTrailerTitle != nil,
                    focusedAction: $focusedAction
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func detailActionButtonStyle(
        role: LuminaActionButtonRole,
        action: DetailAction
    ) -> LuminaActionButtonStyle {
        let isFocused = focusedAction == action
        return LuminaActionButtonStyle(
            role: role,
            size: .regular,
            isFocused: isFocused,
            presentation: .expandable(isExpanded: isFocused)
        )
    }
}

private struct TrailerUnavailableButton: View {
    let isVisible: Bool
    @FocusState.Binding var focusedAction: DetailAction?

    private var isFocused: Bool {
        focusedAction == .trailer
    }

    var body: some View {
        if isVisible {
            Button {} label: {
                Label(L10n.text("Trailer unavailable"), systemImage: "film.stack")
            }
            .buttonStyle(
                LuminaActionButtonStyle(
                    role: .secondary,
                    size: .regular,
                    isFocused: isFocused,
                    presentation: .expandable(isExpanded: isFocused)
                )
            )
            .focused($focusedAction, equals: .trailer)
            .accessibilityLabel(L10n.text("Trailer unavailable"))
        }
    }
}

private struct DetailContextualHeroBackdrop: View {
    let url: URL?
    let topFadeHeight: CGFloat
    let bottomFadeHeight: CGFloat

    var body: some View {
        ZStack(alignment: .trailing) {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                            .mask(leftFadeMask)
                            .mask(topFadeMask)
                            .mask(bottomFadeMask)

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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }

    private var leftFadeMask: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: 0.12),
                .init(color: .black.opacity(0.24), location: 0.26),
                .init(color: .black.opacity(0.78), location: 0.5),
                .init(color: .black, location: 0.72)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var topFadeMask: some View {
        VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black.opacity(0.2), location: 0.28),
                    .init(color: .black.opacity(0.78), location: 0.68),
                    .init(color: .black, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: topFadeHeight)

            Color.black
        }
    }

    private var bottomFadeMask: some View {
        VStack(spacing: 0) {
            Color.black

            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black.opacity(0.78), location: 0.32),
                    .init(color: .black.opacity(0.24), location: 0.64),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: bottomFadeHeight)
        }
    }

    private func placeholderIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 70, weight: .semibold))
            .foregroundStyle(.white.opacity(0.28))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .padding(.trailing, TVLayout.safeHorizontalPadding)
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
