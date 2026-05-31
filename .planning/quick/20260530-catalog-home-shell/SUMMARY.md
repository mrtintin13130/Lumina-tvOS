---
status: complete
completed: 2026-05-30
---

# Catalog Home Shell Summary

Implemented a native tvOS catalog shell with Home, Movies, TV Shows, Search, and Settings tabs.

## Changes

- Added flexible catalog DTOs for home sections, browse cards, and search results.
- Added API client calls for `/api/v1/catalog/home`, `/api/v1/catalog/movies`, `/api/v1/catalog/tv_shows`, and `/api/v1/catalog/search`.
- Added app model state and loaders for catalog shelves, browse lists, and search.
- Replaced placeholder Home cards with a `TabView` menu and Apple TV-style horizontal shelf rows.
- Added poster/backdrop artwork loading through `AsyncImage`.
- Wired movie catalog cards into the existing playback proof path.

## Follow-up Fixes

- Resolved TMDB-style catalog artwork paths such as `/qQclTgLMDvGBuUBFGHRipxkEwWR.jpg` to `image.tmdb.org` poster/backdrop URLs.
- Preserved server-relative API artwork paths for future backend image proxy routes.
- Fixed poster card geometry so multi-line titles and optional progress bars do not change shelf/card height.
- Added tests for catalog presentation artwork decoding and artwork URL resolution.

## Verification

- `xcodebuild build-for-testing -quiet -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` passed after the initial catalog implementation.
- `xcodebuild build-for-testing -quiet -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath ./.derived-data CODE_SIGNING_ALLOWED=NO` passed after the artwork/layout follow-up.
