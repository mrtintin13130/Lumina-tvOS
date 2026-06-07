//
//  CatalogComponents.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .onTapGesture {
            Task { await appModel.openCatalogDetail(item) }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
        .accessibilityAddTraits(.isButton)
    }
}

struct FeaturedHeroCarousel: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool
    @State private var selectedIndex = 0

    let items: [CatalogItem]

    private let rotationTimer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    private let heroHeight: CGFloat = 720

    var body: some View {
        if let item = currentItem {
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

                    Label(L10n.text("Open Details"), systemImage: "info.circle.fill")
                        .font(.system(size: 31, weight: .semibold))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(.white.opacity(isFocused ? 0.24 : 0.16), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(isFocused ? .white.opacity(0.9) : .white.opacity(0.22), lineWidth: isFocused ? 3 : 1)
                        }
                    .padding(.top, 8)
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
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(isFocused ? .white.opacity(0.88) : .clear)
                    .frame(height: 5)
            }
            .contentShape(Rectangle())
            .focusable(true)
            .focused($isFocused)
            .focusEffectDisabled()
            .onTapGesture {
                Task { await appModel.openCatalogDetail(item) }
            }
            .onReceive(rotationTimer) { _ in
                guard items.count > 1 else { return }
                withAnimation(.easeInOut(duration: 0.45)) {
                    selectedIndex = (selectedIndex + 1) % items.count
                }
            }
            .onChange(of: items) { _, newItems in
                selectedIndex = min(selectedIndex, max(newItems.count - 1, 0))
            }
            .accessibilityLabel(item.accessibilitySummary)
            .accessibilityHint(L10n.text("Opens details"))
            .accessibilityAddTraits(.isButton)
        }
    }

    private var currentItem: CatalogItem? {
        guard !items.isEmpty else { return nil }
        return items[min(selectedIndex, items.count - 1)]
    }
}

struct HomeCatalogSectionView: View {
    let section: CatalogSection

    var body: some View {
        switch section.homeLayout {
        case .heroCarousel:
            FeaturedHeroCarousel(items: section.items)
        case .continueLandscape:
            ContinueWatchingShelfView(title: section.title, items: section.items)
        case .genrePills:
            GenrePillSection(title: section.title, items: section.items)
        case .compactRail:
            CompactCatalogShelfView(title: section.title, items: section.items)
        case .logoCardRail:
            LogoCardShelfView(title: section.title, items: section.items)
        case .landscapeRail:
            CatalogLandscapeShelfView(title: section.title, items: section.items)
        case .editorialBanner:
            EditorialBannerSectionView(section: section)
        case .posterRail:
            CatalogShelfView(title: section.title, items: section.items)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(spacing: 18) {
                    ForEach(items) { item in
                        CatalogGenrePillButton(item: item)
                    }
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 8)
            }
            .scrollClipDisabled()
        }
    }
}

struct CatalogGenrePillButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    var body: some View {
        Button {
            appModel.openCatalogLink(item)
        } label: {
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
                        .background(.white.opacity(0.86), in: Capsule())
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .frame(height: 86)
            .background(
                LinearGradient(
                    colors: [
                        .white.opacity(isFocused ? 0.28 : 0.15),
                        .white.opacity(isFocused ? 0.15 : 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(isFocused ? .white.opacity(0.95) : .white.opacity(0.18), lineWidth: isFocused ? 3 : 1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isFocused ? 1.07 : 1)
        .shadow(color: .black.opacity(isFocused ? 0.48 : 0.2), radius: isFocused ? 18 : 8, x: 0, y: isFocused ? 12 : 5)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .accessibilityLabel(item.linkCount.map { "\(item.title), \(L10n.titleCount($0))" } ?? item.title)
        .accessibilityHint(L10n.text("Opens this genre"))
    }
}

struct ContinueWatchingShelfView: View {
    let title: String
    let items: [CatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 26) {
                    ForEach(items) { item in
                        ContinueWatchingCardButton(item: item)
                    }
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 8)
            }
            .scrollClipDisabled()
        }
    }
}

struct ContinueWatchingCardButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let cardWidth: CGFloat = 430
    private let cardHeight: CGFloat = 242
    private let focusedScale: CGFloat = 1.055
    private let cornerRadius: CGFloat = 12

