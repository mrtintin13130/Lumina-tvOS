//
//  CatalogHeroViews.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
