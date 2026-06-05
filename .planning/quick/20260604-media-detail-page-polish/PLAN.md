# Quick Task 20260604: media detail page polish

## Goal

Make the native tvOS media detail page more beautiful and easier to navigate with the Apple TV remote, while keeping the implementation simple and scoped to existing catalog detail code.

## Tasks

### 1. Polish the detail hero and action layout

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Improve the visual hierarchy with a cinematic backdrop, poster, clear metadata, overview, progress, and a focused primary Play/Resume action.
- Verify: Movie detail still focuses the play action when playable and still calls `playCatalogMovie(_:)`.

### 2. Keep TV navigation simple

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Preserve season and episode behavior while making season controls easier to scan on tvOS.
- Verify: Season selection still calls `selectTVSeason(_:)` and episode shelves remain intact.

### 3. Build verification

- Action: Run a tvOS build with signing disabled.
- Verify: `xcodebuild` passes or document the local blocker.
