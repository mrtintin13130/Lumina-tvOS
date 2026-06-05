# Quick Task 20260605: plex inspired detail UI

## Goal

Improve the media detail page so it feels closer to a polished Apple TV streaming app experience, using Plex-inspired layout principles without cloning Plex directly.

## Tasks

### 1. Recompose the hero

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Replace the poster-heavy hero with a dimmed full-screen artwork background, left-aligned title/logo, compact metadata, overview, progress, and action pills.
- Verify: Movie Play/Resume still receives default focus and still calls `playCatalogMovie(_:)`.

### 2. Reduce visual clutter below the hero

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Replace boxed status cards/chips with quieter text-first detail rows and keep TV seasons/episodes navigable.
- Verify: TV season controls still call `selectTVSeason(_:)`.

### 3. Build verification

- Action: Run the generic tvOS build with signing disabled.
- Verify: Build passes or document the local blocker.
