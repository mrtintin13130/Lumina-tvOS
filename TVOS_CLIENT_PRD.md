# Lumina Native tvOS Client PRD

## Status

Approved for implementation planning after feedback incorporation.

## Source Inputs

- External research: `C:/Users/Martin/Downloads/deep-research-report.md`
- Adapted project research: `.planning/research/TVOS_STRATEGY_ADAPTED.md`
- Current backend context: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`

## Product Direction

Lumina should add a first-class native Apple TV client for browsing and playing a user's Lumina media library from the living room.

The client should be a native tvOS app built with SwiftUI, AVKit, AVFoundation, URLSession, Codable, Keychain, XCTest/XCUITest, and minimal third-party dependencies. It should consume the existing Lumina API first, then drive focused backend additions only when the current API does not support a high-quality TV experience.

The tvOS client is not a replacement for Lumina API. Lumina API remains the source of truth for catalog composition, media identity, playback progress, watched state, watchlist, favorites, stream tokens, HLS/direct streaming, subtitles, track metadata, scanner state, TMDB metadata, and diagnostics.

## Primary Goal

Deliver a native Apple TV MVP that lets a user connect to a Lumina server, sign in, browse the catalog, search, view movie/TV details, play video through AVKit using HLS-preferred playback, resume progress, select supported audio/subtitle tracks, and manage watchlist/favorites using the existing Lumina backend contracts.

## Target Users

- A Lumina user who runs a local or self-hosted Lumina API server and wants a remote-control-first Apple TV experience.
- A household member using a shared Apple TV to continue watching, browse the library, and start playback without using a browser or desktop client.
- A maintainer or operator who needs enough diagnostics to correlate tvOS playback failures with Lumina API playback sessions and streaming logs.

## Core User Problems

- Browser or desktop-oriented media browsing is not ideal on a television.
- Remote-control input makes username/password sign-in and precise navigation harder.
- Apple TV playback should use platform-native controls, subtitles, audio selection, buffering behavior, and remote interactions.
- A shared TV device can expose another user's watch history or lists unless account/profile behavior is explicit.
- Debugging playback from a living-room device is difficult without session IDs and client diagnostics.

## Non-Goals

This PRD does not authorize:

- Rewriting Lumina API.
- Replacing Express, PostgreSQL, CommonJS, or the modular-monolith backend.
- Replacing current JWT auth as a prerequisite for MVP.
- Removing direct streaming support from existing clients.
- Making HLS the only global backend playback mode.
- Adding FairPlay DRM for MVP.
- Adding offline video downloads for MVP.
- Adding App Store subscriptions, IAP, or hosted commercial entitlements for MVP.
- Adding Apple Video Partner Program, Universal Search, Siri, zero sign-on, or Apple TV app integration for MVP.
- Adding Android TV implementation work.
- Adding a full household profile system unless explicitly selected as product scope.
- Introducing a backend-for-frontend service unless existing route aggregation proves insufficient.

## Product Assumptions

- Lumina remains a local-library/self-hosted media server for this PRD.
- The first tvOS client will use manual server URL entry. Local network discovery can follow after the playback MVP.
- Existing Lumina username/password JWT auth will be used for MVP. QR/device pairing is deferred until after playback MVP.
- HLS should be preferred on Apple TV because it aligns with AVKit and platform media expectations, but direct stream compatibility remains available for other clients.
- The first MVP optimizes streaming reliability and navigation quality over offline playback, DRM, and commercial App Store monetization.
- The app should target a modern tvOS baseline. Default target is tvOS 17+ unless the available Apple TV hardware or Xcode toolchain makes tvOS 18+ the better explicit target.
- Top Shelf is deferred until after playback stability and core navigation are proven.
- The signed-in Lumina user must always be visible in settings or account surfaces. Household profiles remain deferred.

## Locked MVP Decisions

These decisions should be treated as fixed for initial execution unless a later planning artifact explicitly changes them:

| Topic | Decision |
|-------|----------|
| Auth MVP | Start with existing username/password JWT login |
| Pairing | Defer QR/device pairing until after playback MVP |
| Server setup | Manual server URL entry first |
| Server discovery | Defer local discovery |
| Minimum tvOS target | tvOS 17+ by default; raise to tvOS 18+ only after hardware/toolchain confirmation |
| Repository location | Prefer a sibling client repository unless Lumina is intentionally converted to a monorepo |
| Top Shelf | Defer until playback and Home are stable |
| Household profiles | Defer; display current signed-in user clearly |
| Backend compatibility | Additive changes only; no route rewrites for MVP |
| Playback proof | Validate HLS playback on physical Apple TV before full catalog polish |

## Technical Product Decision

Use a native tvOS stack:

- SwiftUI for app shell, navigation, catalog screens, details, settings, loading states, and error states.
- AVKit and AVFoundation for playback.
- UIKit/TVUIKit bridges only for focus, shelf, or player cases SwiftUI cannot handle cleanly.
- URLSession, Codable, async/await, URLCache, and NSCache for API access and cache behavior.
- Keychain Services for auth tokens and persisted credentials.
- SwiftData or Core Data only if local state outgrows simple cache and settings storage.
- XCTest, Swift Testing where appropriate, and XCUITest for focus/navigation flows.
- AVMetrics, MetricKit, and lightweight app logs for diagnostics.

Do not use Flutter for the tvOS client. Flutter does not provide official tvOS support suitable for a first-class Apple TV media app. Do not start with React Native for TV unless native development becomes impossible; its TV support is community-maintained and adds risk for focus, player, and platform compliance. Do not use Unity unless Lumina changes into a game or heavy 3D experience.

## MVP Experience

### Critical Vertical Slice

Before building the full catalog UI, the project must prove one authenticated Apple TV client can complete the end-to-end playback path.

Required slice:

1. User manually configures a Lumina server URL.
2. App validates the server through health/version and `/api/v1/system/capabilities`.
3. User signs in through existing JWT auth.
4. App fetches one playable movie from a simple list or catalog route.
5. App opens the movie detail enough to identify playability and resume position.
6. App requests or applies a scoped stream token.
7. App starts HLS playback through AVKit on a physical Apple TV.
8. App reports progress to Lumina.
9. User exits playback.
10. App relaunches and resumes from the saved position.

Acceptance criteria:

- The slice runs successfully on physical Apple TV before broad Home/Search/TV-show polish.
- Backend progress and continue-watching state update after playback.
- Stream-token and HLS failures produce user-safe errors.
- Session IDs or equivalent diagnostics allow correlation with Lumina backend logs.

### First Launch And Server Setup

The app must let the user connect to a Lumina API server before sign-in.

Requirements:

- User can enter or select a server base URL.
- App validates that the server exposes Lumina API health/version information and `/api/v1/system/capabilities`.
- App stores the selected server securely enough for repeat launches.
- App shows clear failure states for unreachable server, invalid URL, TLS/certificate problems, unsupported API version, unsupported capability set, and authentication-required states.
- App can retry server validation without restarting.

Acceptance criteria:

- A user can configure a reachable Lumina API server and reach sign-in.
- An unreachable server does not crash the app.
- Server validation failures are actionable and remote-control navigable.

### Authentication

MVP must support signing in to an existing Lumina account through current username/password JWT auth. QR/device pairing is intentionally deferred until after playback MVP.

MVP requirements:

- User can sign in with existing Lumina credentials.
- Token is stored in Keychain.
- User can sign out and clear local auth state.
- App handles expired or invalid tokens by returning to sign-in.
- App calls `/api/v1/auth/me` or equivalent after launch to validate the session.

Preferred follow-up requirements:

- Add QR/device pairing to avoid remote-control password entry.
- Pairing flow uses short-lived user codes, expiry, polling interval, rate limits, and revocation.
- Pairing flow is additive and does not remove existing auth.

Acceptance criteria:

- A fresh install can authenticate against Lumina API.
- Relaunch restores the signed-in session when the token is valid.
- Logout removes token material from Keychain.
- Authentication errors do not leak token values or server internals.

### Home

Home is the primary browsing screen and should consume backend-composed catalog data first.

Requirements:

- App loads `/api/v1/catalog/home` after authentication.
- App renders backend-provided section order without client-side reordering.
- App supports continue watching, cinematic/banner sections, editorial/discovery rows, recently added rows, and empty-state behavior based on the existing response.
- Cards are optimized for 10-foot UI, focus movement, and quick recognition.
- Home supports refresh/retry.
- Home remains usable with partial artwork.

Acceptance criteria:

- Home screen can render an empty library, a small library, and a large library.
- Focus never lands on invisible or disabled content.
- Missing artwork uses stable fallback presentation.
- API error states can be retried with the remote.

### Search And Browse

Requirements:

- Search calls `/api/v1/catalog/search` with supported query parameters.
- Browse supports movies and TV shows through `/api/v1/catalog/movies` and `/api/v1/catalog/tv_shows`.
- Facets use `/api/v1/catalog/facets` where useful for filters.
- Sorting/filter choices are limited to backend-supported parameters.
- Pagination or incremental loading must not create focus jumps or duplicate cards.

Acceptance criteria:

- User can search by title and open results.
- User can browse movies and TV shows separately.
- Unsupported filters are not exposed in the UI.
- Empty search and no-result states are distinct.

### Details

Requirements:

- Movie detail uses `/api/v1/catalog/movies/:id`.
- TV show detail uses `/api/v1/catalog/tv_shows/:id` and season/episode routes.
- Detail pages show title, artwork, overview, year/date, runtime where available, genres, rating where available, playable state, progress, watchlist state, favorite state, trailers where available, and available seasons/episodes for shows.
- Detail pages include primary Play/Resume action.
- Detail pages include watchlist and favorite controls.
- Detail pages avoid exposing local filesystem paths.

Acceptance criteria:

- User can open a movie from Home/Search/Browse and start/resume playback.
- User can open a show, choose a season and episode, and start/resume playback.
- Watchlist/favorite state updates without leaving the detail page.
- Non-playable media is clearly represented and does not start playback.

### Playback

Playback is the highest-risk user workflow. The tvOS client should use AVKit and prefer Lumina HLS routes.

Requirements:

- App starts a playback session through `/api/v1/playback/sessions` when supported by the current API contract.
- App obtains or uses a scoped stream token before loading protected stream resources.
- Movie playback uses `/api/v1/stream/movies/:id/hls/manifest.m3u8` by default.
- Episode playback uses `/api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/hls/manifest.m3u8` by default.
- App supports resume from existing progress.
- App reports progress every 15-30 seconds and on pause, seek, player exit, and completion.
- App supports selected audio/subtitle behavior where backend HLS manifests expose renditions or playback selection is supported.
- App handles stream-token expiry, HLS manifest errors, segment errors, unsupported selected tracks, and missing media files.
- App preserves native Apple TV remote behavior through AVPlayerViewController unless a custom player is explicitly justified.

Acceptance criteria:

- A playable movie starts through AVKit and can be paused, resumed, scrubbed, and exited.
- An episode starts through AVKit and resumes from prior progress.
- Progress persists and appears in continue watching.
- Completion marks watched state according to backend rules.
- Subtitle and audio selection work for supported HLS renditions.
- Playback failure surfaces a user-safe error and records enough local context to correlate with backend diagnostics.

### Library Actions

Requirements:

- User can add/remove movies and shows from watchlist using `/api/v1/catalog/watchlist`.
- User can add/remove favorites using `/api/v1/catalog/favorites`.
- App can list watchlist and favorites.
- UI state remains consistent after successful update and rolls back or refreshes after failed update.

Acceptance criteria:

- Watchlist and favorite changes are visible across Home, Browse, and Detail after refresh.
- Repeated add/remove actions remain idempotent from the user's perspective.

### Settings

Requirements:

- User can view connected server URL.
- User can sign out.
- User can trigger server revalidation.
- User can view app version/build.
- User can expose diagnostics information useful for support without leaking secrets.

Optional:

- Playback preference controls if backend settings and route behavior make them safe.
- Clear image/API cache.
- Select default playback mode for this client, limited to supported backend behavior.

Acceptance criteria:

- A user can recover from an invalid server or expired session.
- Diagnostics display never includes JWTs, stream tokens, local server secrets, or raw filesystem paths.

## UX Requirements

### Navigation

- First screen after sign-in is the usable app experience, not a marketing page.
- Navigation must be remote-first and focus-driven.
- Primary sections should be reachable with predictable directional movement.
- Avoid deep modal stacks.
- Avoid hidden controls that require touch or pointer assumptions.
- Every screen must have a stable loading, empty, error, and success state.

### Focus

- Focus target size and spacing must fit Apple TV viewing distance.
- Initial focus on each screen must land on the safest primary action or first content item.
- Focus must remain stable after async image loads.
- Lazy loading must not move focused content unexpectedly.
- Carousels/shelves must preserve row and item position when returning from detail/player screens.

### Visual Design

- Use artwork as the primary visual signal.
- Prefer poster/backdrop/logo assets from Lumina metadata where available.
- Use restrained UI chrome around content; the app is a media browser, not a marketing site.
- Text must fit at TV distance and avoid truncating critical titles where practical.
- Fallback artwork must look intentional.
- Avoid overusing a single hue family; content artwork should carry most color.

### Accessibility

- Support Apple TV accessibility expectations, including readable contrast, VoiceOver labels for controls, and clear focus state.
- Do not encode state only by color.
- Player controls should rely on native AVKit accessibility where possible.

## Backend Contract Requirements

The tvOS client should consume existing routes first. Any backend work must be additive unless a separate migration PRD approves behavior changes.

### Mandatory Phase 1 Backend Additions

The tvOS client needs a stable way to determine whether a Lumina server can support the app before sign-in and before playback. Phase 1 must add or formally document:

- `GET /api/v1/system/capabilities`
- A formal API error envelope contract for TV-consumed JSON routes

The capability endpoint should be public or safely accessible before authentication. It must not expose secrets, local filesystem paths, configured media roots, JWT configuration, database details, or scanner internals.

Minimum capability response shape:

```json
{
  "serverName": "Lumina",
  "apiVersion": "1.0",
  "minClientVersion": "1.0.0",
  "auth": {
    "passwordLogin": true,
    "devicePairing": false
  },
  "playback": {
    "hls": true,
    "directStream": true,
    "streamTokens": true,
    "audioTrackSelection": true,
    "subtitleTrackSelection": true
  },
  "features": {
    "watchlist": true,
    "favorites": true,
    "continueWatching": true
  }
}
```

Exact field names may change during implementation, but the endpoint must answer these client questions:

- Is this a Lumina-compatible server?
- Which API version is exposed?
- Is this tvOS app version allowed to connect?
- Which auth modes are supported?
- Is HLS playback supported?
- Are stream tokens required/supported?
- Are audio and subtitle selection supported?
- Are watchlist, favorites, and continue watching supported?

### API Error Envelope

TV-consumed JSON routes should converge on a predictable error envelope. Existing routes do not need a broad breaking rewrite, but new TV-facing backend work must return errors the client can classify.

Target shape:

```json
{
  "error": {
    "code": "STREAM_TOKEN_EXPIRED",
    "message": "The stream token has expired.",
    "retryable": true,
    "requestId": "req_..."
  }
}
```

Requirements:

- `code` is stable enough for client branching.
- `message` is user-safe or safely mappable to user-facing copy.
- `retryable` tells the client whether retry UI is appropriate.
- `requestId` is present when request correlation exists.
- Errors must not expose JWTs, stream tokens, local filesystem paths, SQL details, stack traces, or raw subprocess output.
- Legacy routes may keep existing envelopes until migrated, but the TV client contract must document differences explicitly.

### Existing Routes To Treat As Candidate TV Surface

- `GET /api/v1/auth/me`
- `POST /api/v1/auth/login`
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
- `POST /api/v1/catalog/watchlist`
- `DELETE /api/v1/catalog/watchlist`
- `GET /api/v1/catalog/watchlist`
- `POST /api/v1/catalog/favorites`
- `DELETE /api/v1/catalog/favorites`
- `GET /api/v1/catalog/favorites`
- `GET /api/v1/playback/continue-watching`
- `GET /api/v1/playback/history`
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
- `POST /api/v1/stream/token`
- `GET /api/v1/system/capabilities`
- `GET /api/v1/stream/movies/:id/hls/manifest.m3u8`
- `GET /api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/hls/manifest.m3u8`
- `GET /api/v1/stream/movies/:id/info`
- `GET /api/v1/stream/tv/:showId/seasons/:seasonNumber/episodes/:episodeNumber/info`

### Backend Contract Additions To Consider

These are not MVP prerequisites unless client development proves they are needed:

- OpenAPI description for TV-consumed routes.
- TV client compatibility document with route list, response fields, limits, and error envelopes.
- Additive device-pairing endpoints for TV sign-in.
- Stronger artwork variant contract for poster/backdrop/logo aspect ratios.
- ETag/cache headers for Home and static-ish catalog responses.
- Client diagnostics endpoint for playback QoE events if backend diagnostics need client-side context.

## Security And Privacy Requirements

- Store tokens only in Keychain.
- Never log JWTs, stream tokens, passwords, or Authorization headers.
- Never expose stream tokens in user-visible diagnostics.
- Use ATS by default.
- Avoid `NSAllowsArbitraryLoads` unless local/self-hosted development requires a documented debug-only exception.
- Handle self-hosted TLS and local-network setup deliberately.
- Apply least privilege to any local network permissions and explain why the app needs them.
- App Store privacy labels must reflect actual data collection and third-party SDK behavior.
- If third-party sign-in is ever added, evaluate Sign in with Apple requirements before release.

## Observability Requirements

The tvOS client should capture local diagnostics that can be matched to backend playback sessions.

Minimum diagnostic events:

- App launch and server validation result.
- Auth success/failure category without secrets.
- Home/catalog request failures.
- Playback session start/stop.
- AVPlayer item failure and error category.
- Startup latency to first frame when available.
- Buffering/stall events when available.
- Selected audio/subtitle state where available.
- Stream URL type, not full signed token URL.
- Backend playback session ID and media ID.

Diagnostics must be user-safe and support-oriented. They are not analytics for monetization in MVP.

## Testing Strategy

### Client Unit Tests

- API client request construction.
- Auth token storage abstraction.
- Catalog response decoding.
- Playback progress bucketing.
- Error mapping.
- ViewModel state transitions.

### Client UI Tests

- First launch server setup.
- Sign in.
- Home navigation with focus.
- Search.
- Movie detail to playback.
- TV show season/episode navigation.
- Watchlist/favorite toggles.
- Settings/logout.

### Playback Verification

- Simulator verification for navigation and basic AVPlayer integration.
- Physical Apple TV verification starts with the critical vertical slice and continues through playback hardening.
- Physical Apple TV verification is required for HLS playback, remote behavior, audio/subtitle selection, buffering, memory, and long playback.
- Test with at least:
  - movie with direct-play-compatible source
  - movie requiring HLS/transcode
  - episode playback
  - media with embedded subtitles
  - media with external subtitles
  - media with multiple audio tracks
  - missing media file
  - expired stream token
  - server restart during playback

### Backend Regression

Backend changes driven by this PRD must include focused route/contract tests and full `npm test`.

High-risk backend areas:

- Auth and token behavior.
- Stream token scope and expiry.
- HLS manifest generation.
- Subtitle/audio rendition behavior.
- Playback session lifecycle.
- Progress and watched-state behavior.
- Catalog response envelopes.

## Release Strategy

### Development Builds

- Start with local Xcode builds against local Lumina API.
- Use a small seed library for repeatable smoke tests.
- Maintain a physical Apple TV test path before TestFlight.

### Beta

- Use TestFlight when the app can complete sign-in, browse, and playback reliably.
- Provide reviewers/testers with a reachable demo Lumina server or a documented local setup path.
- Capture feedback by email or an external feedback form because tvOS TestFlight feedback flows are more limited than iOS.

### App Store Readiness

App Store release requires explicit decisions on:

- Whether Lumina is a reader-style app or only a self-hosted local media companion.
- Whether account creation exists in-app.
- Whether account deletion is required in-app.
- Whether subscriptions/IAP exist.
- Privacy policy and Apple TV privacy policy text.
- App icon and Top Shelf assets.
- Demo credentials or review setup instructions.

## Roadmap Proposal

### MVP-0: Critical Playback Proof

Goal: prove the riskiest path before investing heavily in full catalog polish.

Deliverables:

- Manual server URL setup.
- Server health/version and capability validation.
- Existing JWT login.
- Minimal playable movie fetch.
- Stream-token request/application.
- HLS playback in AVKit.
- Progress reporting.
- Relaunch and resume verification.
- Physical Apple TV evidence.

Acceptance criteria:

- One authenticated Apple TV client can connect to Lumina, play one movie through HLS, report progress, exit, relaunch, and resume from saved position.
- Failures produce user-safe client errors and backend-correlatable diagnostics.

### MVP-1: Real Usable App

Goal: turn the playback proof into the minimum complete living-room app.

Deliverables:

- Home feed.
- Search.
- Movie browse and details.
- TV show browse, seasons, episodes, and details.
- Resume and continue watching.
- Watchlist and favorites.
- Core settings and sign-out.

Acceptance criteria:

- A user can browse, find, play, resume, and organize media without leaving Apple TV.

### MVP-2: Living-Room Polish And Beta Readiness

Goal: stabilize the app for small TestFlight use.

Deliverables:

- Focus polish.
- Artwork fallback and caching polish.
- Diagnostics screen.
- Expanded physical Apple TV QA matrix.
- TestFlight pipeline.
- Optional Top Shelf decision after playback stability.

Acceptance criteria:

- App is stable enough for a small TestFlight beta.

## Implementation Phase Detail

### Phase 1: Product And API Contract Baseline

Goal: make the tvOS target concrete before building screens.

Deliverables:

- TV client contract document.
- Supported route matrix.
- Mandatory server capability endpoint design.
- Formal API error envelope design.
- Auth MVP decision recorded as existing login first.
- HLS playback contract and progress cadence.
- Artwork requirements for TV layouts.

Acceptance criteria:

- A developer can build the first client shell without guessing route ownership or response expectations.
- Backend changes are explicitly listed as additive or deferred.
- Capability endpoint and error-envelope behavior are planned with focused backend tests.

### Phase 2: Native tvOS Shell And Server Setup

Goal: create a working tvOS project and connect it to a Lumina server.

Deliverables:

- Xcode tvOS project.
- App architecture skeleton: SwiftUI, MVVM, services/repositories, dependency injection.
- Server setup screen.
- Capability endpoint integration.
- API client and auth scaffolding.
- Keychain token storage.
- Initial unit tests.

Acceptance criteria:

- App launches on simulator and physical Apple TV.
- User can configure a server and validate API reachability.

### Phase 3: Auth And Home

Goal: reach authenticated Home after the critical playback proof is underway.

Deliverables:

- Login flow using current Lumina auth or approved pairing flow.
- Session restoration.
- Home feed rendering.
- Loading/empty/error states.
- Focus behavior tests for Home.

Acceptance criteria:

- A signed-in user sees catalog Home from the backend.
- Relaunch restores the session.

### Phase 4: Catalog, Search, And Details

Goal: make the library browsable.

Deliverables:

- Search screen.
- Movie browse.
- TV show browse.
- Movie detail.
- TV show/season/episode detail.
- Watchlist and favorite controls.

Acceptance criteria:

- User can find a movie or episode and reach a playable detail screen.

### Phase 5: Playback MVP

Goal: expand the critical playback proof into reliable native playback for movies and episodes.

Deliverables:

- Stream-token flow.
- AVKit player integration.
- HLS movie playback.
- HLS episode playback.
- Resume/progress updates.
- Basic subtitle/audio support from HLS where available.
- Playback error mapping and diagnostics.

Acceptance criteria:

- User can start, pause, resume, seek, exit, and continue playback later.
- Backend progress and continue-watching update correctly.

### Phase 6: TV Hardening

Goal: improve reliability and living-room polish.

Deliverables:

- Physical Apple TV QA matrix.
- Focus polish.
- Artwork fallback and caching polish.
- Playback diagnostics correlation.
- Deep links if selected.
- Top Shelf only if playback and Home are already stable.
- CI/TestFlight pipeline.

Acceptance criteria:

- App is stable enough for a small TestFlight beta.

### Phase 7: Post-MVP Decisions

Goal: decide optional capabilities after the streaming-first MVP proves useful.

Candidate scopes:

- QR/device pairing.
- Household profiles.
- Offline metadata cache or video downloads.
- FairPlay DRM if Lumina's product model changes.
- Android TV native app using shared API contracts.

## Risks And Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Remote-control sign-in is painful | Users abandon setup | Start with simple login if needed, then add QR/device pairing as a focused auth milestone |
| HLS behavior differs across simulator and hardware | Playback bugs escape local testing | Require physical Apple TV verification for playback milestones |
| Existing API lacks a stable client contract | Client bakes in accidental response assumptions | Create TV client contract and OpenAPI coverage before broad client work |
| Artwork quality is inconsistent | TV UI looks broken despite functional API | Define poster/backdrop/logo fallback and aspect-ratio rules early |
| Token handling leaks through logs or URLs | Security risk | Centralize token redaction and diagnostics policy |
| Backend scope creeps into auth rewrite/DRM/offline | MVP slips | Keep device flow, DRM, and offline behind separate phases or PRDs |
| Shared Apple TV exposes user state | Privacy and UX issue | Make current signed-in user visible; defer household profiles only with explicit decision |
| Too many SDKs trigger privacy/compliance overhead | Release friction | Prefer native frameworks and minimal dependencies |

## Open Questions

- Should the tvOS client live in this repository, a sibling repository, or a monorepo workspace?
- Should app state be scoped to one Lumina user per Apple TV device at MVP?
- What demo server/review path will be used for TestFlight and App Review?
- What artwork dimensions can the backend reliably provide for TV poster, backdrop, and logo layouts?
- Should local-network discovery be added after MVP-0 or after MVP-1?
- Should Top Shelf be included in MVP-2 or deferred until after TestFlight feedback?

## Definition Of Done

The tvOS MVP is done when:

- A user can install the app on Apple TV, configure a Lumina server, sign in, browse Home, search, open details, play movies and episodes, resume progress, and manage watchlist/favorites.
- The critical vertical slice has passed on physical Apple TV before broad catalog polish is considered complete.
- The app validates `/api/v1/system/capabilities` before relying on server features.
- Playback uses native AVKit and prefers HLS without breaking existing backend playback modes.
- Progress, watched state, continue watching, audio/subtitle behavior, and stream-token handling are covered by client and backend verification.
- Physical Apple TV verification passes for the core playback matrix.
- The app has user-safe diagnostics that can be correlated with backend playback sessions.
- TV-facing backend additions return documented, client-classifiable error envelopes.
- Backend changes, if any, are additive, tested, and documented.
- Non-MVP scope remains deferred unless a new PRD or milestone explicitly accepts it.
