---
status: in_progress
created: 2026-06-06
slug: clean-media-detail-page
---

# Clean Media Detail Page

Simplify the tvOS catalog detail page so the backdrop is truly full-bleed across the screen, the hero is easier to reason about, and visible metadata matches the real movie detail response shape.

## Scope

- Keep API and navigation behavior unchanged.
- Refactor `CatalogDetailOverlay.swift` only unless tests reveal a decode gap.
- Preserve Play/Resume, trailer, cast, TV seasons, loading, and status affordances.
- Favor a clean tvOS layout with fewer nested hero components and fewer overlapping gradients.

## Verification

- Build or test with `xcodebuild` if the local simulator/toolchain permits.
- Run focused unit tests if the full tvOS test path is unavailable.
