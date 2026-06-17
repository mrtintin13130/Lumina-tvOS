//
//  CatalogCards.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .hoverEffect(.highlight)
        }
        .tvMediaCatalogButton()
        .zIndex(isFocused ? 10 : 0)
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
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .hoverEffect(.highlight)
        }
        .tvMediaCatalogButton()
        .zIndex(isFocused ? 10 : 0)
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

struct CompactCatalogPosterButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let item: CatalogItem
    let onFocus: ((CatalogItem) -> Void)?

    private let cardWidth: CGFloat = 190
    private let cardHeight: CGFloat = 285
    private let cornerRadius: CGFloat = 10

    var body: some View {
        Button {
            Task { await appModel.openCatalogDetail(item) }
        } label: {
            posterImage
        }
        .tvMediaCatalogButton()
        .focused($isFocused)
        .zIndex(isFocused ? 10 : 0)
        .onChange(of: isFocused) { _, focused in
            guard focused else { return }
            onFocus?(item)
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(L10n.text("Opens details"))
    }

    private var posterImage: some View {
        CatalogArtwork(
            url: appModel.artworkURL(
                for: item.posterPath ?? item.backdropPath,
                kind: .poster
            ),
            aspectRatio: 2 / 3
        )
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .hoverEffect(.highlight)
        .accessibilityHidden(true)
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
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .hoverEffect(.highlight)
        }
        .tvMediaCatalogButton()
        .disabled(item.href != nil)
        .zIndex(isFocused ? 10 : 0)
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
            posterImage
        }
        .tvMediaCatalogButton()
        .focused($isFocused)
        .zIndex(isFocused ? 10 : 0)
        .onChange(of: isFocused) { _, focused in
            if focused {
                onFocus?(item)
            }
        }
        .accessibilityLabel(item.accessibilitySummary)
        .accessibilityHint(item.mediaType == "episode" ? L10n.text("Starts playback") : L10n.text("Opens details"))
    }

    private var posterImage: some View {
        CatalogArtwork(
            url: appModel.artworkURL(
                for: item.posterPath ?? item.backdropPath,
                kind: .poster
            ),
            aspectRatio: 2 / 3
        )
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .hoverEffect(.highlight)
        .accessibilityHidden(true)
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
        .zIndex(isFocused ? 10 : 0)
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
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .frame(width: cardWidth, height: cardHeight)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .hoverEffect(.highlight)
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
