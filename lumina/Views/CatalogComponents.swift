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
    static let setupFieldWidth: CGFloat = 820
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

struct EmptyCatalogState: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 31, weight: .medium))
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
    }
}
