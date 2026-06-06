---
status: completed
created: 2026-06-06
task: playback-capabilities-refactor
---

# Playback And Capabilities Refactor

## Goal

Continue the senior tvOS refactor by moving playback orchestration out of `AppModel` where practical and by binding stream route construction to server capabilities instead of hard-coded client assumptions.

## Scope

- Introduce focused service types for playback proof loading and route/capability handling.
- Keep tvOS playback full-screen and AVKit-first.
- Preserve security redaction and avoid leaking stream tokens or backend internals.
- Add focused tests for new pure logic.
- Verify with generic tvOS build and test-build.

## Notes

- `gsd-sdk` is unavailable in this environment, so this file is the manual quick-task trace.
- Existing uncommitted changes are treated as user work and must not be reverted.

## Result

- Added `RouteTemplateResolver` so API routes can be rendered from `ServerCapabilities.routes` with encoded path parameters.
- Configured `URLSessionLuminaAPIClient` with optional capabilities and moved auth, catalog, stream token, HLS, progress, and playback session routes onto capability templates with stable fallbacks.
- Revalidated server capabilities during session restore so restored sessions also use backend route templates.
- Added `PlaybackProofLoader` to own the movie proof sequence: playable movie, progress, session creation, stream token, HLS URL, and preflight.
- Reduced `AppModel` playback responsibility to UI phase transitions, stale-load cancellation, and result publication.
- Fixed AVKit teardown to report `exit`, so leaving playback stops the backend session instead of only updating it as paused.
- Added tests for route template rendering and capability-driven HLS manifest URL construction.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing`

Simulator test execution remains blocked by CoreSimulatorService failures in this environment.
