# Lumina tvOS API Contract

**Status:** v1.1 reconciled proof-path contract
**Audience:** Native tvOS client and Lumina backend developers

This document defines the TV-facing contract the native Apple TV client may rely on. The backend remains the source of truth for catalog composition, identity, playback, progress, watched state, watchlist, favorites, stream tokens, HLS/direct streaming, subtitles, track metadata, scanner state, metadata, and diagnostics. MVP backend changes must be additive.

## Compatibility Flow

1. The user enters a Lumina server base URL manually.
2. The tvOS client validates basic reachability without storing credentials.
3. The client requests `GET /api/v1/system/capabilities`.
4. The client decides whether the server is compatible before sign-in or feature use.
5. Unsupported capabilities become safe setup or feature-disabled states, not crashes or hidden failures.

## Capability Contract

`GET /api/v1/system/capabilities` should return safe JSON with no tokens, filesystem paths, SQL details, stack traces, or signed URLs.

Required top-level fields:

| Field | Type | Purpose |
|-------|------|---------|
| `server.name` | string | Human-readable product/server name. |
| `server.version` | string | Server release or build version. |
| `api.version` | string | TV-consumed API contract version. |
| `api.minimumTvClientVersion` | string | Oldest supported tvOS client contract version. |
| `auth.modes` | string array | Supported auth modes, including `password_jwt` for MVP. |
| `auth.sessionValidationRoute` | string | Route the client can call to restore a session. |
| `playback.hls` | object | HLS support, stream-token requirement, progress cadence, and session support. |
| `library` | object | Supported catalog, search, details, artwork, watchlist, favorite, and scanner capabilities. |
| `diagnostics` | object | Correlation and safe client diagnostics behavior. |
| `routes` | object | Route availability by stable route key. |
| `limits` | object | Client-safe size, page, artwork, and progress limits. |

Compatibility requirements for v1.1 movie playback proof:

- `auth.modes` includes `password_jwt`.
- `auth.sessionValidationRoute` is present and points to `/api/v1/auth/me`.
- `playback.hls.movies` is `true`.
- `playback.streamTokens.requiredForProtectedStreams` is explicitly declared.
- `playback.progress.supported` is `true`.
- `playback.sessions.supported` is `true`.
- `routes.catalogMovies`, `routes.catalogMovieDetail`, `routes.streamToken`, `routes.movieHlsManifest`, `routes.playbackSessions`, `routes.movieProgress`, `routes.movieProgressUpdate`, and `routes.playbackSessionStop` are present before proof playback is enabled.
- Missing optional features disable only their related UI controls.

## v1.1 Route Keys

The tvOS client should prefer route keys from capabilities over hard-coded paths once capabilities are decoded. The following keys are required or optional for the v1.1 proof path.

