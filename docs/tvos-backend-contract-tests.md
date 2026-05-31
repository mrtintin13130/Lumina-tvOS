# tvOS Backend Contract Test Requirements

**Status:** v1.1 reconciled proof-path requirements

These tests should be implemented against the Lumina backend or documented as explicit acceptance checks before the tvOS client depends on the related behavior. All changes are additive.

## Capabilities

- `GET /api/v1/system/capabilities` returns 200 with server, API, auth, playback, library, diagnostics, routes, and limits sections.
- Unsupported optional features are represented as explicit booleans or missing route keys, not by throwing errors.
- Response contains no tokens, signed URLs, filesystem paths, SQL details, stack traces, or raw subprocess output.
- An older or unsupported server produces a stable capability or error state the client can classify.
- Supported v1.1 proof-path response includes route keys for `authLogin`, `authMe`, `catalogMovies`, `catalogMovieDetail`, `streamToken`, `movieHlsManifest`, `movieHlsPlaylist`, `movieHlsSegment`, `playbackSessions`, `playbackSession`, `playbackSessionStop`, `movieProgress`, and `movieProgressUpdate`.

## Auth And Session

- Username/password JWT login returns token material only from the auth route.
- `/api/v1/auth/me` or equivalent validates restored sessions and returns safe current-user display data.
- Expired or invalid tokens return a stable auth category with safe message and retryability.
- Authorization headers and JWTs are never reflected in response bodies, diagnostics, or errors.

## Catalog And Details

- `/api/v1/catalog/home` preserves backend section order.
- Search and browse endpoints document supported filters, sorting, facets, and pagination.
- Movie and TV detail routes return playability, progress, artwork, watchlist/favorite state, and safe non-playable states.
- Detail responses never expose local filesystem paths.

## Playback And Progress

- Playback sessions can be created through `/api/v1/playback/sessions` when capabilities say session support exists.
- Movie HLS route supports `/api/v1/stream/movies/:id/hls/manifest.m3u8`.
- Episode HLS route supports `/api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/hls/manifest.m3u8`.
- Protected stream access has a documented scoped-token or authorized-manifest flow.
- Progress accepts updates every 15-30 seconds and on pause, seek, exit, and completion.
- Resume state is returned after relaunch from backend progress.
- Completion updates watched state according to backend rules.
- Movie playback session create accepts `media_type`, `media_id`, `position_seconds`, `play_state`, and `client_label`.
- Playback session update accepts `position_seconds`, `play_state`, and optional safe `selection_diagnostics`.
- Playback session stop accepts `position_seconds` and terminal `play_state`.
- Movie progress read/write uses `/api/v1/playback/movies/:movieId/progress`; the generic `/api/v1/playback/progress` placeholder is not required by the v1.1 tvOS proof contract.

## Protected HLS Token Transport

- `POST /api/v1/stream/token` can issue or describe a scoped token for movie playback.
- Movie manifest accepts the scoped token through an AVKit-compatible URL transport such as `stream_token`.
- Child playlists emitted by the manifest remain authorized when loaded by AVKit without app-injected custom headers.
- Segment URLs emitted by playlists remain authorized when loaded by AVKit without app-injected custom headers.
- Subtitle URLs remain authorized when loaded by AVKit without app-injected custom headers.
- Expired, missing, or invalid stream tokens return stable `stream_token`, `manifest`, `segment`, or `track` categories with retryability and correlation.
- Diagnostics, logs, and support evidence redact tokenized URLs and token-like query strings.

## Error Envelope

- Validation, auth, capability, stream-token, manifest, segment, track, missing-media, and server-restart failures return stable codes and categories.
- Each error includes safe user message mapping, retryability, and request or playback correlation where available.
- Error details never include secrets, signed URLs, filesystem paths, SQL details, stack traces, or raw subprocess output.

## Library Actions

- Watchlist and favorite list/toggle routes are documented in capabilities before the client shows controls.
- Toggle failures return stable retryable or non-retryable errors.
- Refresh after optimistic updates returns consistent state across Home, Browse, and Detail.

## Diagnostics

- Request correlation IDs and playback session IDs can be correlated by support.
- Diagnostics are support-oriented and do not include monetization analytics events.
- Redaction tests assert that token-like values, Authorization headers, signed URLs, local paths, SQL strings, and stack-trace markers are absent.

## Additive Gap List

| Gap | Required for | Test requirement |
|-----|--------------|------------------|
| Formal `GET /api/v1/system/capabilities` response | Setup, compatibility, feature gating | Positive supported response, unsupported server response, and v1.1 proof route-key completeness. |
| Stable TV error envelope | Setup, auth, playback, diagnostics | Representative failures for validation, auth, capability, stream-token, manifest, segment, missing media, and server unavailable states. |
| Playback session correlation | Playback proof and diagnostics | Session creation, update, stop, progress linkage, and safe correlation ID behavior. |
| Scoped stream-token behavior | Protected HLS playback | Token issuance/application for manifest, child playlist, segment, and subtitle loads without diagnostics leakage. |
| Progress cadence and completion semantics | Resume and watched state | Cadence acceptance, pause/exit update, stop update, completion update, and relaunch resume. |
| Catalog playable movie selection | v1.1 proof path | Documented query/filter contract for finding one playable movie plus detail response with playability and resume data. |
| Artwork availability and fallback metadata | Home, browse, details | Missing and partial artwork responses remain safe and predictable. |
| Library action capability flags | Watchlist/favorite controls | Controls hidden when unsupported; toggle/list routes tested when supported. |
