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
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        controller.player = player
        context.coordinator.attach(player: player, item: item)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    final class Coordinator {
        private let appModel: AppModel
        private let proof: PlaybackProof
        private weak var player: AVPlayer?
        private weak var item: AVPlayerItem?
        private var itemStatusObservation: NSKeyValueObservation?
        private var playerErrorObservation: NSKeyValueObservation?
        private var didStartPlayback = false

        init(appModel: AppModel, proof: PlaybackProof) {
            self.appModel = appModel
            self.proof = proof
        }

        func attach(player: AVPlayer, item: AVPlayerItem) {
            self.player = player
            self.item = item

            itemStatusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] observedItem, _ in
                guard let self else { return }
                let status = observedItem.status
                Task { @MainActor in
                    switch status {
                    case .readyToPlay:
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
        private func reportFailure() {
            let error = item?.error ?? player?.error
            let statusError = item?.errorLog()?.events.last
            let statusMessage = statusError.map { "Playback failed with status \($0.errorStatusCode)." }
            let message = error?.localizedDescription
                ?? statusError?.errorComment
                ?? statusMessage
                ?? "Playback failed before media became ready."
            appModel.recordPlaybackFailure(message)
        }
    }
}
