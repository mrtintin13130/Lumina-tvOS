//
//  CatalogComponents.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

enum TVLayout {
    static let safeHorizontalPadding: CGFloat = 80
    static let compactHorizontalPadding: CGFloat = 72
    static let safeTopPadding: CGFloat = 60
    static let contentTopPadding: CGFloat = 46
    static let contentBottomPadding: CGFloat = 56
    static let shelfSpacing: CGFloat = 36
    static let heroShelfSpacing: CGFloat = 0
    static let shelfTitleSpacing: CGFloat = 14
    static let shelfItemSpacing: CGFloat = 26
    static let compactShelfItemSpacing: CGFloat = 22
    static let shelfFocusGutter: CGFloat = 26
    static let compactShelfFocusGutter: CGFloat = 22
    static let detailContentMaxWidth: CGFloat = 1360
    static let detailHeroTopPadding: CGFloat = 290
    static let detailMenuTopPadding: CGFloat = 48
    static let setupContentMaxWidth: CGFloat = 1120
}

struct TVMediaCatalogButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderless)
    }
}

extension View {
    func tvMediaCatalogButton() -> some View {
        modifier(TVMediaCatalogButtonModifier())
    }

    func tvSectionTitle() -> some View {
        font(.system(size: 32, weight: .bold))
    }
}

struct CatalogHeader: View {
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

struct FeaturedCatalogButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let heroHeight: CGFloat = 660
    private let cornerRadius: CGFloat = 18
    private let focusedScale: CGFloat = 1.025

    var body: some View {
        Button {
            Task { await appModel.openCatalogDetail(item) }
        } label: {
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
                .accessibilityHidden(true)

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
                        .font(.system(size: 48, weight: .bold))
                        .lineLimit(2)
                        .frame(maxWidth: 780, alignment: .leading)

                    if let overview = item.overview {
                        Text(overview)
                            .font(.system(size: 29, weight: .medium))
                            .foregroundStyle(.white.opacity(0.76))
                            .lineLimit(2)
                            .frame(maxWidth: 860, alignment: .leading)
                    }

                    Label(L10n.text("Open Details"), systemImage: "info.circle")
                        .font(.system(size: 29, weight: .semibold))
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
                        isFocused ? .white.opacity(0.32) : .white.opacity(0.08),
                        lineWidth: 1
                    )
            }
        }
        .tvMediaCatalogButton()
        .shadow(
            color: .black.opacity(isFocused ? 0.55 : 0.25),
            radius: isFocused ? 26 : 14,
            x: 0,
            y: isFocused ? 16 : 8
        )
        .scaleEffect(isFocused ? focusedScale : 1)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
    }
}

struct FeaturedHeroCarousel: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool
    @State private var selectedIndex = 0

    let items: [CatalogItem]
    let heroHeight: CGFloat

    private let rotationTimer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()

    init(
        items: [CatalogItem],
        heroHeight: CGFloat = 660
    ) {
        self.items = items
        self.heroHeight = heroHeight
    }

    var body: some View {
        if let item = currentItem {
            ZStack(alignment: .bottomLeading) {
                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: item.backdropPath ?? item.posterPath,
                        kind: .backdrop
                    ),
                    aspectRatio: 16 / 9,
                    alignment: .bottom
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)

                LinearGradient(
                    colors: [
                        .black.opacity(0.88),
                        .black.opacity(0.48),
                        .black.opacity(0.08)
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

                VStack(alignment: .leading, spacing: 18) {
                    Text("Featured")
                        .font(.system(size: 27, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.72))

                    Text(item.title)
                        .font(.system(size: 70, weight: .bold))
                        .lineLimit(2)
                        .frame(maxWidth: 900, alignment: .leading)

                    if let overview = item.overview {
                        Text(overview)
                            .font(.system(size: 31, weight: .medium))
                            .foregroundStyle(.white.opacity(0.78))
                            .lineLimit(2)
                            .frame(maxWidth: 940, alignment: .leading)
                    }

                    Button {
                        Task { await appModel.openCatalogDetail(item) }
                    } label: {
                        Label(L10n.text("Open Details"), systemImage: "info.circle.fill")
                            .font(.system(size: 31, weight: .semibold))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.16), in: Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(.white.opacity(0.22), lineWidth: 1)
                            }
                    }
                    .tvMediaCatalogButton()
                    .focused($isFocused)
                    .padding(.top, 8)
                    .accessibilityLabel(item.accessibilitySummary)
                    .accessibilityHint(L10n.text("Opens details"))
                }
                .padding(.leading, 76)
                .padding(.bottom, 74)

                if items.count > 1 {
                    HStack(spacing: 12) {
                        ForEach(items.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == selectedIndex ? .white : .white.opacity(0.34))
                                .frame(width: index == selectedIndex ? 42 : 18, height: 8)
                        }
                    }
                    .padding(.trailing, 76)
                    .padding(.bottom, 78)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight)
            .clipped()
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(isFocused ? .white.opacity(0.32) : .clear)
                    .frame(height: 3)
            }
            .onReceive(rotationTimer) { _ in
                guard items.count > 1 else { return }
                showNextSlide()
            }
            .onChange(of: items) { _, newItems in
                selectedIndex = min(selectedIndex, max(newItems.count - 1, 0))
            }
        }
    }

    private var currentItem: CatalogItem? {
        guard !items.isEmpty else { return nil }
        return items[min(selectedIndex, items.count - 1)]
    }

    private func showPreviousSlide() {
        withAnimation(.easeInOut(duration: 0.35)) {
            selectedIndex = (selectedIndex - 1 + items.count) % items.count
        }
    }

    private func showNextSlide() {
        withAnimation(.easeInOut(duration: 0.35)) {
            selectedIndex = (selectedIndex + 1) % items.count
        }
    }
}