| Route key | Required for proof | Method | Route or route family | Source |
|-----------|--------------------|--------|-----------------------|--------|
| `apiInfo` | No | `GET` | `/api/v1` | `rest-client/00-health-auth.http` |
| `health` | No | `GET` | `/api/v1/health` | `rest-client/00-health-auth.http` |
| `capabilities` | Yes | `GET` | `/api/v1/system/capabilities` | Implemented backend route |
| `authSetupStatus` | No | `GET` | `/api/v1/auth/setup/status` | `rest-client/00-health-auth.http` |
| `authLogin` | Yes | `POST` | `/api/v1/auth/login` | `rest-client/00-health-auth.http` |
| `authMe` | Yes | `GET` | `/api/v1/auth/me` | `rest-client/00-health-auth.http` |
| `catalogHome` | No | `GET` | `/api/v1/catalog/home` | `rest-client/05-catalog.http` |
| `catalogSearch` | No | `GET` | `/api/v1/catalog/search` | `rest-client/05-catalog.http` |
| `catalogMovies` | Yes | `GET` | `/api/v1/catalog/movies` | `rest-client/05-catalog.http` |
| `catalogMovieDetail` | Yes | `GET` | `/api/v1/catalog/movies/:movieId` | `rest-client/05-catalog.http` |
| `catalogTvShows` | No | `GET` | `/api/v1/catalog/tv_shows` | `rest-client/05-catalog.http` |
| `streamToken` | Yes for protected streams | `POST` | `/api/v1/stream/token` | `rest-client/04-stream-playback.http` |
| `streamClientInfo` | No | `GET` | `/api/v1/stream/client-info` | `rest-client/04-stream-playback.http` |
| `movieStreamInfo` | No | `GET` | `/api/v1/stream/movies/:movieId/info` | `rest-client/04-stream-playback.http` |
| `movieHlsManifest` | Yes | `GET` | `/api/v1/stream/movies/:movieId/hls/manifest.m3u8` | `rest-client/04-stream-playback.http` |
| `movieHlsPlaylist` | Yes for HLS validation | `GET` | `/api/v1/stream/movies/:movieId/hls/playlist/:quality.m3u8` | `rest-client/04-stream-playback.http` |
| `movieHlsSegment` | Yes for HLS validation | `GET` | `/api/v1/stream/movies/:movieId/hls/segment/:quality/:segment.ts` | `rest-client/04-stream-playback.http` |
| `movieSubtitle` | No for movie proof, yes for subtitle validation | `GET` | `/api/v1/playback/movies/:movieId/subtitles/:subtitleId` | `rest-client/04-stream-playback.http` |
| `playbackSessions` | Yes | `POST`, `GET` | `/api/v1/playback/sessions` | `rest-client/04-stream-playback.http` |
| `playbackSession` | Yes | `PUT` | `/api/v1/playback/sessions/:sessionId` | `rest-client/04-stream-playback.http` |
| `playbackSessionStop` | Yes | `POST` | `/api/v1/playback/sessions/:sessionId/stop` | `rest-client/04-stream-playback.http` |
| `movieProgress` | Yes | `GET` | `/api/v1/playback/movies/:movieId/progress` | `rest-client/04-stream-playback.http` |
| `movieProgressUpdate` | Yes | `PUT` | `/api/v1/playback/movies/:movieId/progress` | `rest-client/04-stream-playback.http` |
| `movieWatched` | No for proof, required for completion polish | `PUT` | `/api/v1/playback/movies/:movieId/watched` | `rest-client/04-stream-playback.http` |
| `movieTracks` | No for proof, required for track polish | `GET` | `/api/v1/playback/movies/:movieId/tracks` | `rest-client/04-stream-playback.http` |
| `watchlist` | No | `GET`, `POST`, `DELETE` | `/api/v1/catalog/watchlist` | `rest-client/05-catalog.http` |
| `watchlistMembership` | No | `GET` | `/api/v1/catalog/watchlist/membership` | `rest-client/05-catalog.http` |
| `favorites` | No | `GET`, `POST`, `DELETE` | `/api/v1/catalog/favorites` | `rest-client/05-catalog.http` |
| `favoritesMembership` | No | `GET` | `/api/v1/catalog/favorites/membership` | `rest-client/05-catalog.http` |

## Route Matrix