    var body: some View {
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
                    isFocused ? .white.opacity(0.95) : .white.opacity(0.08),
                    lineWidth: isFocused ? 3 : 1
                )
        }
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(color: .black.opacity(isFocused ? 0.62 : 0.24), radius: isFocused ? 22 : 10, x: 0, y: isFocused ? 14 : 6)
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .onTapGesture {
            Task { await appModel.openCatalogDetail(item) }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
        .accessibilityAddTraits(.isButton)
    }
}

struct CatalogLandscapeShelfView: View {
    let title: String
    let items: [CatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 26) {
                    ForEach(items) { item in
                        CatalogLandscapeButton(item: item)
                    }
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 8)
            }
            .scrollClipDisabled()
        }
    }
}

struct CatalogLandscapeButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let cardWidth: CGFloat = 420
    private let cardHeight: CGFloat = 236
    private let focusedScale: CGFloat = 1.055
    private let cornerRadius: CGFloat = 12

    var body: some View {
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
                    isFocused ? .white.opacity(0.95) : .white.opacity(0.08),
                    lineWidth: isFocused ? 3 : 1
                )
        }
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(
            color: .black.opacity(isFocused ? 0.62 : 0.24),
            radius: isFocused ? 22 : 10,
            x: 0,
            y: isFocused ? 14 : 6
        )
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .onTapGesture {
            Task { await appModel.openCatalogDetail(item) }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
        .accessibilityAddTraits(.isButton)
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
                        .background(.white.opacity(isFocused ? 0.25 : 0.16), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(isFocused ? .white.opacity(0.92) : .white.opacity(0.18), lineWidth: isFocused ? 3 : 1)
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
                    .stroke(isFocused ? .white.opacity(0.96) : .white.opacity(0.1), lineWidth: isFocused ? 3 : 1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isFocused ? 1.018 : 1)
        .shadow(color: .black.opacity(isFocused ? 0.58 : 0.24), radius: isFocused ? 24 : 10, x: 0, y: isFocused ? 15 : 7)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
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
                        VStack(alignment: .leading, spacing: 14) {
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
                        .buttonStyle(.plain)
                        .background(.white.opacity(isCloseFocused ? 0.25 : 0.12), in: Circle())
                        .overlay {
                            Circle()
                                .stroke(isCloseFocused ? .white.opacity(0.95) : .white.opacity(0.16), lineWidth: isCloseFocused ? 3 : 1)
                        }
                        .scaleEffect(isCloseFocused ? 1.08 : 1)
                        .focused($isCloseFocused)
                        .focusEffectDisabled()
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
                .padding(.horizontal, 72)
                .padding(.top, 64)
                .padding(.bottom, 56)
            }
        }
        .onExitCommand {
            appModel.closeEditorialSection()
        }
    }
}

struct ThemedCatalogSectionView: View {
    let title: String
    let items: [CatalogItem]
    let theme: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.title2.bold())

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
                    .stroke(isFocused ? .white.opacity(0.95) : .white.opacity(0.1), lineWidth: isFocused ? 3 : 1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isFocused ? 1.025 : 1)
        .shadow(color: .black.opacity(isFocused ? 0.58 : 0.24), radius: isFocused ? 24 : 10, x: 0, y: isFocused ? 16 : 7)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
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

struct CompactCatalogShelfView: View {
    let title: String
    let items: [CatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 22) {
                    ForEach(items) { item in
                        CompactCatalogPosterButton(item: item)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 8)
            }
            .scrollClipDisabled()
        }
    }
}