struct ContextualHomeHeroView: View {
    @EnvironmentObject private var appModel: AppModel

    let item: CatalogItem
    let availableHeight: CGFloat?

    private let textHorizontalPadding: CGFloat = TVLayout.safeHorizontalPadding
    private let fallbackHeroHeight: CGFloat = 540
    private let minHeroHeight: CGFloat = 430
    private let maxHeroHeight: CGFloat = 600
    private let preferredHeroHeightRatio: CGFloat = 0.5
    private let minBottomFadeHeight: CGFloat = 240
    private let maxBottomFadeHeight: CGFloat = 430
    private let bottomFadeHeightRatio: CGFloat = 0.64
    private let artworkBleedHeight: CGFloat = 150

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear

            ContextualHeroBackdrop(
                url: appModel.artworkURL(
                    for: item.heroBackdropPath,
                    kind: .backdrop
                ),
                bottomFadeHeight: artworkBottomFadeHeight
            )
            .frame(width: heroArtworkWidth, height: heroArtworkHeight, alignment: .topTrailing)
            .frame(maxWidth: .infinity, maxHeight: heroArtworkHeight, alignment: .topTrailing)
            .frame(height: heroHeight, alignment: .top)
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Text(item.mediaTypeDisplayName)
                    if item.progressPercent > 0 {
                        Text(L10n.watchedPercent(Int(item.progressPercent.rounded())))
                    }
                }
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))

                Text(item.title)
                    .font(.system(size: 62, weight: .bold))
                    .lineLimit(2)
                    .frame(maxWidth: 920, alignment: .leading)

                if !item.detailMetadata.isEmpty {
                    Text(item.detailMetadata.joined(separator: "  -  "))
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(1)
                } else if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(1)
                }

                if item.progressPercent > 0 {
                    ProgressView(value: min(max(item.progressPercent / 100, 0), 1))
                        .progressViewStyle(.linear)
                        .frame(width: 420, height: 6)
                        .padding(.top, 2)
                }

                if let overview = item.overview {
                    Text(overview)
                        .font(.system(size: 29, weight: .medium))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                        .frame(maxWidth: 960, alignment: .leading)
                        .padding(.top, 2)
                }
            }
            .id(item.id)
            .transition(.opacity)
            .padding(.leading, textHorizontalPadding)
            .padding(.trailing, textHorizontalPadding)
            .padding(.bottom, TVLayout.contentTopPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.accessibilitySummary)
    }

    private var heroHeight: CGFloat {
        guard let availableHeight, availableHeight > 0 else {
            return fallbackHeroHeight
        }
        let proposedHeight = availableHeight * preferredHeroHeightRatio
        return min(max(proposedHeight, minHeroHeight), maxHeroHeight)
    }

    private var artworkBottomFadeHeight: CGFloat {
        let proposedHeight = heroArtworkHeight * bottomFadeHeightRatio
        return min(max(proposedHeight, minBottomFadeHeight), maxBottomFadeHeight)
    }

    private var heroArtworkWidth: CGFloat {
        heroArtworkHeight * 16 / 9
    }

    private var heroArtworkHeight: CGFloat {
        heroHeight + artworkBleedHeight
    }
}

private struct ContextualHeroBackdrop: View {
    let url: URL?
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

struct HomeCatalogSectionView: View {
    let section: CatalogSection
    let onItemFocus: ((CatalogItem) -> Void)?
    let contentHorizontalInset: CGFloat

