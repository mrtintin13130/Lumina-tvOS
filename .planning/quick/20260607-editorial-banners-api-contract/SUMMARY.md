---
date: 2026-06-07
task: editorial-banners-api-contract
status: completed
---

# Summary

Updated the tvOS catalog Home implementation for the revised Lumina API editorial banner contract.

## Completed

- Decoded Home `layout` metadata and section-level `genre_id`, `eyebrow`, `subtitle`, and `tags`.
- Added `GET /api/v1/catalog/editorial/:sectionId` support through the API client and catalog repository.
- Changed `cinematic_banner` Home sections to render as focused section-level editorial banners using section metadata.
- Added an editorial collection overlay that loads the full curated section and presents its items as landscape media cards.
- Preserved `spotlight_rail` behavior as a regular horizontal landscape shelf.
- Added test coverage for the new decoding shape and repository editorial fetch path.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`
- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`

Both commands passed. Simulator execution was not attempted because CoreSimulatorService is unavailable in this environment.
