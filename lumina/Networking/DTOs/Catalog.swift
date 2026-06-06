//
//  Catalog.swift
//  lumina
//

import Foundation

struct PlayableMovie: Decodable, Equatable, Identifiable {
    let id: String
    let title: String
    let overview: String?
    let resumePositionSeconds: Double?
    let durationSeconds: Double?
    let hlsManifestPath: String?
    let hasPlayableMedia: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case resumePositionSeconds
        case resume_position_seconds
        case durationSeconds
        case duration_seconds
        case hlsManifestPath
        case hls_manifest_path
        case hasPlayableMedia
        case has_playable_media
        case playback_readiness
        case progress
    }

    enum ProgressKeys: String, CodingKey {
        case positionSeconds = "position_seconds"
        case resumePositionSeconds = "resume_position_seconds"
    }

    enum PlaybackReadinessKeys: String, CodingKey {
        case hasPlayableMedia = "has_playable_media"
    }

    init(
        id: String,
        title: String,
        overview: String? = nil,
        resumePositionSeconds: Double? = nil,
        durationSeconds: Double? = nil,
        hlsManifestPath: String? = nil,
        hasPlayableMedia: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.resumePositionSeconds = resumePositionSeconds
        self.durationSeconds = durationSeconds
        self.hlsManifestPath = hlsManifestPath
        self.hasPlayableMedia = hasPlayableMedia
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .id))
        }
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? "Untitled movie"
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        durationSeconds = try container.decodeIfPresent(Double.self, forKey: .durationSeconds)
            ?? container.decodeIfPresent(Double.self, forKey: .duration_seconds)
        hlsManifestPath = try container.decodeIfPresent(String.self, forKey: .hlsManifestPath)
            ?? container.decodeIfPresent(String.self, forKey: .hls_manifest_path)
        if let hasPlayableMedia = try container.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia)
            ?? container.decodeIfPresent(Bool.self, forKey: .has_playable_media) {
            self.hasPlayableMedia = hasPlayableMedia
        } else if let readiness = try? container.nestedContainer(keyedBy: PlaybackReadinessKeys.self, forKey: .playback_readiness) {
            hasPlayableMedia = try readiness.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia)
        } else {
            hasPlayableMedia = nil
        }

        if let resume = try container.decodeIfPresent(Double.self, forKey: .resumePositionSeconds)
            ?? container.decodeIfPresent(Double.self, forKey: .resume_position_seconds) {
            resumePositionSeconds = resume
        } else if let progress = try? container.nestedContainer(keyedBy: ProgressKeys.self, forKey: .progress) {
            resumePositionSeconds = try progress.decodeIfPresent(Double.self, forKey: .resumePositionSeconds)
                ?? progress.decodeIfPresent(Double.self, forKey: .positionSeconds)
        } else {
            resumePositionSeconds = nil
        }
    }
}

struct MovieListResponse: Decodable, Equatable {
    let items: [PlayableMovie]

    enum CodingKeys: String, CodingKey {
        case items
        case data
        case results
        case movies
    }

    init(items: [PlayableMovie]) {
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([PlayableMovie].self, forKey: .items)
            ?? container.decodeIfPresent([PlayableMovie].self, forKey: .data)
            ?? container.decodeIfPresent([PlayableMovie].self, forKey: .results)
            ?? container.decodeIfPresent([PlayableMovie].self, forKey: .movies)
            ?? []
    }
}

struct CatalogItem: Decodable, Equatable, Identifiable {
    let id: String
    let mediaType: String
    let title: String
    let subtitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let logoPath: String?
    let progressPercent: Double
    let watchedState: String?
    let hasPlayableMedia: Bool?
    let year: Int?
    let runtimeMinutes: Int?
    let rating: Double?
    let contentRating: String?
    let genres: [String]
    let isWatchlisted: Bool?
    let isFavorite: Bool?
    let primaryTrailerTitle: String?
    let linkCount: Int?
    let href: String?
    let cast: [CatalogPersonCredit]
    let crew: [CatalogPersonCredit]

