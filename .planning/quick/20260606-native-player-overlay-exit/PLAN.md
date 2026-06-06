---
status: completed
created: 2026-06-06
task: native-player-overlay-exit
---

# Native Player Overlay Exit

## Goal

Make playback feel native on Apple TV by removing the custom top overlay, giving AVKit media metadata, and handling remote Back/Menu as an in-app playback exit.

## Scope

- Remove the custom title/Exit overlay from `PlaybackProofView`.
- Set `AVPlayerItem.externalMetadata` with the movie title for AVKit's native UI.
- Add an exit command handler on playback to return to Home.
- Verify tvOS build.

## Implementation

- Removed the custom top title/Exit overlay from the playback screen.
- Added movie title metadata to the AVKit player item with `AVMetadataIdentifier.commonIdentifierTitle`.
- Added a SwiftUI `onExitCommand` handler on the playback screen that calls `appModel.exitPlayback()`.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- Result: passed.
