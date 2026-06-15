//
//  PlaybackProofLoader.swift
//  lumina
//

import Foundation

struct PlaybackProofLoadResult {
    let proof: PlaybackProof
    let resumePositionSeconds: Double
    let session: PlaybackSessionResponse?
}

struct PlaybackProofLoader {
    func loadMovieProof(
        movieOverride: PlayableMovie?,
        token: String,
        client: LuminaAPIClient,
        quality: String = "720p"
    ) async throws -> PlaybackProofLoadResult {
        try await loadPlaybackProof(
            mediaOverride: movieOverride,
            token: token,
            client: client,
            quality: quality
        )
    }

    func loadPlaybackProof(
        mediaOverride: PlayableMovie?,
        token: String,
        client: LuminaAPIClient,
        quality: String = "720p"
    ) async throws -> PlaybackProofLoadResult {
        var createdSession: PlaybackSessionResponse?
        var resumePosition: Double = 0
        do {
            let movie = try await playableMovie(movieOverride: mediaOverride, token: token, client: client)
            let progressResponse: MovieProgressResponse? = try await optionalPlaybackValue {
                try await progress(for: movie, token: token, client: client)
            }
            let trackListing: MediaTrackListing? = try await optionalPlaybackValue {
                try await tracks(for: movie, token: token, client: client)
            }
            resumePosition = progressResponse?.positionSeconds ?? movie.resumePositionSeconds ?? 0
            let session = try await optionalPlaybackValue {
                try await client.createPlaybackSession(
                    mediaType: movie.playbackMediaType,
                    mediaId: movie.id,
                    positionSeconds: resumePosition,
                    token: token
                )
            }
            createdSession = session

            let streamToken = try await client.requestStreamToken(mediaType: movie.playbackMediaType, mediaId: movie.id, token: token)
            let streamURL = try hlsManifestURL(for: movie, streamToken: streamToken, sessionId: session?.id, startTime: resumePosition, quality: quality, client: client)
            let manifestInspection = try await client.preflightHLSManifest(url: streamURL)

            let proof = PlaybackProof(
                movie: PlayableMovie(
                    id: movie.id,
                    mediaType: movie.mediaType,
                    title: movie.title,
                    overview: movie.overview,
                    resumePositionSeconds: resumePosition,
                    durationSeconds: progressResponse?.durationSeconds ?? movie.durationSeconds,
                    hlsManifestPath: movie.hlsManifestPath,
                    hasPlayableMedia: movie.hasPlayableMedia,
                    showId: movie.showId,
                    seasonNumber: movie.seasonNumber,
                    episodeNumber: movie.episodeNumber
                ),
                streamURL: streamURL,
                authorizationHeader: nil,
                sessionId: session?.id,
                tracks: trackListing,
                manifestInspection: manifestInspection
            )
            return PlaybackProofLoadResult(
                proof: proof,
                resumePositionSeconds: resumePosition,
                session: session
            )
        } catch {
            if let createdSession {
                try? await client.stopPlaybackSession(
                    sessionId: createdSession.id,
                    positionSeconds: resumePosition,
                    token: token
                )
            }
            throw error
        }
    }

    private func progress(for media: PlayableMovie, token: String, client: LuminaAPIClient) async throws -> MovieProgressResponse {
        if media.playbackMediaType == "episode",
           let showId = media.showId,
           let seasonNumber = media.seasonNumber,
           let episodeNumber = media.episodeNumber {
            return try await client.fetchEpisodeProgress(
                showId: showId,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                token: token
            )
        }
        return try await client.fetchMovieProgress(movieId: media.id, token: token)
    }

    private func tracks(for media: PlayableMovie, token: String, client: LuminaAPIClient) async throws -> MediaTrackListing {
        if media.playbackMediaType == "episode",
           let showId = media.showId,
           let seasonNumber = media.seasonNumber,
           let episodeNumber = media.episodeNumber {
            return try await client.fetchEpisodeTracks(
                showId: showId,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                token: token
            )
        }
        return try await client.fetchMovieTracks(movieId: media.id, token: token)
    }

    private func hlsManifestURL(
        for media: PlayableMovie,
        streamToken: String?,
        sessionId: String?,
        startTime: Double,
        quality: String,
        client: LuminaAPIClient
    ) throws -> URL {
        if media.playbackMediaType == "episode" {
            return try client.episodeHLSManifestURL(
                episode: media,
                streamToken: streamToken,
                sessionId: sessionId,
                startTime: startTime,
                quality: quality
            )
        }
        return client.movieHLSManifestURL(
            movie: media,
            streamToken: streamToken,
            sessionId: sessionId,
            startTime: startTime,
            quality: quality
        )
    }

    private func optionalPlaybackValue<Value>(_ operation: () async throws -> Value) async throws -> Value? {
        do {
            return try await operation()
        } catch let error as LuminaClientError {
            if error == .sessionExpired || error == .missingToken {
                throw error
            }
            return nil
        } catch {
            return nil
        }
    }

    private func playableMovie(
        movieOverride: PlayableMovie?,
        token: String,
        client: LuminaAPIClient
    ) async throws -> PlayableMovie {
        let movie: PlayableMovie
        if let movieOverride {
            movie = movieOverride
        } else {
            movie = try await client.fetchPlayableMovie(token: token)
        }

        guard movie.hasPlayableMedia != false else {
            throw LuminaClientError.transport(L10n.text("No playable movie was found on this Lumina server."))
        }
        return movie
    }
}

extension PlayableMovie {
    var playbackMediaType: String {
        mediaType == "episode" ? "episode" : "movie"
    }
}
