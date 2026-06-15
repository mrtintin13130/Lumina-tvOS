# tvOS Library Actions Summary

Date: 2026-06-15
Status: Implemented, compiler-gated as far as the local Xcode environment allowed

## What changed

- Added `LibraryMembershipRequest` for watchlist/favorite mutation payloads.
- Extended `LuminaAPIClient` with:
  - `setWatchlisted(mediaType:mediaId:isWatchlisted:token:)`
  - `setFavorite(mediaType:mediaId:isFavorite:token:)`
- Implemented documented catalog action routes:
  - `POST /api/v1/catalog/watchlist`
  - `DELETE /api/v1/catalog/watchlist?media_type=...&media_id=...`
  - `POST /api/v1/catalog/favorites`
  - `DELETE /api/v1/catalog/favorites?media_type=...&media_id=...`
- Added capability-gated app model actions for movies and TV shows.
- Detail pages now show focusable Watchlist and Favorite buttons when supported by server capabilities.
- Successful mutations refresh the selected detail item from the backend so visible state remains server-authoritative.
- Added request-shape tests for watchlist add and favorite remove.

## Verification

- Ran static sweeps for new protocol methods, app model actions, and detail labels.
- Ran `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`.
- The command compiled the changed app files and emitted the `luminaTests` module before manual interruption caused by the same CoreSimulator/Xcode service hang seen earlier.
- No Swift compiler diagnostics appeared, and no `error:` or `warning:` entries were found in `/private/tmp/lumina-derived-data/Logs/Build`.

## Remaining follow-up

- Run full tests in a healthy Xcode environment.
- Validate watchlist/favorite mutations against a real Lumina server.
- Consider adding optimistic button disabled/loading state after broader detail-screen state management is in place.
