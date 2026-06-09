//
//  CatalogStateModel.swift
//  lumina
//

import Foundation

@MainActor
final class CatalogStateModel {
    var homeHeroItems: [CatalogItem] = []
    var homeSections: [CatalogSection] = []
    var movies: [CatalogItem] = []
    var tvShows: [CatalogItem] = []
    var searchQuery: String = ""
    var searchResults: [CatalogItem] = []
    var isCatalogLoading = false
    var selectedCatalogItem: CatalogItem?
    var selectedTVSeasons: [TVSeasonSummary] = []
    var selectedTVEpisodes: [CatalogItem] = []
    var selectedSeasonNumber: Int?
    var selectedEditorialSection: CatalogSection?
    var isDetailLoading = false
    var isEditorialLoading = false

    private var searchLoadID: UUID?
    private var detailLoadID: UUID?
    private var editorialLoadID: UUID?

    func applyHomeSnapshot(_ snapshot: CatalogHomeSnapshot) {
        homeHeroItems = snapshot.heroItems
        homeSections = snapshot.sections
        movies = snapshot.movies
        tvShows = snapshot.tvShows
    }

    func beginSearch() -> (query: String, loadID: UUID)? {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return nil
        }
        let loadID = UUID()
        searchLoadID = loadID
        isCatalogLoading = true
        return (query, loadID)
    }

    func completeSearch(loadID: UUID, results: [CatalogItem]) -> Bool {
        guard searchLoadID == loadID else { return false }
        searchResults = results
        isCatalogLoading = false
        return true
    }

    func failSearch(loadID: UUID) -> Bool {
        guard searchLoadID == loadID else { return false }
        isCatalogLoading = false
        return true
    }

    func beginDetail(_ item: CatalogItem) -> UUID {
        let loadID = UUID()
        detailLoadID = loadID
        selectedCatalogItem = item
        selectedTVSeasons = []
        selectedTVEpisodes = []
        selectedSeasonNumber = nil
        isDetailLoading = true
        return loadID
    }

    func applyMovieDetail(loadID: UUID, item: CatalogItem) -> Bool {
        guard detailLoadID == loadID else { return false }
        selectedCatalogItem = item
        isDetailLoading = false
        return true
    }

    func applyTVShowDetail(loadID: UUID, snapshot: TVShowDetailSnapshot) -> Bool {
        guard detailLoadID == loadID else { return false }
        selectedCatalogItem = snapshot.show
        selectedTVSeasons = snapshot.seasons
        selectedSeasonNumber = snapshot.selectedSeasonNumber
        selectedTVEpisodes = snapshot.episodes
        isDetailLoading = false
        return true
    }

    func failDetail(loadID: UUID) -> Bool {
        guard detailLoadID == loadID else { return false }
        isDetailLoading = false
        return true
    }

    func beginSeason(_ season: TVSeasonSummary) {
        selectedSeasonNumber = season.seasonNumber
        isDetailLoading = true
    }

    func completeSeason(episodes: [CatalogItem]) {
        selectedTVEpisodes = episodes
        isDetailLoading = false
    }

    func failSeason() {
        isDetailLoading = false
    }

    func closeDetail() {
        detailLoadID = nil
        selectedCatalogItem = nil
        selectedTVSeasons = []
        selectedTVEpisodes = []
        selectedSeasonNumber = nil
        isDetailLoading = false
    }

    func beginEditorial(_ section: CatalogSection) -> UUID {
        let loadID = UUID()
        editorialLoadID = loadID
        selectedEditorialSection = section
        isEditorialLoading = true
        return loadID
    }

    func completeEditorial(loadID: UUID, section: CatalogSection) -> Bool {
        guard editorialLoadID == loadID else { return false }
        selectedEditorialSection = section
        isEditorialLoading = false
        return true
    }

    func failEditorial(loadID: UUID) -> Bool {
        guard editorialLoadID == loadID else { return false }
        isEditorialLoading = false
        return true
    }

    func closeEditorial() {
        editorialLoadID = nil
        selectedEditorialSection = nil
        isEditorialLoading = false
    }

    func reset() {
        invalidateLoads()
        homeHeroItems = []
        homeSections = []
        movies = []
        tvShows = []
        searchQuery = ""
        searchResults = []
        isCatalogLoading = false
        closeDetail()
        closeEditorial()
    }

    func invalidateLoads() {
        searchLoadID = nil
        detailLoadID = nil
        editorialLoadID = nil
    }
}
