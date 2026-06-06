//
//  CatalogRepository.swift
//  lumina
//

import Foundation

struct CatalogHomeSnapshot: Equatable {
    let heroItems: [CatalogItem]
    let sections: [CatalogSection]
    let movies: [CatalogItem]
    let tvShows: [CatalogItem]
}

struct TVShowDetailSnapshot: Equatable {
    let show: CatalogItem
    let seasons: [TVSeasonSummary]
    let selectedSeasonNumber: Int?
    let episodes: [CatalogItem]
}

struct CatalogRepository {
    let client: LuminaAPIClient
    let token: String

    func loadHome() async throws -> CatalogHomeSnapshot {
        async let home = client.fetchCatalogHome(token: token)
        async let movies = client.fetchMovies(token: token)
        async let tvShows = client.fetchTVShows(token: token)
        let (homeResponse, fetchedMovies, fetchedTVShows) = try await (home, movies, tvShows)
        return CatalogHomeSnapshot(
            heroItems: Self.heroItems(from: homeResponse),
            sections: homeResponse.sections,
            movies: fetchedMovies,
            tvShows: fetchedTVShows
        )
    }

    func search(query: String) async throws -> [CatalogItem] {
        try await client.searchCatalog(query: query, token: token)
    }

    func movieDetail(movieId: String) async throws -> CatalogItem {
        try await client.fetchMovieDetail(movieId: movieId, token: token)
    }

    func tvShowDetail(showId: String) async throws -> TVShowDetailSnapshot {
        async let detail = client.fetchTVShowDetail(showId: showId, token: token)
        async let seasons = client.fetchTVSeasons(showId: showId, token: token)
        let (show, fetchedSeasons) = try await (detail, seasons)
        guard let firstSeason = fetchedSeasons.first else {
            return TVShowDetailSnapshot(
                show: show,
                seasons: fetchedSeasons,
                selectedSeasonNumber: nil,
                episodes: []
            )
        }
        let episodes = try await episodes(showId: show.id, seasonNumber: firstSeason.seasonNumber)
        return TVShowDetailSnapshot(
            show: show,
            seasons: fetchedSeasons,
            selectedSeasonNumber: firstSeason.seasonNumber,
            episodes: episodes
        )
    }

    func episodes(showId: String, seasonNumber: Int) async throws -> [CatalogItem] {
        try await client.fetchTVEpisodes(showId: showId, seasonNumber: seasonNumber, token: token)
    }

    static func heroItems(from response: CatalogHomeResponse) -> [CatalogItem] {
        response.hero?.items ?? response.sections.first?.items ?? []
    }
}
