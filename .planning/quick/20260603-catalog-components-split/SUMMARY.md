---
status: complete
completed: 2026-06-03
---

# Catalog Components Split Summary

Extracted shared catalog presentation helpers out of `ContentView.swift`.

## Changes

- Moved `CatalogHeader`, `FeaturedCatalogButton`, `CatalogShelfView`, `CatalogPosterButton`, `CatalogArtwork`, `EmptyCatalogState`, and catalog display helpers into `lumina/Views/CatalogComponents.swift`.
- Moved `StatusText` into `lumina/Views/StatusText.swift`.
- Updated `lumina.xcodeproj/project.pbxproj` so both new Swift files are included in the app target.
- Left screen-level views in `ContentView.swift`; it now holds app phase routing, setup/sign-in/home/search/grid/playback/settings composition, and small local badges/cards.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived-components CODE_SIGNING_ALLOWED=NO` passed.
- `xcodebuild test -project lumina.xcodeproj -scheme lumina -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath /tmp/lumina-derived-components-tests CODE_SIGNING_ALLOWED=NO` passed.
- Test output reported 20 unit tests plus 4 UI/launch test cases passed.