    enum CodingKeys: String, CodingKey {
        case id
        case mediaId = "media_id"
        case mediaType = "media_type"
        case title
        case name
        case originalTitle = "original_title"
        case year
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case airDate = "air_date"
        case overview
        case description
        case runtime
        case runtimeMinutes = "runtime_minutes"
        case rating
        case voteAverage = "vote_average"
        case contentRating = "content_rating"
        case genres
        case isWatchlisted = "is_watchlisted"
        case inWatchlist = "in_watchlist"
        case watchlist
        case isFavorite = "is_favorite"
        case favorite
        case listMembership = "list_membership"
        case primaryTrailer = "primary_trailer"
        case trailerPreview = "trailer_preview"
        case count
        case href
        case cast
        case crew
        case credits
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case backdropWithTextPath = "backdrop_with_text_path"
        case logoPath = "logo_path"
        case progress
        case progressPercent = "progress_percent"
        case watchedState = "watched_state"
        case playbackReadiness = "playback_readiness"
        case hasPlayableMedia = "has_playable_media"
        case show
        case seasonNumber = "season_number"
        case episodeNumber = "episode_number"
        case episodeTitle = "episode_title"
    }

    enum ProgressKeys: String, CodingKey {
        case progressPercent = "progress_percent"
    }

    enum PlaybackReadinessKeys: String, CodingKey {
        case hasPlayableMedia = "has_playable_media"
    }

    enum ShowKeys: String, CodingKey {
        case title
    }

    enum GenreKeys: String, CodingKey {
        case name
        case title
    }

    enum TrailerKeys: String, CodingKey {
        case title
        case name
        case site
    }

    enum CreditsKeys: String, CodingKey {
        case cast
        case crew
    }

    enum ListMembershipKeys: String, CodingKey {
        case inWatchlist = "in_watchlist"
        case isFavorite = "is_favorite"
    }

