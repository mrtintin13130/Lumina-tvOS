---
last_mapped: 2026-05-30
last_mapped_commit: unknown
focus: quality
---

# Testing

## Summary

The project has generated XCTest and XCUITest targets, but no meaningful behavioral test coverage yet. `TVOS_CLIENT_PRD.md` defines a much broader verification strategy for the future app, especially around auth, catalog rendering, tvOS focus, playback, and physical Apple TV validation.

## Test Targets

`lumina.xcodeproj/project.pbxproj` defines:

- `luminaTests`: unit-test bundle.
- `luminaUITests`: UI-test bundle.

Both test targets depend on the `lumina` app target.

## Unit Test Files

- `luminaTests/luminaTests.swift`

Current contents:

- Imports `XCTest`.
- Imports app module with `@testable import lumina`.
- Defines `setUpWithError()`.
- Defines `tearDownWithError()`.
- Defines generated `testExample()`.
- Defines generated `testPerformanceExample()` using `self.measure`.

There are no assertions in the current unit tests.

## UI Test Files

- `luminaUITests/luminaUITests.swift`
- `luminaUITests/luminaUITestsLaunchTests.swift`

Current UI-test behavior:

- `luminaUITests/luminaUITests.swift` sets `continueAfterFailure = false`.
- `luminaUITests/luminaUITests.swift` launches `XCUIApplication()` in `testExample()`.
- `luminaUITests/luminaUITests.swift` measures launch performance in `testLaunchPerformance()`.
- `luminaUITests/luminaUITestsLaunchTests.swift` launches the app and attaches a screenshot named `Launch Screen`.

There are no UI assertions beyond successful launch/screenshot capture.

## How To List Project Tests

The project can be inspected with:

```sh
xcodebuild -list -project lumina.xcodeproj
```

During mapping, that command reported:

- Targets: `lumina`, `luminaTests`, `luminaUITests`
- Build configurations: `Debug`, `Release`
- Scheme: `lumina`

The command also emitted simulator service warnings in the sandboxed environment, so full simulator execution should be checked in a normal Xcode session or with a healthy CoreSimulatorService.

## Current Coverage

Current effective coverage is limited to:

- Project compiles enough for generated test targets to exist.
- App launch can be attempted by generated UI tests.
- There is no coverage for product requirements.
- There is no coverage for networking, auth, playback, persistence, error handling, focus behavior, or diagnostics because those features do not exist yet.

## PRD Test Strategy

`TVOS_CLIENT_PRD.md` defines future testing needs:

- Unit tests for URL construction, response decoding, auth/session state, error mapping, progress cadence, watchlist/favorite state transitions, and diagnostics redaction.
- UI tests for server setup, sign-in, Home loading, search, details, playback entry, settings, sign-out, and focus navigation.
- Playback verification on physical Apple TV for HLS playback, remote behavior, audio/subtitle selection, buffering, memory, and long playback.
- Backend regression coverage for capability contract, playback sessions, progress updates, stream tokens, HLS manifests, and catalog responses used by TV.

## Highest-Priority Future Tests

As soon as implementation begins, prioritize:

- `ServerURL` validation tests for valid, invalid, unreachable, and TLS/problem states.
- API DTO decoding tests for `/api/v1/system/capabilities`, auth, Home, details, and playback routes.
- Auth service tests that prove tokens are never surfaced in user-visible errors.
- Keychain storage wrapper tests with a test double.
- Playback progress cadence tests independent from AVKit.
- UI focus tests for first-launch server setup and sign-in forms.
- Launch and smoke tests against the real app root after replacing `ContentView`.

## Physical Device Requirement

The PRD explicitly requires physical Apple TV verification before broad catalog polish:

- HLS playback behavior may differ across simulator and hardware.
- Remote behavior and focus movement must be validated on device.
- Audio/subtitle selection, buffering, memory, and long playback need hardware validation.

This is a release risk area because automated simulator tests will not be sufficient.

## Test Data Needs

Future test fixtures should cover:

- Empty library.
- Small library.
- Large library.
- Missing artwork.
- Movie with direct play.
- Movie requiring HLS/transcode.
- Episode playback.
- Expired token.
- Unsupported capability set.
- Stream-token expiry.
- Backend error envelopes that must be converted to safe client errors.

## Gaps And Risks

- No CI configuration is present.
- No test plan file is present.
- No mocks, fixtures, or API sample responses are present.
- Generated placeholder tests can create a false sense of coverage.
- Simulator service warnings observed during mapping may affect command-line UI testing until the local Xcode environment is healthy.
