---
gsd_state_version: 1.0
milestone: v1.1
milestone_name: Backend Contract Alignment And Hardware Playback Proof
status: gaps_found
stopped_at: Phase 10 physical Apple TV playback start succeeded, but progress/resume proof and detail navigation gaps remain.
last_updated: "2026-06-04T00:00:00.000Z"
last_activity: 2026-06-05
progress:
  total_phases: 3
  completed_phases: 2
  total_plans: 10
  completed_plans: 10
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-05-30)

**Core value:** One authenticated Apple TV client can connect to a Lumina server, play HLS video through native AVKit on physical Apple TV, report progress, and resume reliably.
**Current focus:** Phase 10: Physical Movie Playback Proof

## Current Position

Phase: 10 of 10 (physical movie playback proof)
Plan: 10-03 — Evidence review and follow-up gaps
Status: Physical Apple TV playback start proven; Phase 10 gaps found
Last activity: 2026-06-05 — refined the media detail page with a fill-mode hero backdrop, focusable Trailer action, and Cast/Behind the Scenes shelves; progress/resume proof gaps remain

Progress: [██████████] 100%

## Performance Metrics

**Velocity:**

- Total plans completed: 7
- Average duration: N/A
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 8 | 3/3 | - | - |
| 9 | 4/4 | - | - |
| 10 | 3/3 | - | - |

**Recent Trend:**

- Last 5 plans: none
- Trend: N/A

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- Initialization: Use `TVOS_CLIENT_PRD.md` as source of truth.
- Initialization: Skip additional research and define requirements directly from the approved PRD.
- Initialization: Use Vertical MVP roadmap mode for every initial phase.
- v1.1: Treat `rest-client/` as the concrete endpoint inventory for client alignment.
- v1.1: `GET /api/v1/system/capabilities` is implemented and remains the setup compatibility gate.
- v1.1: Prioritize movie playback hardware proof before broad catalog, episode, tracks, or beta polish.
- Phase 8: Reconciled route keys, payload shapes, AVKit stream-token transport, safe errors, and additive backend gaps.
- Phase 9: Aligned Swift proof API client with real v1.1 auth, catalog, session, progress, stream-token, HLS, and redaction behavior.
- Phase 10: Physical Apple TV login, navigation, movie selection, and playback start were proven; final phase has client focus and progress/resume evidence gaps.

### Pending Todos

None yet.

### Blockers/Concerns

- Physical Apple TV verification reached playback start, but progress, stop/exit, relaunch, and resume evidence is still required before broad catalog polish can be considered complete.
- The current app has a proof-oriented networking/playback shell aligned to the v1.1 movie proof path, but the movie detail overlay can leave Home focus/navigation active behind it on physical Apple TV.
- `TVOS_CLIENT_PRD.md` is currently untracked and should be included or intentionally ignored before PR preparation.
- Milestone audit found blocking human-verification gaps: physical Apple TV playback proof, backend progress/resume evidence, full catalog/playback/library-action validation, and TestFlight readiness evidence remain incomplete.
- AVKit HLS token transport must be verified against manifests, playlists, segments, and subtitles so protected playback works on physical Apple TV.

## Deferred Items

Items acknowledged and carried forward from previous milestone close:

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Auth | QR/device pairing | Deferred to v2 | Initialization |
| Discovery | Local network discovery | Deferred to v2 | Initialization |
| Platform | Top Shelf behavior | Deferred until playback and Home are stable | Initialization |
| Product | Household profiles | Deferred to v2 | Initialization |
| Playback | Offline downloads and FairPlay DRM | Deferred to later product decision | Initialization |

## Quick Tasks Completed

