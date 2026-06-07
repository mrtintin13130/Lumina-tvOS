//
//  AVKitPlayerView.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import AVKit
import SwiftUI

struct AVKitPlayerView: UIViewControllerRepresentable {
    @EnvironmentObject private var appModel: AppModel
    let proof: PlaybackProof

    func makeCoordinator() -> Coordinator {
        Coordinator(appModel: appModel, proof: proof)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let asset: AVURLAsset
        if let authorizationHeader = proof.authorizationHeader {
            asset = AVURLAsset(
                url: proof.streamURL,
                options: ["AVURLAssetHTTPHeaderFieldsKey": ["Authorization": authorizationHeader]]
            )
        } else {
            asset = AVURLAsset(url: proof.streamURL)
        }
        let item = AVPlayerItem(asset: asset)
        item.externalMetadata = Self.externalMetadata(for: proof)
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        controller.allowsPictureInPicturePlayback = true
        controller.player = player
        context.coordinator.attach(player: player, item: item, asset: asset)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.stopPlayback(event: "exit")
        uiViewController.player?.pause()
        uiViewController.player = nil
    }

    private static func externalMetadata(for proof: PlaybackProof) -> [AVMetadataItem] {
        let title = AVMutableMetadataItem()
        title.identifier = .commonIdentifierTitle
        title.value = proof.movie.title as NSString
        title.extendedLanguageTag = "und"
        return [title]
    }

    final class Coordinator {
        private let appModel: AppModel
        private let proof: PlaybackProof
        private weak var player: AVPlayer?
        private weak var item: AVPlayerItem?
        private weak var asset: AVURLAsset?
        private var itemStatusObservation: NSKeyValueObservation?
        private var playerErrorObservation: NSKeyValueObservation?
        private var timeObserver: Any?
        private var endObserver: NSObjectProtocol?
        private var didStartPlayback = false
        private var didSendFinalEvent = false
        private var didInspectMediaSelection = false

        init(appModel: AppModel, proof: PlaybackProof) {
            self.appModel = appModel
            self.proof = proof
        }

        func attach(player: AVPlayer, item: AVPlayerItem, asset: AVURLAsset) {
            self.player = player
            self.item = item
            self.asset = asset

            itemStatusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] observedItem, _ in
                guard let self else { return }
                let status = observedItem.status
                Task { @MainActor in
                    switch status {
                    case .readyToPlay:
                        self.inspectMediaSelectionIfNeeded()
                        self.startPlaybackIfNeeded()
                    case .failed:
                        self.reportFailure()
                    case .unknown:
                        break
                    @unknown default:
                        break
                    }
                }
            }

            playerErrorObservation = player.observe(\.error, options: [.new]) { [weak self] _, _ in
                guard let self else { return }
                Task { @MainActor in
                    self.reportFailure()
                }
            }

            timeObserver = player.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 15, preferredTimescale: 600),
                queue: .main
            ) { [weak self] time in
                guard let self else { return }
                Task { @MainActor in
                    self.reportProgress(positionSeconds: time.seconds, event: "playing")
                }
            }

            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.stopPlayback(event: "stopped")
                }
            }
        }

        @MainActor
        private func startPlaybackIfNeeded() {
            guard !didStartPlayback, let player else { return }
            didStartPlayback = true
            let resume = max(0, proof.movie.resumePositionSeconds ?? 0)
            let target = CMTime(seconds: resume, preferredTimescale: 600)
            player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                player.play()
            }
        }

        @MainActor
        private func inspectMediaSelectionIfNeeded() {
            guard !didInspectMediaSelection, let asset else { return }
            didInspectMediaSelection = true

            Task { [weak self, weak asset] in
                guard let self, let asset else { return }
                do {
                    async let audibleGroup = asset.loadMediaSelectionGroup(for: .audible)
                    async let legibleGroup = asset.loadMediaSelectionGroup(for: .legible)
                    let groups = try await (audibleGroup, legibleGroup)
                    await MainActor.run {
                        self.appModel.recordPlaybackMediaOptions(
                            audioCount: groups.0?.options.count ?? 0,
                            subtitleCount: groups.1?.options.count ?? 0,
                            backendTracks: self.proof.tracks,
                            manifestInspection: self.proof.manifestInspection
                        )
                    }
                } catch {
                    await MainActor.run {
                        self.appModel.recordPlaybackMediaOptionsUnavailable(
                            L10n.text("AVKit media selection groups were not available.")
                        )
                    }
                }
            }
        }

        @MainActor
        private func reportFailure() {
            let error = item?.error ?? player?.error
            let statusError = item?.errorLog()?.events.last
            let statusMessage = statusError.map { L10n.playbackStatusFailure($0.errorStatusCode) }
            let message = error?.localizedDescription
                ?? statusError?.errorComment
                ?? statusMessage
                ?? L10n.text("Playback failed before media became ready.")
            appModel.recordPlaybackFailure(message)
            stopPlayback(event: "paused")
        }

        @MainActor
        func stopPlayback(event: String) {
            guard !didSendFinalEvent else { return }
            didSendFinalEvent = true
            let position = currentPositionSeconds()
            reportProgress(positionSeconds: position, event: event)
            removeObservers()
        }

        @MainActor
        private func reportProgress(positionSeconds: Double, event: String) {
            guard positionSeconds.isFinite else { return }
            Task {
                await appModel.reportPlaybackProgress(positionSeconds: max(0, positionSeconds), event: event)
            }
        }

        @MainActor
        private func currentPositionSeconds() -> Double {
            guard let player else {
                return proof.movie.resumePositionSeconds ?? 0
            }
            return player.currentTime().seconds
        }

        private func removeObservers() {
            if let timeObserver, let player {
                player.removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            if let endObserver {
                NotificationCenter.default.removeObserver(endObserver)
                self.endObserver = nil
            }
        }
    }
}
