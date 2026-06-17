//
//  CatalogEditorialViews.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
