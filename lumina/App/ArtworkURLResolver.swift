//
//  ArtworkURLResolver.swift
//  lumina
//

import Foundation

struct ArtworkURLResolver {
    let serverURL: URL

    func url(for path: String?, kind: CatalogArtworkKind) -> URL? {
        guard let path, !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)

        if let absoluteURL = URL(string: trimmedPath), absoluteURL.scheme != nil {
            return absoluteURL
        }

        if trimmedPath.hasPrefix("/api/") || trimmedPath.hasPrefix("/assets/") || trimmedPath.hasPrefix("/artwork/") {
            return URL(string: trimmedPath, relativeTo: serverURL)?.absoluteURL
        }

        if trimmedPath.hasPrefix("/") {
            return URL(string: "https://image.tmdb.org/t/p/\(kind.tmdbWidthPath)\(trimmedPath)")
        }

        return URL(string: trimmedPath, relativeTo: serverURL)?.absoluteURL
    }
}