    init(
        section: CatalogSection,
        onItemFocus: ((CatalogItem) -> Void)? = nil,
        contentHorizontalInset: CGFloat = 0
    ) {
        self.section = section
        self.onItemFocus = onItemFocus
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        switch section.homeLayout {
        case .heroCarousel:
            FeaturedHeroCarousel(items: section.items)
        case .continueLandscape:
            ContinueWatchingShelfView(
                title: section.title,
                items: section.items,
                onItemFocus: onItemFocus,
                contentHorizontalInset: contentHorizontalInset
            )
        case .genrePills:
            GenrePillSection(title: section.title, items: section.items, contentHorizontalInset: contentHorizontalInset)
        case .compactRail:
            CompactCatalogShelfView(
                title: section.title,
                items: section.items,
                onItemFocus: onItemFocus,
                contentHorizontalInset: contentHorizontalInset
            )
        case .logoCardRail:
            LogoCardShelfView(
                title: section.title,
                items: section.items,
                onItemFocus: onItemFocus,
                contentHorizontalInset: contentHorizontalInset
            )
        case .landscapeRail:
            CatalogLandscapeShelfView(
                title: section.title,
                items: section.items,
                onItemFocus: onItemFocus,
                contentHorizontalInset: contentHorizontalInset
            )
        case .editorialBanner:
            EditorialBannerSectionView(section: section)
                .padding(.horizontal, contentHorizontalInset)
        case .posterRail:
            CatalogShelfView(
                title: section.title,
                items: section.items,
                onItemFocus: onItemFocus,
                contentHorizontalInset: contentHorizontalInset
            )
        }
    }
}

enum HomeSectionLayout: Equatable {
    case heroCarousel
    case continueLandscape
    case genrePills
    case compactRail
    case logoCardRail
    case landscapeRail
    case editorialBanner
    case posterRail
}

extension CatalogSection {
    var homeLayout: HomeSectionLayout {
        switch presentation?.layout {
        case "cinematic_carousel":
            return .heroCarousel
        case "continue_landscape":
            return .continueLandscape
        case "poster_rail":
            return .posterRail
        case "spotlight_rail":
            return .landscapeRail
        case "compact_rail":
            return .compactRail
        case "genre_pills":
            return .genrePills
        case "logo_card_rail":
            return .logoCardRail
        case "cinematic_banner":
            return .editorialBanner
        default:
            return .posterRail
        }
    }
}

struct GenrePillSection: View {
    let title: String
    let items: [CatalogItem]
    let contentHorizontalInset: CGFloat

    init(
        title: String,
        items: [CatalogItem],
        contentHorizontalInset: CGFloat = 0
    ) {
        self.title = title
        self.items = items
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .tvSectionTitle()
                .padding(.horizontal, contentHorizontalInset)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 18) {
                    ForEach(items) { item in
                        CatalogGenrePillButton(item: item)
                    }
                }
                .padding(.vertical, TVLayout.compactShelfFocusGutter)
                .padding(.leading, horizontalShelfPadding(TVLayout.shelfFocusGutter))
                .padding(.trailing, horizontalShelfPadding(TVLayout.shelfFocusGutter))
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalShelfPadding(_ defaultPadding: CGFloat) -> CGFloat {
        contentHorizontalInset > 0 ? contentHorizontalInset : defaultPadding
    }
}

struct CatalogGenrePillButton: View {
    let item: CatalogItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 25, weight: .semibold))

            Text(item.title)
                .font(.system(size: 31, weight: .semibold))
                .lineLimit(1)

            if let count = item.linkCount {
                Text("\(count)")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.black.opacity(0.72))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.78), in: Capsule())
            }
        }
        .foregroundStyle(.white.opacity(0.82))
        .padding(.horizontal, 28)
        .frame(height: 86)
        .background(.white.opacity(0.08), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
        .accessibilityLabel(item.linkCount.map { "\(item.title), \(L10n.titleCount($0))" } ?? item.title)
    }
}

struct ContinueWatchingShelfView: View {
    let title: String
    let items: [CatalogItem]
    let onItemFocus: ((CatalogItem) -> Void)?
    let contentHorizontalInset: CGFloat

    init(
        title: String,
        items: [CatalogItem],
        onItemFocus: ((CatalogItem) -> Void)? = nil,
        contentHorizontalInset: CGFloat = 0
    ) {
        self.title = title
        self.items = items
        self.onItemFocus = onItemFocus
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TVLayout.shelfTitleSpacing) {
            Text(title)
                .tvSectionTitle()
                .padding(.horizontal, contentHorizontalInset)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: TVLayout.shelfItemSpacing) {
                    ForEach(items) { item in
                        ContinueWatchingCardButton(item: item, onFocus: onItemFocus)
                    }
                }
                .padding(.vertical, TVLayout.shelfFocusGutter)
                .padding(.leading, horizontalShelfPadding(TVLayout.shelfFocusGutter))
                .padding(.trailing, horizontalShelfPadding(TVLayout.shelfFocusGutter))
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalShelfPadding(_ defaultPadding: CGFloat) -> CGFloat {
        contentHorizontalInset > 0 ? contentHorizontalInset : defaultPadding
    }
}

