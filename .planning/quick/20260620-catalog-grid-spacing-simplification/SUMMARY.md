---
status: complete
slug: catalog-grid-spacing-simplification
date: 2026-06-20
---

# Quick Task: Catalog Grid Spacing Simplification

Reduced the Movies and TV Shows browse page top inset from the general catalog content padding to a named `browseGridTopPadding` of `24` pt. The existing 80 pt horizontal content rail remains in place so focused poster content stays within the Apple TV-safe viewing area.

Verification:

- Confirmed the changed top padding is used only by the shared Movies and TV Shows `CatalogGridView` call sites.
- Ran `xcodebuild -project lumina.xcodeproj -scheme lumina -sdk appletvsimulator -destination 'generic/platform=tvOS Simulator' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO build`.
- Build succeeded. Xcode emitted the existing local CoreSimulator service warnings, but compilation and app build completed successfully.
