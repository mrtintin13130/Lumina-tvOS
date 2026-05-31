---
last_mapped: 2026-05-30
last_mapped_commit: unknown
focus: tech
---

# Integrations

## Summary

The current codebase has no implemented external integrations. `TVOS_CLIENT_PRD.md` defines the expected integration surface for a native tvOS Lumina client, centered on a self-hosted Lumina API server, JWT auth, HLS playback, progress reporting, catalog browsing, and diagnostics.

## Implemented Integrations

- None in application code.
- `lumina/ContentView.swift` is a static placeholder and performs no network, playback, auth, storage, or analytics work.
- `lumina/luminaApp.swift` only mounts `ContentView()`.

## Planned Primary Backend

- The Lumina API server is the source of truth for catalog composition, media identity, playback progress, watched state, watchlist, favorites, stream tokens, HLS/direct streaming, subtitles, track metadata, scanner state, TMDB metadata, and diagnostics.
- The tvOS app is expected to consume existing backend contracts first and request additive backend changes only where the current API cannot support a TV-quality experience.
- The app should not rewrite or replace the Lumina API.

## Server Setup And Capability Integrations

`TVOS_CLIENT_PRD.md` requires a first-launch server setup flow:

- User manually enters a server base URL.
- App validates health/version information.
- App validates `GET /api/v1/system/capabilities`.
- App handles unreachable server, invalid URL, TLS/certificate errors, unsupported API versions, unsupported capability sets, and authentication-required states.

The capability endpoint must not expose secrets, filesystem paths, JWT configuration, database details, or scanner internals.

## Authentication Integrations

Planned MVP auth uses existing Lumina username/password JWT auth:

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

Expected client responsibilities:

- Store tokens only in Keychain.
- Sign out and clear local auth state.
- Handle expired or invalid tokens by returning to sign-in.
- Avoid logging JWTs, passwords, stream tokens, or Authorization headers.

QR/device pairing is explicitly deferred until after playback MVP.

## Catalog Integrations

Candidate catalog routes listed in `TVOS_CLIENT_PRD.md`:

- `GET /api/v1/catalog/home`
- `GET /api/v1/catalog/search`
- `GET /api/v1/catalog/movies`
- `GET /api/v1/catalog/tv_shows`
- `GET /api/v1/catalog/facets`
- `GET /api/v1/catalog/movies/:id`
- `GET /api/v1/catalog/tv_shows/:id`
- `GET /api/v1/catalog/tv_shows/:showId/seasons`
- `GET /api/v1/catalog/tv_shows/:showId/seasons/:seasonNumber`
- `GET /api/v1/catalog/tv_shows/:showId/seasons/:seasonNumber/episodes`
- `GET /api/v1/catalog/tv_shows/:showId/seasons/:seasonNumber/episodes/:episodeNumber`

The client should render backend-provided Home section order without client-side reordering.

## Library Action Integrations

Planned watchlist routes:

- `POST /api/v1/catalog/watchlist`
- `DELETE /api/v1/catalog/watchlist`
- `GET /api/v1/catalog/watchlist`

Planned favorite routes:

- `POST /api/v1/catalog/favorites`
- `DELETE /api/v1/catalog/favorites`
- `GET /api/v1/catalog/favorites`

These should update detail surfaces without forcing the user to leave the current screen.

## Playback Integrations

Playback is the highest-risk integration area in the PRD. Planned routes include:

- `POST /api/v1/playback/sessions`
- `PUT /api/v1/playback/sessions/:sessionId`
- `POST /api/v1/playback/sessions/:sessionId/stop`
- `GET /api/v1/playback/movies/:movieId/progress`
- `PUT /api/v1/playback/movies/:movieId/progress`
- `PUT /api/v1/playback/movies/:movieId/watched`
- `GET /api/v1/playback/movies/:movieId/tracks`
- `GET /api/v1/playback/episodes/:episodeId/progress`
- `PUT /api/v1/playback/episodes/:episodeId/progress`
- `PUT /api/v1/playback/episodes/:episodeId/watched`
- `GET /api/v1/playback/episodes/:episodeId/tracks`
- `GET /api/v1/playback/continue-watching`
- `GET /api/v1/playback/history`

The MVP must prove one authenticated Apple TV client can start playback, report progress, exit, relaunch, and resume.

## Stream Integrations

Planned stream-token and HLS routes:

- `POST /api/v1/stream/token`
- `GET /api/v1/stream/movies/:id/hls/manifest.m3u8`
- `GET /api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/hls/manifest.m3u8`
- `GET /api/v1/stream/movies/:id/info`
- `GET /api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/info`

The tvOS client should prefer HLS through AVKit while preserving backend support for direct streaming used by other clients.

## Platform Integrations

Planned Apple platform integrations:

- AVKit player for native playback controls.
- AVFoundation for media details and playback behavior where needed.
- Keychain Services for token persistence.
- MetricKit and AVMetrics for diagnostics.
- TVUIKit or UIKit bridges only where SwiftUI cannot handle focus, shelf, or player behavior cleanly.
- Top Shelf assets exist in `lumina/Assets.xcassets/App Icon & Top Shelf Image.brandassets`, but Top Shelf functionality is deferred in `TVOS_CLIENT_PRD.md`.

## Security Boundaries

- User-visible diagnostics must not expose JWTs, stream tokens, local server secrets, or raw filesystem paths.
- Backend errors must not expose SQL details, stack traces, raw subprocess output, JWTs, stream tokens, or local filesystem paths.
- Stream-token and HLS failures need user-safe error mapping and backend-correlatable diagnostics.

## Current Integration Gaps

- No API client exists.
- No auth service exists.
- No Keychain integration exists.
- No server URL persistence exists.
- No playback session client exists.
- No AVKit playback view exists.
- No diagnostics or redaction policy is implemented.