struct ContinueWatchingCardButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let onFocus: ((CatalogItem) -> Void)?

    init(
        item: CatalogItem,
        onFocus: ((CatalogItem) -> Void)? = nil
    ) {
        self.item = item
        self.onFocus = onFocus
    }

    private let cardWidth: CGFloat = 430
    private let cardHeight: CGFloat = 242
    private let focusedScale: CGFloat = 1.055
    private let cornerRadius: CGFloat = 12

    var body: some View {
        Button {
            Task { await appModel.openCatalogDetail(item) }
        } label: {
            ZStack(alignment: .bottomLeading) {
                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: item.backdropPath ?? item.posterPath,
                        kind: .backdrop
                    ),
                    aspectRatio: 16 / 9
                )
                .frame(width: cardWidth, height: cardHeight)
                .accessibilityHidden(true)

                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.18),
                        .black.opacity(0.88)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 7) {
                    Text(item.title)
                        .font(.system(size: 27, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(item.subtitle ?? L10n.text("Continue watching"))
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white.opacity(0.74))
                        .lineLimit(1)

                    ProgressView(value: min(max(item.progressPercent / 100, 0), 1))
                        .progressViewStyle(.linear)
                        .frame(width: cardWidth - 34, height: 6)
                        .padding(.top, 4)
                }
                .padding(17)
                .frame(width: cardWidth, alignment: .leading)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isFocused ? .white.opacity(0.34) : .white.opacity(0.08),
                        lineWidth: 1
                    )
            }
        }
        .tvMediaCatalogButton()
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(color: .black.opacity(isFocused ? 0.62 : 0.24), radius: isFocused ? 22 : 10, x: 0, y: isFocused ? 14 : 6)
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .onChange(of: isFocused) { _, focused in
            if focused {
                onFocus?(item)
            }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
    }
}

struct CatalogLandscapeShelfView: View {
    let title: String
    let items: [CatalogItem]
    let onItemFocus: ((CatalogItem) -> Void)?
    let contentHorizontalInset: CGFloat

    init(
        title: String,
        items: [CatalogItem],
        onItemFocus: ((CatalogItem) -> Void)? = nil,
        contentHorizontalInset: CGFloat = 0
    ) {
        self.title = title
        self.items = items
        self.onItemFocus = onItemFocus
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TVLayout.shelfTitleSpacing) {
            Text(title)
                .tvSectionTitle()
                .padding(.horizontal, contentHorizontalInset)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: TVLayout.shelfItemSpacing) {
                    ForEach(items) { item in
                        CatalogLandscapeButton(item: item, onFocus: onItemFocus)
                    }
                }
                .padding(.vertical, TVLayout.shelfFocusGutter)
                .padding(.leading, horizontalShelfPadding(TVLayout.shelfFocusGutter))
                .padding(.trailing, horizontalShelfPadding(TVLayout.shelfFocusGutter))
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalShelfPadding(_ defaultPadding: CGFloat) -> CGFloat {
        contentHorizontalInset > 0 ? contentHorizontalInset : defaultPadding
    }
}

struct CatalogLandscapeButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let onFocus: ((CatalogItem) -> Void)?

    init(
        item: CatalogItem,
        onFocus: ((CatalogItem) -> Void)? = nil
    ) {
        self.item = item
        self.onFocus = onFocus
    }

    private let cardWidth: CGFloat = 420
    private let cardHeight: CGFloat = 236
    private let focusedScale: CGFloat = 1.055
    private let cornerRadius: CGFloat = 12

    var body: some View {
        Button {
            Task { await appModel.openCatalogDetail(item) }
        } label: {
            ZStack(alignment: .bottomLeading) {
                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: item.backdropPath ?? item.posterPath,
                        kind: .backdrop
                    ),
                    aspectRatio: 16 / 9
                )
                .frame(width: cardWidth, height: cardHeight)
                .accessibilityHidden(true)

                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.2),
                        .black.opacity(0.86)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.system(size: 27, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(item.subtitle ?? item.mediaTypeDisplayName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(1)
                }
                .padding(16)
                .frame(width: cardWidth, alignment: .leading)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isFocused ? .white.opacity(0.34) : .white.opacity(0.08),
                        lineWidth: 1
                    )
            }
        }
        .tvMediaCatalogButton()
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(
            color: .black.opacity(isFocused ? 0.62 : 0.24),
            radius: isFocused ? 22 : 10,
            x: 0,
            y: isFocused ? 14 : 6
        )
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .onChange(of: isFocused) { _, focused in
            if focused {
                onFocus?(item)
            }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
    }
}

