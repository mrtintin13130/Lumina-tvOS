---
status: complete
completed: 2026-06-06
---

# AVKit Media Selection

Implemented native-player media selection support by keeping AVPlayerViewController as the source of truth for audio and subtitle switching, while adding safe diagnostics around the HLS media selection groups.

## Changes

- Added `MediaTrackListing` DTOs for Lumina playback track responses.
- Added `fetchMovieTracks(movieId:token:)` to `LuminaAPIClient` and `URLSessionLuminaAPIClient`.
- Playback proof loading now fetches movie tracks opportunistically and keeps playback resilient when that endpoint is unavailable.
- `AVKitPlayerView` now loads `.audible` and `.legible` AVAsset media selection groups when the item is ready.
- App diagnostics now record redacted counts for AVKit media options and backend track listings.
- Added a unit test proving playback proof carries decoded backend track listings.

## Verification

- Passed: `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO`
- Passed: `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS Simulator' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO`
- Not run to execution: simulator tests, because CoreSimulatorService is unavailable in this environment.