| TV behavior | Backend ownership | Expected route or route family | Client expectation |
|-------------|-------------------|--------------------------------|--------------------|
| Server compatibility | Backend | `GET /api/v1/system/capabilities` | Determines supported auth, catalog, playback, library actions, diagnostics, and limits. |
| Sign in | Backend | `routes.authLogin`, currently `/api/v1/auth/login` | Returns token material only in the auth response; client stores it only through Keychain. |
| Session restore | Backend | `routes.authMe`, currently `/api/v1/auth/me` | Confirms restored JWT and returns safe current-user display data. |
| Home | Backend | `/api/v1/catalog/home` | Preserves backend section order; client does not reorder sections. |
| Search | Backend | `/api/v1/catalog/search` | Uses backend-supported query parameters only. |
| Movie browse | Backend | `/api/v1/catalog/movies` | Supports documented filters, sorting, facets, and pagination. |
| TV browse | Backend | `/api/v1/catalog/tv_shows` | Supports documented filters, sorting, facets, and pagination. |
| Movie detail | Backend | `routes.catalogMovieDetail`, currently `/api/v1/catalog/movies/:movieId` | Returns playability, metadata, artwork, progress, watchlist/favorite state, and trailers where available. |
| TV detail | Backend | TV show, season, and episode detail routes documented in capabilities | Returns season/episode hierarchy and playable episode detail data. |
| Playback session | Backend | `routes.playbackSessions`, `routes.playbackSession`, `routes.playbackSessionStop` | Creates, updates, and stops a correlatable session before and during protected playback. |
| Movie HLS | Backend | `routes.movieHlsManifest`, currently `/api/v1/stream/movies/:movieId/hls/manifest.m3u8` | Preferred movie playback route on Apple TV. |
| Episode HLS | Backend | `/api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/hls/manifest.m3u8` | Preferred episode playback route on Apple TV. |
| Stream token | Backend | `routes.streamToken`, currently `/api/v1/stream/token` | Returns scoped token or token application instructions without exposing it in diagnostics. |
| Progress | Backend | `routes.movieProgress` and `routes.movieProgressUpdate`, currently `/api/v1/playback/movies/:movieId/progress` | Accepts updates every 15-30 seconds and on pause, seek, exit, and completion. |
| Watched state | Backend | Watched state route documented in capabilities | Completion follows backend rules. |
| Watchlist/favorite | Backend | Library action routes documented in capabilities | Client can optimistically update but must recover from refresh. |
| Diagnostics correlation | Backend and client | Diagnostics route or correlation headers documented in capabilities | Supports request/session/playback correlation without analytics creep. |

## Phase 9 Alignment Targets

Current Swift proof code intentionally predates this reconciliation. Phase 9 should replace these placeholders with the v1.1 contract above:

| Current assumption | v1.1 target |
|--------------------|-------------|
| Login fallback paths `/auth/login` and `/login` | Use `routes.authLogin` or `/api/v1/auth/login`. |
| Session fallback paths `/auth/me` and `/me` | Use `routes.authMe` or `/api/v1/auth/me`. |
| Movie browse query `/api/v1/catalog/movies?playable=true&limit=1` | Use documented catalog query parameters from capabilities or backend contract; `playable_only=true` is the current `rest-client/` search parameter, while browse examples use filters without `playable`. |
| Generic `PlayableMovie.hlsManifestPath` dependency | Construct route-key based movie HLS URL from `movieHlsManifest` unless detail response explicitly provides a safe relative path. |
| `POST /api/v1/playback/sessions` body using `mediaId` and `mediaKind` | Use snake_case `media_type`, `media_id`, `position_seconds`, `play_state`, and `client_label`. |
| Generic `POST /api/v1/playback/progress` | Use `GET` and `PUT /api/v1/playback/movies/:movieId/progress` for proof-path resume/progress. |
| Generic `ProgressUpdateRequest` with camelCase fields and event | Use real movie progress payload plus playback session update/stop calls for session lifecycle. |

## Error Envelope

TV-consumed JSON errors should use a stable envelope:

```json
{
  "error": {
    "code": "STREAM_TOKEN_EXPIRED",
    "category": "stream_token",
    "safeMessage": "The playback link expired. Try playing again.",
    "retryable": true,
    "correlationId": "req_01HYSAFE",
    "details": {
      "mediaKind": "movie",
      "operation": "start_playback"
    }
  }
}
```

Required fields:

| Field | Purpose |
|-------|---------|
| `code` | Stable machine code suitable for tests and client mapping. |
| `category` | Client category such as `validation`, `auth`, `capability`, `stream_token`, `manifest`, `segment`, `track`, `missing_media`, `server_restart`, or `unknown`. |
| `safeMessage` | User-safe text with no backend internals or secrets. |
| `retryable` | Whether retry is reasonable from the same screen. |
| `correlationId` | Request or session correlation value safe for support. |
| `details` | Optional safe context only. |

