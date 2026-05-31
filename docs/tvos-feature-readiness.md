# tvOS Feature Readiness Notes

## Home, Browse, Search, And Details

- Home must render backend section order from `/api/v1/catalog/home`.
- Search must call backend-supported parameters only and distinguish empty query from no results.
- Browse must keep movie and TV paths separate until backend facets prove a shared model is safe.
- Detail screens must show play/resume, progress, metadata, artwork fallback, watchlist/favorite state, and safe non-playable states.
- Focus should land on the first safe primary action and remain stable after async artwork loads.

## Full Playback And Library Actions

- Movies use `/api/v1/stream/movies/:id/hls/manifest.m3u8` by default.
- Episodes use `/api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/hls/manifest.m3u8` by default.
- Progress reports every 15-30 seconds and on pause, seek, exit, and completion.
- Completion and watched state follow backend rules.
- Watchlist and favorite toggles may be optimistic but must refresh and recover from backend failure.
- Subtitle and audio selection rely on native HLS renditions unless backend selection behavior is documented.

## Settings And Diagnostics

- Settings must show connected server, signed-in user, app version/build, server validation, diagnostics, and sign-out.
- Diagnostics may include app version, tvOS version, server version, route key, status code, correlation ID, playback session ID, media ID, media kind, playback position, error category, and retryability.
- Diagnostics must not include JWTs, stream tokens, passwords, Authorization headers, signed URLs, local filesystem paths, SQL details, stack traces, or raw subprocess output.
- UI tests should cover setup, sign-in, Home, search, details, playback entry, library actions, Settings, and logout.

