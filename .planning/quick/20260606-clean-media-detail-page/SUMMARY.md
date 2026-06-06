---
status: complete
completed: 2026-06-06
slug: clean-media-detail-page
---

# Summary

Cleaned up the media detail page by making the hero artwork target the physical tvOS screen width instead of only the navigation container width, reducing the hero from three overlapping gradient layers to two purposeful fades, lowering the hero height, and keeping the below-hero content in a simple readable column.

Follow-up: removed the remaining parent-width clipping and switched the hero bleed to explicit negative safe-area padding so the backdrop can reach the left and right screen edges without relying on `UIScreen`.

Navigation cleanup: removed detail presentation from `TabView.navigationDestination` and moved it into the app shell as a full-screen state overlay. Detail artwork is now a root full-screen background layer instead of a scroll-view hero child, eliminating width recalculation flashes and tab/navigation container clipping.

Cast fix: verified `Lumina-API` emits top-level `credits` with numeric `person_id` fields from `GET /api/v1/catalog/movies/:id`. The tvOS credit decoder previously tried to decode `person_id` as a string before trying integer fallback, which caused each credit object to fail decoding and left cast empty. The decoder now treats each ID representation independently.

Aligned detail decoding with the real movie detail payload shape by supporting `list_membership` and flat `credits` arrays with `credit_type`, so watchlist/favorite state and cast credits show correctly from `GET /api/v1/catalog/movies/:id`.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived CODE_SIGNING_ALLOWED=NO` passed.
- `xcodebuild test -project lumina.xcodeproj -scheme lumina -destination 'platform=tvOS Simulator,name=Apple TV'` could not run because CoreSimulator was unavailable and Xcode selected no concrete tvOS simulator.
