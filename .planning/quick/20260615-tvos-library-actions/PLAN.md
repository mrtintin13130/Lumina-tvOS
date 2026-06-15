# tvOS Library Actions Plan

Date: 2026-06-15

## Goal

Add first-pass watchlist and favorite controls to the native tvOS detail screen using the documented Lumina catalog action routes.

## Scope

- Use existing built-in SwiftUI button/focus behavior.
- Keep state server-authoritative by refreshing the selected detail item after successful toggles.
- Respect server capability flags before showing controls.
- Support movies and TV shows only for this slice, matching the documented backend examples.

## Tasks

1. Extend networking
   - Add a reusable library-action payload DTO.
   - Add watchlist/favorite mutation methods to `LuminaAPIClient`.
   - Implement `POST` for add and `DELETE` with query parameters for remove.

2. Extend app model
   - Add capability-gated action availability.
   - Add `toggleWatchlist(_:)` and `toggleFavorite(_:)`.
   - Refresh selected movie/TV show detail after successful mutation.
   - Map unsupported media or backend failures to safe status messages.

3. Extend detail UI
   - Add focusable Watchlist and Favorite buttons beside Play.
   - Use built-in SF Symbols and existing tvOS button styling.
   - Keep passive membership labels as secondary state.

4. Verify
   - Add focused unit coverage for URLSession route/body behavior where practical.
   - Run Swift compile/build gate as far as the local Xcode environment allows.
