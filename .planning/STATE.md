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
| 2026-05-30 | catalog-home-shell | Added native tvOS catalog tabs, home shelves, browse grids, search, catalog API loading, and artwork-backed cards. |

## Session Continuity

Last session: 2026-05-30
Stopped at: Milestone v1.1 initialized and ready to plan Phase 8.
Resume file: None