    init(
        id: String,
        mediaType: String = "movie",
        title: String,
        subtitle: String? = nil,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        logoPath: String? = nil,
        progressPercent: Double = 0,
        watchedState: String? = nil,
        hasPlayableMedia: Bool? = nil,
        year: Int? = nil,
        runtimeMinutes: Int? = nil,
        rating: Double? = nil,
        contentRating: String? = nil,
        genres: [String] = [],
        isWatchlisted: Bool? = nil,
        isFavorite: Bool? = nil,
        primaryTrailerTitle: String? = nil,
        linkCount: Int? = nil,
        href: String? = nil,
        cast: [CatalogPersonCredit] = [],
        crew: [CatalogPersonCredit] = []
    ) {
        self.id = id
        self.mediaType = mediaType
        self.title = title
        self.subtitle = subtitle
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.logoPath = logoPath
        self.progressPercent = progressPercent
        self.watchedState = watchedState
        self.hasPlayableMedia = hasPlayableMedia
        self.year = year
        self.runtimeMinutes = runtimeMinutes
        self.rating = rating
        self.contentRating = contentRating
        self.genres = genres
        self.isWatchlisted = isWatchlisted
        self.isFavorite = isFavorite
        self.primaryTrailerTitle = primaryTrailerTitle
        self.linkCount = linkCount
        self.href = href
        self.cast = cast
        self.crew = crew
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else if let stringID = try? container.decode(String.self, forKey: .mediaId) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .mediaId))
        }

        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType) ?? "movie"
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? "Untitled"
        year = try container.decodeIfPresent(Int.self, forKey: .year)
            ?? CatalogItem.year(from: try container.decodeIfPresent(String.self, forKey: .releaseDate))
            ?? CatalogItem.year(from: try container.decodeIfPresent(String.self, forKey: .firstAirDate))
            ?? CatalogItem.year(from: try container.decodeIfPresent(String.self, forKey: .airDate))
        let originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle)
        if let show = try? container.nestedContainer(keyedBy: ShowKeys.self, forKey: .show),
           let showTitle = try show.decodeIfPresent(String.self, forKey: .title) {
            let season = try container.decodeIfPresent(Int.self, forKey: .seasonNumber)
            let episode = try container.decodeIfPresent(Int.self, forKey: .episodeNumber)
            let episodeTitle = try container.decodeIfPresent(String.self, forKey: .episodeTitle)
            subtitle = [showTitle, season.map { "S\($0)" }, episode.map { "E\($0)" }, episodeTitle]
                .compactMap { $0 }
                .joined(separator: " ")
        } else if let year {
            subtitle = String(year)
        } else {
            subtitle = originalTitle
        }
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
            ?? container.decodeIfPresent(String.self, forKey: .description)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropWithTextPath)
            ?? container.decodeIfPresent(String.self, forKey: .backdropPath)
        logoPath = try container.decodeIfPresent(String.self, forKey: .logoPath)
        if let progress = try? container.nestedContainer(keyedBy: ProgressKeys.self, forKey: .progress) {
            progressPercent = try progress.decodeIfPresent(Double.self, forKey: .progressPercent) ?? 0
        } else {
            progressPercent = try container.decodeIfPresent(Double.self, forKey: .progressPercent) ?? 0
        }
        watchedState = try container.decodeIfPresent(String.self, forKey: .watchedState)
        runtimeMinutes = try container.decodeIfPresent(Int.self, forKey: .runtimeMinutes)
            ?? container.decodeIfPresent(Int.self, forKey: .runtime)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
            ?? container.decodeIfPresent(Double.self, forKey: .voteAverage)
        contentRating = try container.decodeIfPresent(String.self, forKey: .contentRating)
        genres = CatalogItem.decodeGenres(from: container)
        if let membership = try? container.nestedContainer(keyedBy: ListMembershipKeys.self, forKey: .listMembership) {
            isWatchlisted = try container.decodeIfPresent(Bool.self, forKey: .isWatchlisted)
                ?? container.decodeIfPresent(Bool.self, forKey: .inWatchlist)
                ?? container.decodeIfPresent(Bool.self, forKey: .watchlist)
                ?? membership.decodeIfPresent(Bool.self, forKey: .inWatchlist)
            isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
                ?? container.decodeIfPresent(Bool.self, forKey: .favorite)
                ?? membership.decodeIfPresent(Bool.self, forKey: .isFavorite)
        } else {
            isWatchlisted = try container.decodeIfPresent(Bool.self, forKey: .isWatchlisted)
                ?? container.decodeIfPresent(Bool.self, forKey: .inWatchlist)
                ?? container.decodeIfPresent(Bool.self, forKey: .watchlist)
            isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
                ?? container.decodeIfPresent(Bool.self, forKey: .favorite)
        }
        primaryTrailerTitle = CatalogItem.decodeTrailerTitle(from: container)
        linkCount = try container.decodeIfPresent(Int.self, forKey: .count)
        href = try container.decodeIfPresent(String.self, forKey: .href)
        cast = CatalogItem.decodeCredits(from: container, key: .cast)
        crew = CatalogItem.decodeCredits(from: container, key: .crew)
        if let direct = try container.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia) {
            hasPlayableMedia = direct
        } else if let readiness = try? container.nestedContainer(keyedBy: PlaybackReadinessKeys.self, forKey: .playbackReadiness) {
            hasPlayableMedia = try readiness.decodeIfPresent(Bool.self, forKey: .hasPlayableMedia)
        } else {
            hasPlayableMedia = nil
        }
    }

    var playableMovie: PlayableMovie {
        PlayableMovie(id: id, title: title, overview: overview, hasPlayableMedia: hasPlayableMedia)
    }

    private static func year(from date: String?) -> Int? {
        guard let prefix = date?.prefix(4), let year = Int(prefix) else {
            return nil
        }
        return year
    }

    private static func decodeGenres(from container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let strings = try? container.decode([String].self, forKey: .genres) {
            return strings
        }
        guard var nested = try? container.nestedUnkeyedContainer(forKey: .genres) else {
            return []
        }
        var names: [String] = []
        while !nested.isAtEnd {
            if let value = try? nested.decode(String.self) {
                names.append(value)
                continue
            }
            if let genre = try? nested.nestedContainer(keyedBy: GenreKeys.self) {
                if let name = try? genre.decodeIfPresent(String.self, forKey: .name) {
                    names.append(name)
                } else if let title = try? genre.decodeIfPresent(String.self, forKey: .title) {
                    names.append(title)
                }
            } else {
                _ = try? nested.decode(EmptyDecodable.self)
            }
        }
        return names
    }

    private static func decodeTrailerTitle(from container: KeyedDecodingContainer<CodingKeys>) -> String? {
        if let trailer = try? container.nestedContainer(keyedBy: TrailerKeys.self, forKey: .primaryTrailer) {
            return (try? trailer.decode(String.self, forKey: .title))
                ?? (try? trailer.decode(String.self, forKey: .name))
                ?? (try? trailer.decode(String.self, forKey: .site))
        }
        if let trailer = try? container.nestedContainer(keyedBy: TrailerKeys.self, forKey: .trailerPreview) {
            return (try? trailer.decode(String.self, forKey: .title))
                ?? (try? trailer.decode(String.self, forKey: .name))
                ?? (try? trailer.decode(String.self, forKey: .site))
        }
        return nil
    }

    private static func decodeCredits(
        from container: KeyedDecodingContainer<CodingKeys>,
        key: CreditsKeys
    ) -> [CatalogPersonCredit] {
        let directKey: CodingKeys = key == .cast ? .cast : .crew
        if let direct = try? container.decode([CatalogPersonCredit].self, forKey: directKey) {
            return direct
        }
        if let flatCredits = try? container.decode([CatalogPersonCredit].self, forKey: .credits) {
            return flatCredits.filter { credit in
                let type = credit.creditType?.lowercased()
                if key == .cast {
                    return type == nil || type == "cast"
                }
                return type != "cast"
            }
        }
        if let credits = try? container.nestedContainer(keyedBy: CreditsKeys.self, forKey: .credits),
           let nested = try? credits.decode([CatalogPersonCredit].self, forKey: key) {
            return nested
        }
        return []
    }
}

