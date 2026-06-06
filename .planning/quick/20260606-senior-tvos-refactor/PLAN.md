---
status: completed
created: 2026-06-06
task: senior-tvos-refactor
---

# Senior tvOS Refactor

## Goal

Improve the Lumina tvOS client architecture and remote-first behavior without preserving prototype-only proof seams.

## Scope

- Reduce `AppModel` responsibility by extracting stable service/state helpers.
- Harden token, stream URL, diagnostics, and playback session behavior.
- Improve tvOS focus, accessibility, and 10-foot UI basics in the catalog/detail surfaces.
- Add behavior tests around the newly extracted logic where practical.
- Verify with generic tvOS build and test-build in the local Xcode environment.

## Notes

- `gsd-sdk` is unavailable in this environment, so this file is the manual quick-task trace.
- Existing uncommitted changes are treated as user work and must not be reverted.

## Result

- Extracted artwork URL resolution from `AppModel`.
- Hardened playback loading against stale async completions and cancelled sessions.
- Added AVPlayer progress/stop reporting tied to actual player time.
- Tightened Keychain token storage errors and device-local accessibility.
- Expanded diagnostics/API error redaction for tokens, JSON secrets, local paths, SQL, and stack traces.
- Made catalog cards semantic tvOS `Button`s with better focus and accessibility labels.
- Improved detail action focus defaults and unified Play/Trailer focus treatment.
- Moved playback to a full-screen AVKit-first view instead of a framed panel.
- Added/updated unit coverage for artwork resolution, manifest URL safety, URL path encoding, and redaction.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing`

Simulator test execution was not available because CoreSimulatorService is failing in this environment.
