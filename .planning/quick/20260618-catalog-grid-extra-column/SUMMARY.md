---
status: complete
slug: catalog-grid-extra-column
date: 2026-06-18
---

# Quick Task: Catalog Grid Extra Column

Reduced the shared Movies and TV Shows catalog grid item range from `250...270` pt to `220...240` pt, preserving the existing 34 pt spacing while allowing one additional adaptive poster column on the standard tvOS page layout.

Verification:

- Confirmed the changed adaptive grid is the shared `CatalogGridView` used by Movies and TV Shows.
- Ran `xcodebuild -project lumina.xcodeproj -scheme lumina -sdk appletvsimulator -destination 'generic/platform=tvOS Simulator' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO build`.
- Build succeeded. Xcode emitted the existing local CoreSimulator service warnings, but compilation and app build completed successfully.