struct EditorialBannerSectionView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let section: CatalogSection

    private let bannerHeight: CGFloat = 360
    private let cornerRadius: CGFloat = 14

    var body: some View {
        Button {
            Task { await appModel.openEditorialSection(section) }
        } label: {
            ZStack(alignment: .leading) {
                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: section.items.first?.backdropPath ?? section.items.first?.posterPath,
                        kind: .backdrop
                    ),
                    aspectRatio: 16 / 9
                )
                .frame(maxWidth: .infinity)
                .frame(height: bannerHeight)
                .clipped()
                .accessibilityHidden(true)

                LinearGradient(
                    colors: editorialGradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                VStack(alignment: .leading, spacing: 13) {
                    if let eyebrow = section.eyebrow {
                        Text(eyebrow)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white.opacity(0.74))
                            .textCase(.uppercase)
                    }

                    Text(section.title)
                        .font(.system(size: 50, weight: .bold))
                        .lineLimit(2)
                        .frame(maxWidth: 820, alignment: .leading)

                    if let subtitle = section.subtitle {
                        Text(subtitle)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.white.opacity(0.78))
                            .lineLimit(2)
                            .frame(maxWidth: 880, alignment: .leading)
                    }

                    if !section.tags.isEmpty {
                        HStack(spacing: 10) {
                            ForEach(section.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 21, weight: .semibold))
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.16), in: Capsule())
                            }
                        }
                    }

                    Label(section.presentation?.viewAll?.label ?? L10n.text("View Collection"), systemImage: "rectangle.stack.fill")
                        .font(.system(size: 27, weight: .semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.16), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(0.18), lineWidth: 1)
                        }
                        .padding(.top, 4)
                }
                .padding(.horizontal, 36)
            }
            .frame(maxWidth: .infinity)
            .frame(height: bannerHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFocused ? .white.opacity(0.34) : .white.opacity(0.1), lineWidth: 1)
            }
        }
        .tvMediaCatalogButton()
        .scaleEffect(isFocused ? 1.018 : 1)
        .shadow(color: .black.opacity(isFocused ? 0.58 : 0.24), radius: isFocused ? 24 : 10, x: 0, y: isFocused ? 15 : 7)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .accessibilityLabel([section.eyebrow, section.title, section.subtitle].compactMap { $0 }.joined(separator: ", "))
        .accessibilityHint(L10n.text("Opens this editorial collection"))
    }

    private var editorialGradientColors: [Color] {
        switch section.presentation?.theme {
        case "warm":
            return [.black.opacity(0.9), .red.opacity(0.36), .black.opacity(0.12)]
        case "cool":
            return [.black.opacity(0.9), .cyan.opacity(0.26), .black.opacity(0.08)]
        case "muted":
            return [.black.opacity(0.9), .gray.opacity(0.32), .black.opacity(0.1)]
        default:
            return [.black.opacity(0.9), .black.opacity(0.42), .black.opacity(0.06)]
        }
    }
}

struct CatalogEditorialPage: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isCloseFocused: Bool

    let section: CatalogSection

    var body: some View {
        ZStack(alignment: .topLeading) {
            CatalogArtwork(
                url: appModel.artworkURL(
                    for: section.items.first?.backdropPath ?? section.items.first?.posterPath,
                    kind: .backdrop
                ),
                aspectRatio: 16 / 9
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            LinearGradient(
                colors: [.black.opacity(0.86), .black.opacity(0.62), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 30) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: TVLayout.shelfTitleSpacing) {
                            if let eyebrow = section.eyebrow {
                                Text(eyebrow)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.74))
                                    .textCase(.uppercase)
                            }

                            Text(section.title)
                                .font(.system(size: 64, weight: .bold))
                                .lineLimit(2)
                                .frame(maxWidth: 1000, alignment: .leading)

                            if let subtitle = section.subtitle {
                                Text(subtitle)
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.78))
                                    .lineLimit(2)
                                    .frame(maxWidth: 980, alignment: .leading)
                            }
                        }

                        Spacer()

                        Button {
                            appModel.closeEditorialSection()
                        } label: {
                            Label(L10n.text("Close"), systemImage: "xmark.circle.fill")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 44, weight: .semibold))
                                .frame(width: 74, height: 74)
                        }
                        .tvMediaCatalogButton()
                        .background(.white.opacity(0.12), in: Circle())
                        .overlay {
                            Circle()
                                .stroke(isCloseFocused ? .white.opacity(0.34) : .white.opacity(0.16), lineWidth: 1)
                        }
                        .scaleEffect(isCloseFocused ? 1.08 : 1)
                        .focused($isCloseFocused)
                        .accessibilityLabel(L10n.text("Close editorial collection"))
                    }

                    if !section.tags.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(section.tags.prefix(5), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 23, weight: .semibold))
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 7)
                                    .background(.white.opacity(0.14), in: Capsule())
                            }
                        }
                    }

                    if appModel.isEditorialLoading {
                        ProgressView(L10n.text("Loading collection"))
                            .padding(.top, 18)
                    } else if section.items.isEmpty {
                        EmptyCatalogState(title: L10n.text("No titles in this collection yet"))
                    } else {
                        CatalogLandscapeShelfView(title: L10n.text("Titles"), items: section.items)
                    }

                    StatusText(message: appModel.statusMessage)
                }
                .padding(.horizontal, TVLayout.safeHorizontalPadding)
                .padding(.top, TVLayout.safeTopPadding)
                .padding(.bottom, TVLayout.contentBottomPadding)
            }
        }
        .onExitCommand {
            appModel.closeEditorialSection()
        }
        .defaultFocus($isCloseFocused, true)
    }
}

