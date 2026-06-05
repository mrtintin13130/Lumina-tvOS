# Quick Task 20260605: detail page edge to edge

## Goal

Remove the remaining navigation-title and safe-area framing from the media detail screen so the artwork reads as a true edge-to-edge Apple TV detail page.

## Tasks

### 1. Hide navigation chrome

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Remove the visible navigation title/bar from the detail page.
- Verify: The media title no longer appears at the top of the screen.

### 2. Extend hero to screen edges

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Let the hero ignore top and horizontal safe areas while keeping readable content inset inside the artwork.
- Verify: The backdrop no longer appears as a contained rectangle with black spacing around it.

### 3. Build verification

- Action: Run the generic tvOS build with signing disabled.
- Verify: Build passes or document the local blocker.
