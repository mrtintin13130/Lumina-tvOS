---
status: complete
date: 2026-06-05
---

# Quick Task 20260605 Summary: detail page edge to edge

## Completed

- Hid the navigation bar on `CatalogDetailPage` so the media title no longer appears at the top of the screen.
- Let the detail hero ignore top and horizontal container safe areas so the backdrop can extend to the screen edges instead of appearing as a contained rectangle.
- Kept the readable detail content inset within the full-screen artwork.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO build` passed.