struct ThemedCatalogSectionView: View {
    let title: String
    let items: [CatalogItem]
    let theme: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .tvSectionTitle()

            LazyVStack(spacing: 22) {
                ForEach(items) { item in
                    ThemedCatalogCardButton(item: item, theme: theme)
                }
            }
        }
    }
}

struct ThemedCatalogCardButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let theme: String?

    private let cardHeight: CGFloat = 330
    private let cornerRadius: CGFloat = 14

    var body: some View {
        Button {
            Task { await appModel.openCatalogDetail(item) }
        } label: {
            ZStack(alignment: .leading) {
                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: item.backdropPath ?? item.posterPath,
                        kind: .backdrop
                    ),
                    aspectRatio: 16 / 9
                )
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)
                .clipped()
                .accessibilityHidden(true)

                LinearGradient(
                    colors: themedGradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.system(size: 44, weight: .bold))
                        .lineLimit(2)
                        .frame(maxWidth: 820, alignment: .leading)

                    if let overview = item.overview {
                        Text(overview)
                            .font(.system(size: 27, weight: .medium))
                            .foregroundStyle(.white.opacity(0.76))
                            .lineLimit(2)
                            .frame(maxWidth: 900, alignment: .leading)
                    } else {
                        Text(item.subtitle ?? item.mediaTypeDisplayName)
                            .font(.system(size: 27, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                }
                .padding(.horizontal, 34)
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFocused ? .white.opacity(0.34) : .white.opacity(0.1), lineWidth: 1)
            }
        }
        .tvMediaCatalogButton()
        .scaleEffect(isFocused ? 1.025 : 1)
        .shadow(color: .black.opacity(isFocused ? 0.58 : 0.24), radius: isFocused ? 24 : 10, x: 0, y: isFocused ? 16 : 7)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
    }

    private var themedGradientColors: [Color] {
        switch theme {
        case "warm":
            return [.black.opacity(0.86), .red.opacity(0.34), .clear]
        case "cool":
            return [.black.opacity(0.86), .teal.opacity(0.28), .clear]
        case "muted":
            return [.black.opacity(0.88), .gray.opacity(0.28), .clear]
        default:
            return [.black.opacity(0.86), .black.opacity(0.36), .clear]
        }
    }
}

struct CatalogShelfView: View {
    let title: String
    let items: [CatalogItem]
    let onItemFocus: ((CatalogItem) -> Void)?
    let contentHorizontalInset: CGFloat

    init(
        title: String,
        items: [CatalogItem],
        onItemFocus: ((CatalogItem) -> Void)? = nil,
        contentHorizontalInset: CGFloat = 0
    ) {
        self.title = title
        self.items = items
        self.onItemFocus = onItemFocus
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TVLayout.shelfTitleSpacing) {
            Text(title)
                .tvSectionTitle()
                .padding(.horizontal, contentHorizontalInset)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: TVLayout.shelfItemSpacing) {
                    ForEach(items) { item in
                        CatalogPosterButton(item: item, onFocus: onItemFocus)
                    }
                }
                .padding(.vertical, TVLayout.shelfFocusGutter)
                .padding(.leading, horizontalShelfPadding(TVLayout.shelfFocusGutter))
                .padding(.trailing, horizontalShelfPadding(TVLayout.shelfFocusGutter))
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalShelfPadding(_ defaultPadding: CGFloat) -> CGFloat {
        contentHorizontalInset > 0 ? contentHorizontalInset : defaultPadding
    }
}

struct CompactCatalogShelfView: View {
    let title: String
    let items: [CatalogItem]
    let onItemFocus: ((CatalogItem) -> Void)?
    let contentHorizontalInset: CGFloat

    init(
        title: String,
        items: [CatalogItem],
        onItemFocus: ((CatalogItem) -> Void)? = nil,
        contentHorizontalInset: CGFloat = 0
    ) {
        self.title = title
        self.items = items
        self.onItemFocus = onItemFocus
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .tvSectionTitle()
                .padding(.horizontal, contentHorizontalInset)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: TVLayout.compactShelfItemSpacing) {
                    ForEach(items) { item in
                        CompactCatalogPosterButton(item: item, onFocus: onItemFocus)
                    }
                }
                .padding(.vertical, TVLayout.compactShelfFocusGutter)
                .padding(.leading, horizontalShelfPadding(TVLayout.compactShelfFocusGutter))
                .padding(.trailing, horizontalShelfPadding(TVLayout.compactShelfFocusGutter))
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalShelfPadding(_ defaultPadding: CGFloat) -> CGFloat {
        contentHorizontalInset > 0 ? contentHorizontalInset : defaultPadding
    }
}

