---
phase: 08-backend-contract-reconciliation
plan: 03
subsystem: contract-tests
tags:
  - fixtures
  - xctest
provides:
  - v1.1 capabilities fixture coverage
affects:
  - lumina/LuminaCore.swift
  - luminaTests/Fixtures/capabilities-supported.json
  - luminaTests/luminaTests.swift
tech-stack:
  added: []
  patterns:
    - compatibility tests assert route-key presence
key-files:
  created: []
  modified:
    - lumina/LuminaCore.swift
    - luminaTests/Fixtures/capabilities-supported.json
    - luminaTests/luminaTests.swift
key-decisions:
  - `movieProgressUpdate` is the reconciled progress compatibility route key, with transitional tolerance for `progressUpdate`.
patterns-established:
  - Supported capabilities fixtures should pressure every proof-path route family needed by Phase 9.
duration: "20min"
completed: 2026-05-30
status: complete
---

# Phase 8 Plan 03 Summary: Contract Fixtures And Verification

Aligned the supported capabilities fixture and focused unit assertions with the reconciled v1.1 proof-path route keys.

## Accomplishments

- Added supported capability route keys for auth, catalog movie detail, stream token, HLS playlist/segment, playback session lifecycle, movie progress, watched, tracks, subtitles, watchlist, and favorites.
- Added unit assertions for the critical Phase 9 proof-path keys.
- Updated `ServerCapabilities.isTvMVPCompatible` to accept `movieProgressUpdate` while tolerating the prior `progressUpdate` key during transition.

## Verification

- JSON fixtures parsed successfully with Node.
- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` succeeded.
- `xcodebuild test` could not run because CoreSimulatorService is unavailable and generic destinations cannot execute tests.

## Next Phase Readiness

Phase 9 can replace placeholder route construction and payloads with the documented v1.1 contract.