## Redaction Rules

Never return, log, display, or include in diagnostics:

- JWTs, refresh tokens, stream tokens, passwords, or Authorization headers.
- Signed URLs or query strings containing token-like fields.
- Local filesystem paths.
- SQL details, stack traces, raw subprocess output, or private environment values.
- Raw HLS URLs when they include protected tokens.

Allowed diagnostics fields:

- App version/build, tvOS version, device class, screen name, operation name.
- Server version, API version, capability flags, route key, status code.
- Safe request correlation ID, playback session ID, media ID, media kind.
- Playback state, current time, duration, progress update reason, retry count.
- Error category, stable error code, retryability, and safe message key.

## Playback Contract

- Apple TV prefers HLS manifests.
- Direct stream compatibility remains available for other clients and is not removed by this work.
- Protected playback should use scoped stream tokens or backend-authorized manifest access.
- Playback sessions should be created before playback when supported.
- Progress should be accepted every 15-30 seconds and on pause, seek, exit, and completion.
- Resume position should come from backend progress state after relaunch.
- Completion and watched state follow backend rules, not client-only thresholds.
- Audio and subtitle selection rely on HLS renditions or documented backend selection behavior.

## v1.1 Proof Playback Payloads

### Stream Token

`POST /api/v1/stream/token`

Request fields:

| Field | Type | Required | Semantics |
|-------|------|----------|-----------|
| `mediaType` | string | Yes | Current backend example uses `movie`; Phase 9 should preserve this spelling unless backend capabilities publish a more specific scoped payload. |

Response must provide either a scoped token value or explicit instructions for backend-authorized manifest access. Tokens must be treated as secret material and must never appear in diagnostics.

### Playback Session Create

`POST /api/v1/playback/sessions`

Request fields:

| Field | Type | Required | Semantics |
|-------|------|----------|-----------|
| `media_type` | string | Yes | `movie` for the v1.1 proof path. |
| `media_id` | number or string | Yes | Backend movie identifier. |
| `position_seconds` | number | Yes | Starting playback position, usually `0` or backend resume position. |
| `play_state` | string | Yes | Initial state, normally `playing`. |
| `client_label` | string | Yes | Safe label such as `Lumina tvOS`; never include device owner names or tokens. |

Response must include a playback session identifier safe to store in diagnostics and send on stream/progress calls.

### Playback Session Update

`PUT /api/v1/playback/sessions/:sessionId`

Request fields:

| Field | Type | Required | Semantics |
|-------|------|----------|-----------|
| `position_seconds` | number | Yes | Current AVKit playback position. |
| `play_state` | string | Yes | `playing`, `paused`, `buffering`, or another documented backend state. |
| `selection_diagnostics` | object or null | No | Safe audio/subtitle selection context. Must not include local paths or stream URLs. |

### Playback Session Stop

`POST /api/v1/playback/sessions/:sessionId/stop`

Request fields:

| Field | Type | Required | Semantics |
|-------|------|----------|-----------|
| `position_seconds` | number | Yes | Final observed playback position. |
| `play_state` | string | Yes | `stopped`, `completed`, or another documented terminal state. |

### Movie Progress

`GET /api/v1/playback/movies/:movieId/progress`

Returns backend resume state for the movie. The tvOS app should read this after sign-in/relaunch before offering or starting resume.

`PUT /api/v1/playback/movies/:movieId/progress`

Request fields:

| Field | Type | Required | Semantics |
|-------|------|----------|-----------|
| `position_seconds` | number | Yes | Current or final playback position. |
| `duration_seconds` | number | Yes when known | Movie duration from backend or player item. |
| `play_state` | string | Yes | State associated with the progress update, such as `playing`, `paused`, `stopped`, or `completed`. |