struct CompactCatalogPosterButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let onFocus: ((CatalogItem) -> Void)?

    init(
        item: CatalogItem,
        onFocus: ((CatalogItem) -> Void)? = nil
    ) {
        self.item = item
        self.onFocus = onFocus
    }

    private let cardWidth: CGFloat = 190
    private let cardHeight: CGFloat = 285
    private let focusedScale: CGFloat = 1.065
    private let cornerRadius: CGFloat = 10

    var body: some View {
        Button {
            Task { await appModel.openCatalogDetail(item) }
        } label: {
            ZStack(alignment: .bottomLeading) {
                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: item.posterPath ?? item.backdropPath,
                        kind: .poster
                    ),
                    aspectRatio: 2 / 3
                )
                .frame(width: cardWidth, height: cardHeight)
                .accessibilityHidden(true)

                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.1),
                        .black.opacity(0.82)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )

                Text(item.title)
                    .font(.system(size: 23, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(12)
                    .frame(width: cardWidth, alignment: .leading)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isFocused ? .white.opacity(0.34) : .white.opacity(0.08),
                        lineWidth: 1
                    )
            }
        }
        .tvMediaCatalogButton()
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(color: .black.opacity(isFocused ? 0.62 : 0.22), radius: isFocused ? 20 : 9, x: 0, y: isFocused ? 13 : 6)
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .onChange(of: isFocused) { _, focused in
            if focused {
                onFocus?(item)
            }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
    }
}

struct LogoCardShelfView: View {
    let title: String
    let items: [CatalogItem]
    let onItemFocus: ((CatalogItem) -> Void)?
    let contentHorizontalInset: CGFloat

    init(
        title: String,
        items: [CatalogItem],
        onItemFocus: ((CatalogItem) -> Void)? = nil,
        contentHorizontalInset: CGFloat = 0
    ) {
        self.title = title
        self.items = items
        self.onItemFocus = onItemFocus
        self.contentHorizontalInset = contentHorizontalInset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TVLayout.shelfTitleSpacing) {
            Text(title)
                .tvSectionTitle()
                .padding(.horizontal, contentHorizontalInset)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: TVLayout.shelfItemSpacing) {
                    ForEach(items) { item in
                        LogoCardButton(item: item, onFocus: onItemFocus)
                    }
                }
                .padding(.vertical, TVLayout.compactShelfFocusGutter)
                .padding(.leading, horizontalShelfPadding(TVLayout.shelfFocusGutter))
                .padding(.trailing, horizontalShelfPadding(TVLayout.shelfFocusGutter))
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .frame(maxWidth: .infinity)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalShelfPadding(_ defaultPadding: CGFloat) -> CGFloat {
        contentHorizontalInset > 0 ? contentHorizontalInset : defaultPadding
    }
}

struct LogoCardButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let onFocus: ((CatalogItem) -> Void)?

    init(
        item: CatalogItem,
        onFocus: ((CatalogItem) -> Void)? = nil
    ) {
        self.item = item
        self.onFocus = onFocus
    }

    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 168
    private let focusedScale: CGFloat = 1.055
    private let cornerRadius: CGFloat = 12

    var body: some View {
        Button {
            guard item.href == nil else { return }
            Task { await appModel.openCatalogDetail(item) }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.1))

                CatalogArtwork(
                    url: appModel.artworkURL(
                        for: item.logoPath ?? item.backdropPath ?? item.posterPath,
                        kind: item.logoPath == nil ? .backdrop : .logo
                    ),
                    aspectRatio: 16 / 9,
                    contentMode: item.logoPath == nil ? .fill : .fit
                )
                .padding(item.logoPath == nil ? 0 : 30)
                .frame(width: cardWidth, height: cardHeight)
                .opacity(item.logoPath == nil ? 0.42 : 0.9)
                .accessibilityHidden(true)

                Text(item.title)
                    .font(.system(size: 27, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 18)
                    .shadow(color: .black.opacity(0.75), radius: 8, x: 0, y: 3)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isFocused ? .white.opacity(0.34) : .white.opacity(0.12),
                        lineWidth: 1
                    )
            }
        }
        .tvMediaCatalogButton()
        .disabled(item.href != nil)
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(color: .black.opacity(isFocused ? 0.56 : 0.2), radius: isFocused ? 20 : 9, x: 0, y: isFocused ? 13 : 6)
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .onChange(of: isFocused) { _, focused in
            if focused {
                onFocus?(item)
            }
        }
        .accessibilityLabel(item.title)
        .accessibilityHint(item.href == nil ? L10n.text("Opens details") : L10n.text("Collection browsing unavailable"))
    }
}

