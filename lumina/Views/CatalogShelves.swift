//
//  CatalogShelves.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
