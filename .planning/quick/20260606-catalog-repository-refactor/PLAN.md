---
status: completed
created: 2026-06-06
task: catalog-repository-refactor
---

# Catalog Repository Refactor

## Goal

Continue moving backend orchestration out of `AppModel` by extracting catalog loading, search, detail, and season episode flows into focused repository types.

## Scope

- Add catalog repository models that aggregate API responses into app-ready state.
- Keep `AppModel` responsible for UI state transitions only.
- Preserve current tvOS UI behavior.
- Add focused tests for the new pure aggregation path where practical.
- Verify with generic tvOS build and test-build.

## Notes

- `gsd-sdk` is unavailable in this environment, so this file is the manual quick-task trace.
- Existing uncommitted changes are treated as user work and must not be reverted.

## Result

- Added `CatalogRepository` to aggregate Home, search, movie detail, TV show detail, and season episode API calls.
- Added snapshot value types for catalog home and TV show detail state.
- Updated `AppModel` so catalog methods apply repository snapshots instead of orchestrating every endpoint inline.
- Added a fake `LuminaAPIClient` in tests for repository-level async coverage.
- Added tests for Home snapshot aggregation and TV show first-season episode loading.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing`

Simulator test execution remains blocked by CoreSimulatorService failures in this environment.