| Date | Task | Summary |
|------|------|---------|
| 2026-06-03 | catalog-screens-split | Extracted catalog tab shell and browsing screens from `ContentView.swift`; generic tvOS build and simulator tests passed. |
| 2026-06-03 | setup-auth-screen-split | Extracted setup/sign-in screens and shared contract badge from `ContentView.swift`; generic tvOS build and simulator tests passed. |
| 2026-06-03 | refactor-checkpoint-hygiene | Untracked local Xcode user-state noise and prepared the completed refactor set for a checkpoint commit. |
| 2026-06-03 | catalog-components-split | Extracted reusable catalog components and shared status text from `ContentView.swift`; generic tvOS build and simulator tests passed. |
| 2026-06-03 | content-view-playback-detail-split | Split catalog detail overlay and AVKit player bridge out of `ContentView.swift`; generic tvOS build and simulator test run passed. |
| 2026-06-04 | replace-movie-detail-overlay | Replaced the catalog detail overlay with a dedicated SwiftUI navigation page; generic tvOS build passed with code signing disabled. |
| 2026-06-04 | media-detail-page-polish | Polished the dedicated tvOS media detail page with a cinematic hero, clearer Play/Resume focus, progress/status cards, and focus-aware season controls; generic tvOS build passed with code signing disabled. |
| 2026-06-04 | detail-back-navigation-auth-regression | Made startup session restore idempotent so returning from the media detail page cannot unexpectedly move an active session back to sign-in; generic tvOS build passed with code signing disabled. |
| 2026-06-04 | full-bleed-detail-page | Converted the media detail hero from a contained card into a full-bleed first-screen tvOS page layout; generic tvOS build passed with code signing disabled. |
| 2026-06-05 | plex-inspired-detail-ui | Reworked the media detail page into a Plex-inspired tvOS pre-play layout with dimmed full-screen artwork, left-aligned title/logo, compact metadata, action pills, and quieter detail rows; generic tvOS build passed with code signing disabled. |
| 2026-06-05 | detail-page-edge-to-edge | Hid detail navigation chrome and let the media hero ignore top and horizontal safe areas so artwork can extend to the screen edges; generic tvOS build passed with code signing disabled. |
| 2026-06-05 | detail-page-shelves-actions | Replaced the detail hero artwork renderer with a fill-mode backdrop, removed the non-actionable Ready pill, made Trailer focusable, and added Cast/Behind the Scenes shelves from catalog credits; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | clean-media-detail-page | Simplified the media detail screen into a full-screen detail overlay with root-level backdrop artwork, removed the fragile `TabView.navigationDestination` detail path, and aligned detail decoding with `list_membership` plus flat `credits`; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | senior-tvos-refactor | Hardened playback lifecycle, diagnostics redaction, token storage, manifest URL safety, artwork URL resolution, and tvOS focus semantics; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | playback-capabilities-refactor | Added capability-driven route rendering, revalidated capabilities during session restore, extracted playback proof loading from `AppModel`, and made AVKit teardown stop playback sessions on exit; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | catalog-repository-refactor | Extracted catalog home/search/detail/episode orchestration into `CatalogRepository`, added repository snapshots and fake-client tests; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | stability-roadmap-execution | Added auth/session repository, 401/403 session expiration handling, AppModel flow tests, and search/detail stale-load guards; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | network-diagnostics-playback-hardening | Added typed safe diagnostics, explicit tvOS URLSession timeout/cache policy, no-playable-media fixture coverage, and playback proof cleanup/error-propagation tests; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | keychain-signin-error | Fixed raw TokenStoreError surfacing during sign-in by using update-or-add Keychain writes and mapping token-store failures to a safe storage error; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | signin-simulator-ux-fix | Added app Keychain entitlement, renamed sign-in username state/copy to email, and added visible signing-in feedback; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | simulator-tokenstore-fallback | Added a simulator-only memory fallback for Keychain failures so sign-in can be tested when tvOS simulator secure storage is unavailable; generic tvOS build and build-for-testing passed with code signing disabled. |
| 2026-06-06 | person-credit-card-refactor | Replaced movie detail person cards with a reusable Home-inspired credit card that shows character/job first and actor/person underneath; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | card-focus-style | Disabled the system white/gray tvOS focus plate on featured, poster, and person cards while preserving custom scale, border, and shadow feedback; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | remove-card-button-focus-plate | Removed `Button` wrappers from featured, poster, and person cards so tvOS cannot apply the white/gray button focus plate; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-person-shelf-right-bleed | Let movie detail person shelves render in a full-width band with no trailing shelf padding so focused cards can move off the right edge; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-person-shelf-edge-to-edge-scroll | Removed parent shelf viewport padding, kept only title/start content inset, and zeroed horizontal scroll content margins so cards clip at screen edges while navigating; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-person-shelf-full-bleed-simple | Removed the remaining people row content inset while keeping title alignment, making person shelves simple full-bleed rows; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-person-shelf-safe-area-fix | Restored the preferred initial row inset and made the detail vertical scroll viewport ignore horizontal safe area so people shelves can scroll against screen edges; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-scroll-layout-stability | Localized horizontal safe-area ignoring to people shelf scroll views instead of the whole detail page to avoid initial full-bleed layout jumps; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-person-shelf-deterministic-width | Replaced the unstable safe-area-based people shelf layout with an explicit GeometryReader viewport width while preserving the initial left inset; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | detail-person-shelf-recommended-safe-layout | Reverted the people shelves to a simple tvOS-safe SwiftUI layout matching the Home shelf pattern, removing GeometryReader viewport sizing and full-bleed scroll hacks; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | person-card-size-tweak | Slightly increased reusable person credit cards for better tvOS readability while preserving the existing focus behavior; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | physical-apple-tv-keychain-fix | Removed unnecessary Keychain access-group entitlement and simplified Keychain query attributes so physical Apple TV sign-in can use the app's default secure storage; generic tvOS build passed with code signing disabled. |
| 2026-06-06 | native-player-overlay-exit | Removed the custom playback top overlay, provided the movie title through AVKit metadata, and handled remote Back/Menu as an in-app playback exit; generic tvOS build passed with code signing disabled. |
| 2026-05-30 | catalog-home-shell | Added native tvOS catalog tabs, home shelves, browse grids, search, catalog API loading, and artwork-backed cards. |

## Session Continuity

Last session: 2026-05-30
Stopped at: Milestone v1.1 initialized and ready to plan Phase 8.
Resume file: None