Progress updates should be accepted every 15-30 seconds and on pause, seek, exit, stop, and completion. Completion and watched state remain backend-owned.

## AVKit HLS Token Transport

URLSession-controlled API calls should use `Authorization: Bearer <jwt>` when authenticated. AVKit HLS playback cannot rely on the app attaching Authorization headers to every manifest-derived request, so protected HLS must support a URL-carried scoped stream token flow.

Required protected playback behavior:

| Resource | Required token behavior |
|----------|-------------------------|
| Movie manifest | Accept `stream_token` on `/api/v1/stream/movies/:movieId/hls/manifest.m3u8`. |
| Child playlist | Manifest must emit playlist URLs that either include `stream_token` or are otherwise authorized for AVKit without custom app headers. |
| Segment | Playlist must emit segment URLs that either include `stream_token` or are otherwise authorized for AVKit without custom app headers. |
| Subtitle | Subtitle URLs must support `stream_token` or be emitted in an AVKit-loadable authorized form. |

The client and backend may still support Authorization-header HLS requests for test tools and direct URLSession probes, but physical Apple TV proof must validate the AVKit-compatible token path.

Redaction requirement: any URL containing `stream_token`, token-like query keys, signed query strings, or bearer credentials must be rendered as `[redacted-url]` or equivalent before logs, diagnostics, screenshots, or support evidence are captured.

## Artwork Contract

Routes that return visual media should document available poster, backdrop, logo, thumbnail, and placeholder/fallback behavior. The client may request tvOS-appropriate sizes from documented artwork URLs, but must tolerate missing or partial artwork without focus jumps.

## Deferred Scope

The Phase 1 contract does not add QR/device pairing, local network discovery, household profiles, Top Shelf behavior, Apple TV app integrations, FairPlay DRM, offline downloads, Android TV implementation, or commercial App Store entitlement flows.

## Additive Backend Gap Register

These items are additive. They should not rewrite existing route families or remove direct streaming behavior used by other clients.

| Gap | Owner | Route or family | Client impact | Test expectation |
|-----|-------|-----------------|---------------|------------------|
| Capabilities route-key completeness | Backend | `/api/v1/system/capabilities` | Phase 9 cannot safely choose real endpoints without stable route keys. | Supported fixture/endpoint includes all required v1.1 proof keys and optional feature keys. |
| Catalog playable movie selection contract | Backend + tvOS | `/api/v1/catalog/movies`, `/api/v1/catalog/movies/:movieId` | Client needs a deterministic way to find one playable movie without broad browse polish. | Contract test documents accepted query parameters and a response containing ID, title, playability, artwork, and resume/progress data. |
| AVKit stream-token propagation | Backend | `/api/v1/stream/token`, movie HLS manifest/playlist/segment/subtitle routes | Protected HLS may fail on physical Apple TV if only the top manifest accepts a token. | Manifest, playlist, segment, and subtitle checks prove token propagation or equivalent authorization. |
| Playback session payload response shape | Backend | `/api/v1/playback/sessions` and `/:sessionId` routes | Client needs a stable session ID for progress and diagnostics correlation. | Create/update/stop tests assert snake_case payloads and safe session identifiers. |
| Movie progress resume semantics | Backend | `/api/v1/playback/movies/:movieId/progress` | Relaunch resume cannot be proven without a stable read/write progress contract. | Save/read tests assert position, duration, state, exit update, and relaunch restore behavior. |
| Safe error envelope consistency | Backend | setup, auth, catalog, stream, playback, progress routes | Client cannot map failures safely if legacy errors vary by route. | Representative validation, auth, stream-token, manifest, missing-media, and server errors include stable code/category/safe message/retryability/correlation. |
| Tokenized URL redaction | Backend + tvOS | diagnostics and support evidence | Proof evidence may leak protected playback tokens without redaction. | Redaction tests assert JWTs, stream tokens, Authorization headers, signed URLs, local paths, SQL details, stack traces, and raw subprocess output are absent. |
