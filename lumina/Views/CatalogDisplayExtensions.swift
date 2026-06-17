//
//  CatalogDisplayExtensions.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import Foundation
import SwiftUI

extension String {
    var nonEmptyCreditText: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension CatalogItem {
    var heroBackdropPath: String? {
        backdropPath ?? backdropWithTextPath ?? posterPath
    }

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
