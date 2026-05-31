# Debug: Simulator Playback Stalls

**Started:** 2026-05-30
**Status:** fixed-api-contract-mismatch

## Symptom

In the tvOS simulator, selecting Playback Proof opens the playback path but media never starts. Xcode logs show simulator/AVKit noise including missing `libquic.dylib`, transient AV focus constraints, unloaded AV metadata, and audio queue startup timeouts.

## Working Hypothesis

The logged messages are mostly simulator/runtime noise. The app currently calls `play()` immediately during `makeUIViewController` before the `AVPlayerItem` reports readiness, and it does not surface `AVPlayerItem` failure reasons. If the HLS manifest/segments fail because of token transport, ATS, codec, or simulator media support, the app sits on the player screen with no actionable error.

## Fix Direction

- Keep player observations alive in a `UIViewControllerRepresentable` coordinator.
- Start playback only after `AVPlayerItem.status == .readyToPlay`.
- Surface safe playback failures to `AppModel.statusMessage`.
- Preserve token/header redaction.

## Implemented

- Added `AppModel.recordPlaybackFailure(_:)` so AVKit failures are redacted before appearing in the UI or diagnostics.
- Updated `PlaybackProofView` to show the current safe status message below the player.
- Updated `AVKitPlayerView` to create an `AVPlayerItem`, keep KVO observations in its coordinator, wait for `.readyToPlay`, then seek/resume and play.
- Added AV player/item error handling so manifest, token, ATS, codec, or transport failures should produce a visible safe message instead of a silent stalled player.

## Verification

- `xcodebuild build-for-testing -quiet -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` passed.
- The command still emitted CoreSimulatorService/runtime warnings from the local simulator environment, but the build exited successfully.

## Next Observation

Retry Playback Proof in the simulator. If playback still does not start, capture the visible status message shown under the player. That message should now be more useful than the `libquic`, transient AV focus constraint, and AudioQueue simulator noise.

## API Contract Recheck

The live API repo at `/Users/martin/Documents/Developement/Lumina-API` shows the stream-token request is stricter than the initial tvOS client implementation:

- `POST /api/v1/stream/token` validates `media_type` and `media_id` in `src/modules/streaming/validation/streamTokenRequest.js`.
- HLS routes accept either normal Authorization middleware or `stream_token`, but query-token transport is the intended AVKit-safe path for manifest, playlist, segment, and subtitle subrequests.
- The playback session creation response is shaped as `{ "session": { ... } }` via `src/modules/playback/presentation/sessionPresenter.js`.
- The HLS usage examples include `quality`, `t`, and `session_id` query parameters.

## API Alignment Fix

- Changed `StreamTokenRequest` to encode `media_type` and `media_id`.
- Changed playback proof loading to request a media-scoped stream token with the selected movie id and stop silently swallowing stream-token creation failures.
- Changed the HLS manifest URL to include `quality=original`, `t=<resume seconds>`, `stream_token`, and `session_id` when available.
- Changed playback proof to prefer stream-token query transport instead of Authorization headers for AVKit HLS playback.
- Changed `PlaybackSessionResponse` decoding to accept the API's nested `{ "session": ... }` response.
- Added unit coverage for the stream-token request payload, nested playback session response, and HLS URL query shape.

## Latest Verification

- `xcodebuild build-for-testing -quiet -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` passed after the API-alignment fix.
- `xcodebuild test ... -destination 'platform=tvOS Simulator,name=Apple TV'` was attempted but interrupted after the simulator runner hung without output.
- API-side `node --test tests/services/streamTokenService.test.js tests/routes/stream.test.js` could not run because the API repo does not currently have installed Node dependencies (`express`, `jsonwebtoken` missing).

## Second Retry Fix

The API catalog browse contract exposes `playback_readiness.has_playable_media`. The client was ignoring that and using the first returned movie, which could select an unplayable catalog card and then fail at the stream route.

- `PlayableMovie` now decodes `playback_readiness.has_playable_media`.
- `fetchPlayableMovie` fetches a larger first page and picks the first movie that is not explicitly marked unplayable.
- `loadPlaybackProof` now performs a `URLSession` preflight request against the exact HLS manifest URL before entering AVKit.
- The preflight validates HTTP success and `#EXTM3U`; failures become visible safe status messages such as manifest HTTP status/body snippets.

## Second Retry Verification

- `xcodebuild build-for-testing -quiet -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` passed after the playable-filter and manifest-preflight changes.

## Simulator Noise Assessment

The repeated Xcode logs (`libquic` load failure, transient AV focus constraints, unloaded AV metadata, and `AQME` audio timeouts) are not sufficient to identify an API route problem. tvOS Simulator can play HLS, but AVKit/audio behavior is less reliable than physical Apple TV, especially when the host simulator audio device fails to start.

To separate API/HLS failures from simulator AVKit failures, manifest preflight now checks the chain one step deeper:

- master manifest returns HTTP 2xx and starts with `#EXTM3U`
- first variant playlist returns HTTP 2xx and starts with `#EXTM3U`
- first `.ts` segment returns HTTP 2xx, using a small range request where supported

If all three pass and AVKit still fails with only simulator audio/layout logs, the remaining suspect is simulator media playback behavior or codec/device support rather than the initial API contract.

## Updated HTTP File Recheck

The refreshed `rest-client/04-stream-playback.http` confirms:

- Stream tokens use `POST /api/v1/stream/token` with `media_type` and `media_id`.
- Movie HLS playback supports `quality`, `t`, and `session_id`.
- `quality` is a parameter; examples use `original` through a variable, but lower variants such as `720p` are supported by the transcoding settings surface.

Client update after the recheck:

- Playback proof now requests `quality=720p` rather than `quality=original` to reduce simulator transcode/bitrate risk.
- `xcodebuild build-for-testing -quiet -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` passed after the change.
