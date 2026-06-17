//
//  CatalogArtwork.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

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
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: alignment
                            )

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
    }

    private func placeholderIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 54, weight: .semibold))
            .foregroundStyle(.white.opacity(0.42))
    }
}
