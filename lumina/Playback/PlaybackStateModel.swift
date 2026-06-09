//
//  PlaybackStateModel.swift
//  lumina
//

import Foundation

@MainActor
final class PlaybackStateModel {
    var playbackProof: PlaybackProof?

    private let playbackProofLoader: PlaybackProofLoader
    private let diagnostics: DiagnosticsRecorder
    private var playbackLoadID: UUID?

    init(
        playbackProofLoader: PlaybackProofLoader,
        diagnostics: DiagnosticsRecorder
    ) {
        self.playbackProofLoader = playbackProofLoader
        self.diagnostics = diagnostics
    }

    func beginLoad() -> UUID {
        let loadID = UUID()
        playbackLoadID = loadID
        return loadID
    }

    func loadMovieProof(
        movieOverride: PlayableMovie?,
        token: String,
        client: LuminaAPIClient
    ) async throws -> PlaybackProofLoadResult {
        try await playbackProofLoader.loadMovieProof(
            movieOverride: movieOverride,
            token: token,
            client: client
        )
    }

    func applyLoadedProof(_ result: PlaybackProofLoadResult, loadID: UUID) -> Bool {
        guard playbackLoadID == loadID else { return false }
        playbackProof = result.proof
        return true
    }

    func isCurrentLoad(_ loadID: UUID) -> Bool {
        playbackLoadID == loadID
    }

    func exit() {
        playbackLoadID = nil
        playbackProof = nil
    }

    func reset() {
        exit()
    }

    func recordFailure(_ message: String) -> String {
        diagnostics.record(operation: "avkit_playback", phase: .playback, message: message)
        return DiagnosticsRecorder.redact(message)
    }

    func recordMediaOptions(
        audioCount: Int,
        subtitleCount: Int,
        backendTracks: MediaTrackListing?,
        manifestInspection: HLSManifestInspection?
    ) {
        let backendAudioCount = backendTracks?.tracks.audio.count ?? 0
        let backendEmbeddedSubtitleCount = backendTracks?.tracks.subtitles.embedded.count ?? 0
        let backendExternalSubtitleCount = backendTracks?.tracks.subtitles.external.count ?? 0
        let manifestAudioCount = manifestInspection?.audioRenditionCount ?? 0
        let manifestSubtitleCount = manifestInspection?.subtitleRenditionCount ?? 0
        let nonPlaylistSubtitleCount = manifestInspection?.nonPlaylistSubtitleRenditionCount ?? 0
        diagnostics.record(
            operation: "avkit_media_selection",
            phase: .playback,
            severity: mediaSelectionSeverity(
                avkitAudioCount: audioCount,
                avkitSubtitleCount: subtitleCount,
                backendAudioCount: backendAudioCount,
                backendSubtitleCount: backendEmbeddedSubtitleCount + backendExternalSubtitleCount,
                manifestAudioCount: manifestAudioCount,
                manifestSubtitleCount: manifestSubtitleCount,
                nonPlaylistSubtitleCount: nonPlaylistSubtitleCount
            ),
            message: "AVKit media options audio=\(audioCount) subtitles=\(subtitleCount); HLS media audio=\(manifestAudioCount) subtitles=\(manifestSubtitleCount) non_playlist_subtitles=\(nonPlaylistSubtitleCount); backend audio=\(backendAudioCount) embedded_subtitles=\(backendEmbeddedSubtitleCount) external_subtitles=\(backendExternalSubtitleCount)"
        )
    }

    func recordMediaOptionsUnavailable(_ message: String) {
        diagnostics.record(
            operation: "avkit_media_selection",
            phase: .playback,
            severity: .warning,
            message: message
        )
    }

    private func mediaSelectionSeverity(
        avkitAudioCount: Int,
        avkitSubtitleCount: Int,
        backendAudioCount: Int,
        backendSubtitleCount: Int,
        manifestAudioCount: Int,
        manifestSubtitleCount: Int,
        nonPlaylistSubtitleCount: Int
    ) -> DiagnosticsSeverity {
        if backendAudioCount > 0, manifestAudioCount == 0 {
            return .warning
        }
        if backendSubtitleCount > 0, manifestSubtitleCount == 0 {
            return .warning
        }
        if manifestAudioCount > 0, avkitAudioCount == 0 {
            return .warning
        }
        if manifestSubtitleCount > 0, avkitSubtitleCount == 0 {
            return .warning
        }
        if nonPlaylistSubtitleCount > 0 {
            return .warning
        }
        return .info
    }
}
