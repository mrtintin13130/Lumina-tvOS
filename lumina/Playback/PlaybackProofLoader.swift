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
        var createdSession: PlaybackSessionResponse?
        var resumePosition: Double = 0
        do {
            let movie = try await playableMovie(movieOverride: movieOverride, token: token, client: client)
            let progress = try await optionalPlaybackValue {
                try await client.fetchMovieProgress(movieId: movie.id, token: token)
            }
            let tracks = try await optionalPlaybackValue {
                try await client.fetchMovieTracks(movieId: movie.id, token: token)
            }
            resumePosition = progress?.positionSeconds ?? movie.resumePositionSeconds ?? 0
            let session = try await optionalPlaybackValue {
                try await client.createPlaybackSession(
                    mediaId: movie.id,
                    positionSeconds: resumePosition,
                    token: token
                )
            }
            createdSession = session

            let streamToken = try await client.requestStreamToken(mediaType: "movie", mediaId: movie.id, token: token)
            let streamURL = client.movieHLSManifestURL(
                movie: movie,
                streamToken: streamToken,
                sessionId: session?.id,
                startTime: resumePosition,
                quality: quality
            )
            let manifestInspection = try await client.preflightHLSManifest(url: streamURL)

            let proof = PlaybackProof(
                movie: PlayableMovie(
                    id: movie.id,
                    title: movie.title,
                    overview: movie.overview,
                    resumePositionSeconds: resumePosition,
                    durationSeconds: progress?.durationSeconds ?? movie.durationSeconds,
                    hlsManifestPath: movie.hlsManifestPath,
                    hasPlayableMedia: movie.hasPlayableMedia
                ),
                streamURL: streamURL,
                authorizationHeader: nil,
                sessionId: session?.id,
                tracks: tracks,
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
        if let movieOverride {
            return movieOverride
        }
        return try await client.fetchPlayableMovie(token: token)
    }
}
