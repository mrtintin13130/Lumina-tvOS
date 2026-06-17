//
//  CatalogSectionViews.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
