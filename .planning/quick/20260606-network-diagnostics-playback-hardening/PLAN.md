---
status: completed
created: 2026-06-06
task: network-diagnostics-playback-hardening
---

# Network Diagnostics Playback Hardening

## Scope

- Add typed, user-safe diagnostics events with phase, severity, and correlation support.
- Make `URLSession` configuration explicit for tvOS request timeouts, cache policy, and constrained networking.
- Stop swallowing critical playback proof errors such as expired auth or failed progress/session reads.
- Expand contract fixtures/tests for no playable media and cleanup after playback preflight failure.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build` passed.
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing` passed.
- Unit-test compile coverage includes structured diagnostics, default URLSession configuration, no-playable-media fixture decoding, session-expired propagation, and playback session cleanup after preflight failure.

## Notes

- `gsd-sdk` is unavailable in this environment, so this file is the manual quick-task trace.
- Existing uncommitted changes are treated as user work and must not be reverted.
- Simulator test execution is still blocked in this environment by CoreSimulatorService availability.