private struct EmptyDecodable: Decodable {}

struct CatalogPersonCredit: Decodable, Equatable, Identifiable {
    let id: String
    let name: String
    let role: String?
    let department: String?
    let creditType: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case personId = "person_id"
        case tmdbId = "tmdb_id"
        case name
        case character
        case role
        case job
        case department
        case creditType = "credit_type"
        case profilePath = "profile_path"
        case photoPath = "photo_path"
        case imagePath = "image_path"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name)
            ?? "Unknown"
        role = try container.decodeIfPresent(String.self, forKey: .character)
            ?? container.decodeIfPresent(String.self, forKey: .role)
            ?? container.decodeIfPresent(String.self, forKey: .job)
        department = try container.decodeIfPresent(String.self, forKey: .department)
        creditType = try container.decodeIfPresent(String.self, forKey: .creditType)
        profilePath = try container.decodeIfPresent(String.self, forKey: .profilePath)
            ?? container.decodeIfPresent(String.self, forKey: .photoPath)
            ?? container.decodeIfPresent(String.self, forKey: .imagePath)

        if let stringID = (try? container.decodeIfPresent(String.self, forKey: .id))
            ?? (try? container.decodeIfPresent(String.self, forKey: .personId))
            ?? (try? container.decodeIfPresent(String.self, forKey: .tmdbId)) {
            id = stringID
            return
        }

        if let intID = (try? container.decodeIfPresent(Int.self, forKey: .id))
            ?? (try? container.decodeIfPresent(Int.self, forKey: .personId))
            ?? (try? container.decodeIfPresent(Int.self, forKey: .tmdbId)) {
            id = String(intID)
        } else {
            id = "\(name)-\(role ?? department ?? "credit")"
        }
    }
}

struct CatalogSection: Decodable, Equatable, Identifiable {
    let id: String
    let title: String
    let type: String?
    let mediaType: String?
    let genreId: Int?
    let eyebrow: String?
    let subtitle: String?
    let tags: [String]
    let presentation: CatalogPresentation?
    let items: [CatalogItem]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case type
        case mediaType = "media_type"
        case genreId = "genre_id"
        case eyebrow
        case subtitle
        case tags
        case presentation
        case items
    }

    init(
        id: String,
        title: String,
        type: String? = nil,
        mediaType: String? = nil,
        genreId: Int? = nil,
        eyebrow: String? = nil,
        subtitle: String? = nil,
        tags: [String] = [],
        presentation: CatalogPresentation? = nil,
        items: [CatalogItem] = []
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.mediaType = mediaType
        self.genreId = genreId
        self.eyebrow = eyebrow
        self.subtitle = subtitle
        self.tags = tags
        self.presentation = presentation
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
        genreId = try container.decodeIfPresent(Int.self, forKey: .genreId)
        eyebrow = try container.decodeIfPresent(String.self, forKey: .eyebrow)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        presentation = try container.decodeIfPresent(CatalogPresentation.self, forKey: .presentation)
        items = try container.decodeIfPresent([CatalogItem].self, forKey: .items) ?? []
    }
}

