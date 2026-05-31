# Requirements: Lumina Native tvOS Client v1.1

**Defined:** 2026-05-30
**Core Value:** One authenticated Apple TV client can connect to a Lumina server, play HLS video through native AVKit on physical Apple TV, report progress, and resume reliably.

## v1.1 Requirements

Requirements for the backend contract alignment and physical Apple TV playback proof milestone. Each maps to roadmap phases.

### Contract Alignment

- [x] **CONT-05**: Developer can compare `rest-client/` endpoint examples against the tvOS API contract and see every client-consumed route, payload shape, and route key needed for the playback proof.
- [x] **CONT-06**: `GET /api/v1/system/capabilities` returns or documents route keys and feature flags for auth, catalog, movie HLS, stream tokens, playback sessions, progress, watched state, tracks, subtitles, watchlist, favorites, diagnostics, and page limits.
- [x] **CONT-07**: Client and backend agree on playback payload naming and semantics for `media_type`, `media_id`, `position_seconds`, `duration_seconds`, `play_state`, `client_label`, session IDs, and progress update reasons.
- [x] **CONT-08**: Stream-token transport is documented for Apple TV HLS manifests, playlists, segments, and subtitles so AVKit can load protected resources without relying on unavailable per-segment custom headers.
- [x] **CONT-09**: Error responses used by setup, auth, catalog, stream-token, HLS, playback session, progress, and missing-media flows map to user-safe client categories without exposing secrets or backend internals.

### Client API Integration

- [x] **API-01**: The Swift API client decodes the implemented capabilities response and gates unsupported features without blocking compatible servers that expose the v1.1 route set.
- [x] **API-02**: The Swift API client uses the real auth endpoints for login and session restore while storing token material only through the Keychain abstraction.
- [x] **API-03**: The Swift API client fetches a playable movie through the catalog endpoint surface and decodes the ID, title, playability, progress/resume, artwork, and HLS-relevant fields needed for proof playback.
- [x] **API-04**: The Swift API client creates, updates, and stops playback sessions using the real `/api/v1/playback/sessions` payload shape.
- [x] **API-05**: The Swift API client saves and restores movie progress through the real movie progress endpoints, including exit and relaunch behavior.
- [x] **API-06**: The Swift API client requests or applies stream-token behavior for protected movie HLS playback and never logs or displays the tokenized URL.
- [x] **API-07**: Unit tests cover v1.1 DTO decoding, request construction, compatibility gating, payload naming, redaction, and safe error mapping using fixtures derived from the real endpoint contract.

### Playback Proof

- [ ] **PLAY-11**: User can sign in to a live Lumina server, select one playable catalog movie, and enter a proof playback screen with a valid playback session.
- [ ] **PLAY-12**: Physical Apple TV starts movie HLS playback through AVKit using the backend-supported stream-token or authorized manifest path.
- [ ] **PLAY-13**: Playback session update and movie progress save occur during playback, on pause or exit, and on stop without leaking JWTs, stream tokens, Authorization headers, or signed URLs.
- [ ] **PLAY-14**: Relaunching the app after playback restores the server session, reads backend movie progress, and offers or starts resume from the saved position.
- [ ] **PLAY-15**: Stream-token expiry, HLS manifest failure, missing media, and server unreachable states produce safe retryable or terminal user-facing errors and backend-correlatable diagnostics.

### Verification

- [ ] **VER-01**: Generic tvOS build and test-build pass after the v1.1 API alignment.
- [ ] **VER-02**: Physical Apple TV playback proof captures safe evidence for start, pause/exit progress, relaunch resume, and stop/completion behavior against a live Lumina server.
- [ ] **VER-03**: Backend evidence confirms the expected playback session and progress records were created or updated for the proof movie.
- [ ] **VER-04**: Any backend or client gaps found during live proof are recorded as explicit follow-up requirements, not hidden in diagnostics or local notes.

## v1.2 Requirements

Deferred to future milestone. Tracked but not in the current roadmap.

### Catalog Expansion

- **CAT-11**: User can browse full Home, search, movie browse, TV browse, movie details, TV details, and season/episode flows against the live catalog API with stable focus and artwork behavior.
- **CAT-12**: User can add and remove movies and TV shows from watchlist and favorites and see consistent state across Home, Browse, Detail, and refresh.

### Episode Playback And Tracks

- **PLAY-16**: User can play an episode through the real episode HLS route and resume it from backend progress.
- **PLAY-17**: User can select supported audio and subtitle tracks where the backend and HLS rendition behavior allow it.
- **PLAY-18**: Completion and watched state behavior is verified for movies and episodes according to backend rules.

### Beta Readiness

- **BETA-01**: TestFlight signing, seed library, demo/reviewer server path, privacy decisions, App Store metadata, app icon, and Top Shelf asset decisions are ready for a small beta.

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Broad Home/search/details polish | v1.1 must prove the real server-auth-playback-progress-resume loop first. |
| Episode playback | Movie playback proof is the narrowest high-risk vertical slice; episodes follow once the loop is proven. |
| Watchlist/favorite UI completion | Endpoint alignment may include DTOs, but full product flows are deferred. |
| QR/device pairing | Existing username/password JWT auth remains the MVP path. |
| Local network discovery | Manual server URL entry remains the MVP setup path. |
| Backend route rewrites | Backend changes should stay additive and contract-focused. |
| App Store/TestFlight release execution | Release prep follows after hardware playback proof is trustworthy. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| CONT-05 | Phase 8 | Complete |
| CONT-06 | Phase 8 | Complete |
| CONT-07 | Phase 8 | Complete |
| CONT-08 | Phase 8 | Complete |
| CONT-09 | Phase 8 | Complete |
| API-01 | Phase 9 | Complete |
| API-02 | Phase 9 | Complete |
| API-03 | Phase 9 | Complete |
| API-04 | Phase 9 | Complete |
| API-05 | Phase 9 | Complete |
| API-06 | Phase 9 | Complete |
| API-07 | Phase 9 | Complete |
| PLAY-11 | Phase 10 | Pending |
| PLAY-12 | Phase 10 | Pending |
| PLAY-13 | Phase 10 | Pending |
| PLAY-14 | Phase 10 | Pending |
| PLAY-15 | Phase 10 | Pending |
| VER-01 | Phase 10 | Pending |
| VER-02 | Phase 10 | Pending |
| VER-03 | Phase 10 | Pending |
| VER-04 | Phase 10 | Pending |

**Coverage:**

- v1.1 requirements: 21 total
- Mapped to phases: 21
- Unmapped: 0

---
*Requirements defined: 2026-05-30*
*Last updated: 2026-05-30 after v1.1 milestone start*