struct CatalogPosterButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let onFocus: ((CatalogItem) -> Void)?

    init(
        item: CatalogItem,
        onFocus: ((CatalogItem) -> Void)? = nil
    ) {
        self.item = item
        self.onFocus = onFocus
    }

    private let cardWidth: CGFloat = 250
    private let cardHeight: CGFloat = 375
    private let focusedScale: CGFloat = 1.06
    private let cornerRadius: CGFloat = 12

    var body: some View {
        Button {
            Task {
                if item.mediaType == "episode" {
                    await appModel.playCatalogMovie(item)
                } else {
                    await appModel.openCatalogDetail(item)
                }
            }
        } label: {
            posterCard
                .frame(width: cardWidth, height: cardHeight)
        }
        .tvMediaCatalogButton()
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(
            color: .black.opacity(isFocused ? 0.65 : 0.25),
            radius: isFocused ? 22 : 10,
            x: 0,
            y: isFocused ? 14 : 6
        )
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focused($isFocused)
        .onChange(of: isFocused) { _, focused in
            if focused {
                onFocus?(item)
            }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(item.mediaType == "episode" ? L10n.text("Starts playback") : L10n.text("Opens details"))
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
                    .font(.system(size: 29, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.subtitle ?? item.mediaTypeDisplayName)
                    .font(.system(size: 24, weight: .medium))
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
                    isFocused ? .white.opacity(0.34) : .white.opacity(0.08),
                    lineWidth: 1
                )
        }
    }
}

enum PersonCreditCardTextStyle {
    case cast
    case crew
}

struct PersonCreditButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let person: CatalogPersonCredit
    let textStyle: PersonCreditCardTextStyle

    private let cardWidth: CGFloat = 220
    private let imageHeight: CGFloat = 294
    private let cardHeight: CGFloat = 410
    private let cornerRadius: CGFloat = 12

    init(
        person: CatalogPersonCredit,
        textStyle: PersonCreditCardTextStyle
    ) {
        self.person = person
        self.textStyle = textStyle
    }

    var body: some View {
        Button {
            appModel.openPersonDetails(person)
        } label: {
            cardContent
        }
        .tvMediaCatalogButton()
        .focused($isFocused)
        .scaleEffect(isFocused ? 1.06 : 1)
        .shadow(
            color: .black.opacity(isFocused ? 0.56 : 0.22),
            radius: isFocused ? 20 : 10,
            x: 0,
            y: isFocused ? 13 : 6
        )
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(L10n.text("Opens person details"))
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            CatalogArtwork(
                url: appModel.artworkURL(for: person.profilePath, kind: .poster),
                aspectRatio: 2 / 3
            )
            .frame(width: cardWidth, height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 2))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText)
                    .font(.system(size: 29, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.86)

                if let secondaryText {
                    Text(secondaryText)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(1)
                }
            }
            .frame(width: cardWidth - 22, alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.bottom, 12)
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
        .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    isFocused ? .white.opacity(0.34) : .white.opacity(0.08),
                    lineWidth: 1
                )
        }
        .frame(width: cardWidth, height: cardHeight)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var primaryText: String {
        switch textStyle {
        case .cast:
            return person.role?.nonEmptyCreditText ?? person.name
        case .crew:
            return person.role?.nonEmptyCreditText
                ?? person.department?.nonEmptyCreditText
                ?? person.name
        }
    }

    private var secondaryText: String? {
        switch textStyle {
        case .cast:
            return primaryText == person.name ? person.department?.nonEmptyCreditText : person.name
        case .crew:
            return primaryText == person.name ? nil : person.name
        }
    }

    private var accessibilityLabel: String {
        if let secondaryText {
            return "\(primaryText), \(secondaryText)"
        }
        return primaryText
    }
}

struct CatalogArtwork: View {
    let url: URL?
    let aspectRatio: CGFloat
    let contentMode: ContentMode
    let alignment: Alignment

    init(
        url: URL?,
        aspectRatio: CGFloat,
        contentMode: ContentMode = .fill,
        alignment: Alignment = .center
    ) {
        self.url = url
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.alignment = alignment
    }

    var body: some View {
        ZStack(alignment: alignment) {
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
                            .aspectRatio(contentMode: contentMode)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)

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

private extension String {
    var nonEmptyCreditText: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct EmptyCatalogState: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 31, weight: .medium))
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
    }
}

extension CatalogItem {
    var heroBackdropPath: String? {
        backdropPath ?? backdropWithTextPath ?? posterPath
    }

    var mediaTypeDisplayName: String {
        switch mediaType {
        case "tv_show":
            return L10n.text("TV Show")
        case "episode":
            return L10n.text("Episode")
        default:
            return L10n.text("Movie")
        }
    }

    var detailMetadata: [String] {
        var values: [String] = []
        if let year {
            values.append(String(year))
        }
        if let runtimeMinutes {
            values.append(L10n.format("%d min", runtimeMinutes))
        }
        if let rating {
            values.append(String(format: "%.1f", rating))
        }
        if let contentRating, !contentRating.isEmpty {
            values.append(contentRating)
        }
        values.append(contentsOf: genres.prefix(3))
        if progressPercent > 0 {
            values.append(L10n.watchedPercent(Int(progressPercent.rounded())))
        }
        return values
    }

    var accessibilitySummary: String {
        var parts = [mediaTypeDisplayName, title]
        if let subtitle {
            parts.append(subtitle)
        }
        if progressPercent > 0 {
            parts.append(L10n.watchedPercentAccessibility(Int(progressPercent.rounded())))
        }
        return parts.joined(separator: ", ")
    }
}
