//
//  TVPageLayouts.swift
//  lumina
//
//  Created by Martin Thomas on 18/06/2026.
//

import SwiftUI

struct TVTabContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .ignoresSafeArea(.container, edges: .horizontal)
    }
}

struct TVFullBleedPageLayout<Content: View>: View {
    @ViewBuilder let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .background(Color.black.ignoresSafeArea())
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }
}

struct TVTabPageLayout<Content: View>: View {
    let topPadding: CGFloat
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let bottomPadding: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        topPadding: CGFloat,
        spacing: CGFloat,
        horizontalPadding: CGFloat = TVLayout.safeHorizontalPadding,
        bottomPadding: CGFloat = TVLayout.contentBottomPadding,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.topPadding = topPadding
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.bottomPadding = bottomPadding
        self.content = content
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: spacing) {
                content()
            }
            .tvContentRail(horizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
        }
    }
}

struct TVMediaDetailLayout<Background: View, Content: View>: View {
    @ViewBuilder let background: () -> Background
    @ViewBuilder let content: () -> Content

    init(
        @ViewBuilder _ background: @escaping () -> Background,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            background()

            content()
        }
        .ignoresSafeArea(.container, edges: .horizontal)
        .background(Color.black.ignoresSafeArea())
    }
}

private struct TVContentRailModifier: ViewModifier {
    let horizontalPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
    }
}

extension View {
    func tvContentRail(_ horizontalPadding: CGFloat = TVLayout.safeHorizontalPadding) -> some View {
        modifier(TVContentRailModifier(horizontalPadding: horizontalPadding))
    }
}