struct CatalogHomeResponse: Decodable, Equatable {
    struct Hero: Decodable, Equatable {
        let title: String?
        let subtitle: String?
        let presentation: CatalogPresentation?
        let items: [CatalogItem]

        init(
            title: String? = nil,
            subtitle: String? = nil,
            presentation: CatalogPresentation? = nil,
            items: [CatalogItem] = []
        ) {
            self.title = title
            self.subtitle = subtitle
            self.presentation = presentation
            self.items = items
        }
    }

    let hero: Hero?
    let layout: CatalogHomeLayout?
    let sections: [CatalogSection]

    init(hero: Hero? = nil, layout: CatalogHomeLayout? = nil, sections: [CatalogSection] = []) {
        self.hero = hero
        self.layout = layout
        self.sections = sections
    }
}

struct CatalogHomeLayout: Decodable, Equatable {
    let version: String?
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case version
        case generatedAt = "generated_at"
    }
}

struct CatalogPresentation: Decodable, Equatable {
    let layout: String?
    let emphasis: String?
    let theme: String?
    let autoplay: Bool?
    let viewAll: CatalogPresentationLink?

    enum CodingKeys: String, CodingKey {
        case layout
        case emphasis
        case theme
        case autoplay
        case viewAll = "view_all"
    }
}

struct CatalogPresentationLink: Decodable, Equatable {
    let label: String?
    let href: String?
}

struct CatalogListResponse: Decodable, Equatable {
    let results: [CatalogItem]

    enum CodingKeys: String, CodingKey {
        case results
        case items
        case data
    }

    init(results: [CatalogItem]) {
        self.results = results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decodeIfPresent([CatalogItem].self, forKey: .results)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .items)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .data)
            ?? []
    }
}

struct CatalogDetailResponse: Decodable, Equatable {
    let item: CatalogItem

    enum CodingKeys: String, CodingKey {
        case movie
        case tvShow = "tv_show"
        case show
        case item
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let movie = try container.decodeIfPresent(CatalogItem.self, forKey: .movie) {
            item = movie
        } else if let tvShow = try container.decodeIfPresent(CatalogItem.self, forKey: .tvShow) {
            item = tvShow
        } else if let show = try container.decodeIfPresent(CatalogItem.self, forKey: .show) {
            item = show
        } else if let value = try container.decodeIfPresent(CatalogItem.self, forKey: .item) {
            item = value
        } else if let data = try container.decodeIfPresent(CatalogItem.self, forKey: .data) {
            item = data
        } else {
            item = try CatalogItem(from: decoder)
        }
    }
}

struct TVSeasonSummary: Decodable, Equatable, Identifiable {
    let id: String
    let seasonNumber: Int
    let title: String
    let overview: String?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case seasonNumber = "season_number"
        case title
        case name
        case overview
        case description
        case posterPath = "poster_path"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seasonNumber = try container.decodeIfPresent(Int.self, forKey: .seasonNumber) ?? 0
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            id = "season-\(seasonNumber)"
        }
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? "Season \(seasonNumber)"
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
            ?? container.decodeIfPresent(String.self, forKey: .description)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
    }
}

struct TVSeasonListResponse: Decodable, Equatable {
    let seasons: [TVSeasonSummary]

    enum CodingKeys: String, CodingKey {
        case seasons
        case items
        case results
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seasons = try container.decodeIfPresent([TVSeasonSummary].self, forKey: .seasons)
            ?? container.decodeIfPresent([TVSeasonSummary].self, forKey: .items)
            ?? container.decodeIfPresent([TVSeasonSummary].self, forKey: .results)
            ?? container.decodeIfPresent([TVSeasonSummary].self, forKey: .data)
            ?? []
    }
}

struct TVEpisodeListResponse: Decodable, Equatable {
    let episodes: [CatalogItem]

    enum CodingKeys: String, CodingKey {
        case episodes
        case items
        case results
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        episodes = try container.decodeIfPresent([CatalogItem].self, forKey: .episodes)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .items)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .results)
            ?? container.decodeIfPresent([CatalogItem].self, forKey: .data)
            ?? []
    }
}

enum CatalogArtworkKind {
    case poster
    case backdrop
    case logo

    var tmdbWidthPath: String {
        switch self {
        case .poster:
            return "w500"
        case .backdrop:
            return "w1280"
        case .logo:
            return "w500"
        }
    }
}
