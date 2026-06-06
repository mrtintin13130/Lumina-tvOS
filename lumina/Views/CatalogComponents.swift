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

                Label("Open Details", systemImage: "info.circle")
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
        .accessibilityHint("Opens details")
        .accessibilityAddTraits(.isButton)
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
            .accessibilityHint("Opens details")
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
        .accessibilityHint("Opens person details")
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
                            .scaledToFill()

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
            return "TV Show"
        case "episode":
            return "Episode"
        default:
            return "Movie"
        }
    }

    var detailMetadata: [String] {
        var values: [String] = []
        if let year {
            values.append(String(year))
        }
        if let runtimeMinutes {
            values.append("\(runtimeMinutes) min")
        }
        if let rating {
            values.append(String(format: "%.1f", rating))
        }
        if let contentRating, !contentRating.isEmpty {
            values.append(contentRating)
        }
        values.append(contentsOf: genres.prefix(3))
        if progressPercent > 0 {
            values.append("\(Int(progressPercent.rounded()))% watched")
        }
        return values
    }

    var accessibilitySummary: String {
        var parts = [mediaTypeDisplayName, title]
        if let subtitle {
            parts.append(subtitle)
        }
        if progressPercent > 0 {
            parts.append("\(Int(progressPercent.rounded())) percent watched")
        }
        return parts.joined(separator: ", ")
    }
}