struct CompactCatalogPosterButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let cardWidth: CGFloat = 172
    private let cardHeight: CGFloat = 258
    private let focusedScale: CGFloat = 1.065
    private let cornerRadius: CGFloat = 10

    var body: some View {
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
                .font(.system(size: 21, weight: .semibold))
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
                    isFocused ? .white.opacity(0.95) : .white.opacity(0.08),
                    lineWidth: isFocused ? 3 : 1
                )
        }
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(color: .black.opacity(isFocused ? 0.62 : 0.22), radius: isFocused ? 20 : 9, x: 0, y: isFocused ? 13 : 6)
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .onTapGesture {
            Task { await appModel.openCatalogDetail(item) }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
        .accessibilityAddTraits(.isButton)
    }
}

struct LogoCardShelfView: View {
    let title: String
    let items: [CatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 24) {
                    ForEach(items) { item in
                        LogoCardButton(item: item)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 8)
            }
            .scrollClipDisabled()
        }
    }
}

struct LogoCardButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem

    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 168
    private let focusedScale: CGFloat = 1.055
    private let cornerRadius: CGFloat = 12

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.white.opacity(isFocused ? 0.18 : 0.1))

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
                    isFocused ? .white.opacity(0.95) : .white.opacity(0.12),
                    lineWidth: isFocused ? 3 : 1
                )
        }
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(color: .black.opacity(isFocused ? 0.56 : 0.2), radius: isFocused ? 20 : 9, x: 0, y: isFocused ? 13 : 6)
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .onTapGesture {
            if item.href != nil {
                appModel.openCatalogLink(item)
            } else {
                Task { await appModel.openCatalogDetail(item) }
            }
        }
        .accessibilityLabel(item.title)
        .accessibilityHint(item.href == nil ? L10n.text("Opens details") : L10n.text("Opens this collection"))
        .accessibilityAddTraits(.isButton)
    }
}

struct CatalogPosterButton: View {
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
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .focusable(true)
            .focused($isFocused)
            .focusEffectDisabled()
            .onTapGesture {
                Task { await appModel.openCatalogDetail(item) }
            }
            .accessibilityLabel(item.accessibilitySummary)
            .accessibilityHint(L10n.text("Opens details"))
            .accessibilityAddTraits(.isButton)
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
                    .font(.system(size: 25, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.subtitle ?? item.mediaTypeDisplayName)
                    .font(.system(size: 21, weight: .medium))
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

enum PersonCreditCardTextStyle {
    case cast
    case crew
}

struct PersonCreditButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let person: CatalogPersonCredit
    let textStyle: PersonCreditCardTextStyle
    let onSelect: (CatalogPersonCredit) -> Void

    private let cardWidth: CGFloat = 206
    private let imageHeight: CGFloat = 276
    private let cardHeight: CGFloat = 384
    private let focusedScale: CGFloat = 1.06
    private let cornerRadius: CGFloat = 12

    init(
        person: CatalogPersonCredit,
        textStyle: PersonCreditCardTextStyle,
        onSelect: @escaping (CatalogPersonCredit) -> Void = { _ in }
    ) {
        self.person = person
        self.textStyle = textStyle
        self.onSelect = onSelect
    }

    var body: some View {
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
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.86)

                if let secondaryText {
                    Text(secondaryText)
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(1)
                }
            }
            .frame(width: cardWidth - 22, alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.bottom, 12)
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
        .background(.black.opacity(isFocused ? 0.46 : 0.28), in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    isFocused ? .white.opacity(0.95) : .white.opacity(0.08),
                    lineWidth: isFocused ? 3 : 1
                )
        }
        .frame(width: cardWidth, height: cardHeight)
        .scaleEffect(isFocused ? focusedScale : 1)
        .shadow(
            color: .black.opacity(isFocused ? 0.62 : 0.22),
            radius: isFocused ? 22 : 10,
            x: 0,
            y: isFocused ? 14 : 6
        )
        .zIndex(isFocused ? 10 : 0)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .focusable(true)
        .focused($isFocused)
        .focusEffectDisabled()
        .onTapGesture {
            onSelect(person)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(L10n.text("Opens person details"))
        .accessibilityAddTraits(.isButton)
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

    init(url: URL?, aspectRatio: CGFloat, contentMode: ContentMode = .fill) {
        self.url = url
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }

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
                            .aspectRatio(contentMode: contentMode)

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
