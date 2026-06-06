---
date: 2026-06-07
task: api-driven-home-section-layouts
status: completed
---

# Summary

Updated Home catalog section rendering so shelves are selected by `presentation.layout`.

## Completed

- Made `poster_rail` render normal portrait poster cards, so Recent Movies is portrait when the API returns that layout.
- Kept `spotlight_rail` as the larger landscape feature-card shelf.
- Added explicit render paths for `cinematic_carousel`, `continue_landscape`, `compact_rail`, `genre_pills`, `logo_card_rail`, and `cinematic_banner`.
- Added continue-watching progress landscape cards.
- Added compact portrait poster cards for denser rails.
- Added logo card rails for studio/network-style rows.
- Added test coverage for the layout mapping.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`
- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`

Both passed. A first parallel `build-for-testing` attempt failed because the shared Xcode build database was locked by the simultaneous build; the sequential rerun passed.
