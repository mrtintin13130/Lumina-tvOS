# Quick Task 20260604: replace movie detail overlay with dedicated tvOS detail page

## Goal

Replace the catalog detail overlay with a dedicated SwiftUI navigation page so movie detail focus and back behavior are isolated from the Home tab shell on tvOS.

## Tasks

### 1. Replace overlay presentation with navigation

- Files: `lumina/Views/CatalogScreens.swift`
- Action: Remove the `ZStack` overlay wrapper and add a navigation destination driven by `AppModel.selectedCatalogItem`.
- Verify: Selecting a catalog item still calls `openCatalogDetail(_:)`, and clearing the destination closes detail state.
- Done: Home tab content is no longer active behind a full-screen overlay.

### 2. Convert detail overlay view into a detail page

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Rename the SwiftUI type to `CatalogDetailPage`, remove the opaque overlay shell and close button, add tvOS page chrome, focus the primary action, and keep movie playback plus TV season/episode sections intact.
- Verify: Movie details render as a standalone page and play action remains available for playable movies.
- Done: Detail UI behaves as a page rather than a modal overlay.
