# Home Dynamic Gradient Plan

Date: 2026-06-16

## Goal

Use API-provided catalog item colors to drive a Plex-like, smoothly animated Home background gradient when focus changes between media items.

## Scope

- Decode optional `colors` from `CatalogItem`.
- Use `background`, `backgroundSecondary`, and `accent`; ignore `text` for now.
- Debounce rapid focus movement before updating the Home background.
- Keep the animation slow and smooth.
- Fall back to the existing black/dark background when colors are missing or invalid.

## Tasks

1. Extend catalog model
   - Add a nested color palette DTO to `CatalogItem`.
   - Parse hex color strings into SwiftUI colors without forcing app-wide dependencies.

2. Add Home gradient state
   - Track the displayed gradient separately from immediate focused item selection.
   - Debounce focus-driven palette changes.
   - Animate palette changes slowly.

3. Render gradient
   - Add a full-screen Home background gradient behind the contextual hero and shelves.
   - Blend accent subtly so it feels atmospheric rather than loud.

4. Verify
   - Run static diff checks.
   - Run build gate if the local Xcode environment allows.
