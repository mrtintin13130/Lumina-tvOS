# Lumina Native tvOS Client

## What This Is

Lumina Native tvOS Client is a first-class Apple TV app for browsing and playing a user's Lumina media library from the living room. It is a native SwiftUI, AVKit, and AVFoundation client that consumes the existing Lumina API as the source of truth for catalog, identity, playback, progress, watched state, watchlist, favorites, stream tokens, HLS/direct streaming, subtitles, track metadata, scanner state, metadata, and diagnostics.

The repository currently contains an Xcode-generated tvOS SwiftUI scaffold. The next work is to turn that scaffold into a remote-control-first media app while keeping backend changes additive and focused on the TV client contract.

## Core Value

One authenticated Apple TV client can connect to a Lumina server, play HLS video through native AVKit on physical Apple TV, report progress, and resume reliably.

## Current Milestone: v1.2 Stability, Usability, And Beta Hardening

**Goal:** Turn the working tvOS client into a stable, usable, remote-first beta candidate by hardening the core movie path, focus/navigation behavior, diagnostics, and verification without overbuilding non-MVP features.

**Target features:**
- Reduce architecture risk by separating session, catalog, playback, and diagnostics responsibilities from the current central app model while keeping the implementation lightweight and testable.
- Finish the user-critical Apple TV path: server setup, sign-in, Home, movie details, playback, exit, relaunch, resume, settings, and sign-out.
- Harden tvOS focus, default focus, focus restoration, remote Back/Menu behavior, and setup/search text-entry friction so the app feels natural from the couch.
- Make diagnostics and support information useful and safe for real debugging without exposing JWTs, stream tokens, Authorization headers, signed URLs, local paths, SQL details, stack traces, or raw subprocess output.
- Add repeatable unit/UI/hardware verification gates for playback lifecycle, progress/resume, focus/navigation, and beta readiness.

## Requirements

### Validated

- ✓ A native tvOS Xcode project exists with app, unit-test, and UI-test targets — existing scaffold
- ✓ The app target uses SwiftUI and targets Apple TV / tvOS 17.2 — existing project settings
- ✓ Product direction is documented in `TVOS_CLIENT_PRD.md` — approved PRD
- ✓ A codebase map exists under `.planning/codebase/` — existing planning context

### Active

- [ ] Split high-risk responsibilities out of `AppModel` into small session, catalog, playback, and diagnostics coordinators or models while preserving existing SwiftUI behavior and tests.
- [ ] Remove, hide, or explicitly disable user-visible placeholder actions such as episode playback, trailer playback, genre browsing, and person details until they are real flows.
- [ ] Harden tvOS focus behavior across setup, sign-in, Home, grids, search, detail overlays, editorial overlays, settings, and playback exit so focus is visible, predictable, and restored after navigation.
- [ ] Complete movie playback lifecycle proof on physical Apple TV, including start, pause/exit, stop, relaunch, resume, expired stream-token, missing media, server restart/unreachable, subtitles, and alternate audio where available.
- [ ] Add safe Settings diagnostics/support information that exposes app/server/session context useful for support while preserving all security redaction requirements.
- [ ] Replace template UI tests with focused XCUITest coverage for setup/sign-in shell, Home, search, detail, playback entry, Settings, and sign-out, plus keep generic tvOS build/test-build commands repeatable.
- [ ] Prepare a small-beta readiness checklist with reviewer path, demo server expectations, seed media coverage, physical QA evidence, privacy decisions, and known deferrals.

### Out of Scope

- Rewriting the Lumina API — the backend remains the source of truth and MVP changes should be additive.
- Replacing Express, PostgreSQL, CommonJS, or the modular-monolith backend — not required for the tvOS MVP.
- Replacing current JWT auth as an MVP prerequisite — username/password JWT login is the locked MVP auth path.
- QR/device pairing — deferred until after playback MVP.
- Local network discovery — deferred until after manual server setup and playback MVP.
- Making HLS the only global backend playback mode — Apple TV should prefer HLS without breaking direct streaming for other clients.
- FairPlay DRM — not part of MVP.
- Offline video downloads — not part of MVP.
- App Store subscriptions, IAP, hosted commercial entitlements, Apple Video Partner Program, Universal Search, Siri, zero sign-on, or Apple TV app integration — deferred App Store/commercial scope.
- Android TV implementation — separate future effort.
- Full household profile system — deferred; MVP must clearly show current signed-in user.
- Backend-for-frontend service — not justified unless existing route aggregation proves insufficient.
- Top Shelf product behavior — deferred until playback and Home are stable.

## Context

The repository has grown from the initial SwiftUI scaffold into a real native Apple TV client with setup/auth screens, Bonjour/manual server selection, capability validation, Keychain-backed token storage, catalog loading, Home shelves, search, movie/TV detail surfaces, AVKit playback, stream-token HLS support, progress/session reporting, redacted diagnostics, localization, fixtures, and meaningful unit tests.

`TVOS_CLIENT_PRD.md` is the strongest product source. It sets the app direction as a native tvOS client using SwiftUI, AVKit, AVFoundation, URLSession, Codable, Keychain Services, XCTest/XCUITest, and minimal third-party dependencies. It explicitly rejects Flutter, avoids React Native for TV unless native development becomes impossible, and reserves Unity for unrelated game/3D scenarios.

The app is a client of an existing Lumina API. The backend remains responsible for catalog composition, media identity, playback progress, watched state, watchlist, favorites, stream tokens, HLS/direct streaming, subtitles, track metadata, scanner state, TMDB metadata, and diagnostics. Client development should consume existing routes first and drive focused additive backend additions only when the API does not support a high-quality TV experience.

The PRD's critical vertical slice is the highest-priority proof: manual server setup, capability validation, JWT login, one playable movie fetch, detail/playability check, stream token, HLS playback through AVKit, progress reporting, exit, relaunch, and resume. This must succeed on physical Apple TV before broad catalog polish.

The `rest-client/` endpoint collection is now the concrete backend endpoint inventory for this milestone. It confirms the available auth, catalog, HLS, playback session, progress, watched-state, track, subtitle, watchlist, and favorite routes. `GET /api/v1/system/capabilities` is implemented even though it is not listed in the endpoint collection, so the client should validate against that route and reconcile route-key details against the real backend response.

The current senior-review finding is that the app has promising foundations but is not yet beta-stable. `AppModel` now concentrates too many concerns, some polished UI affordances still lead to placeholder messages, tvOS focus/default-focus behavior is uneven, physical Apple TV playback evidence remains the gate for confidence, Settings diagnostics are too thin for real support, and UI tests still mostly reflect the generated template.

## Constraints

- **Platform**: Native tvOS / Apple TV app — the user experience must be remote-control-first and focus-driven.
- **Minimum OS**: tvOS 17+ by default — raise to tvOS 18+ only after hardware/toolchain confirmation.
- **Stack**: SwiftUI, AVKit, AVFoundation, URLSession, Codable, async/await, URLCache/NSCache, Keychain Services, XCTest/XCUITest — matches PRD and current scaffold.
- **Dependencies**: Minimal third-party dependencies — reduce platform, privacy, and App Store risk.
- **Backend compatibility**: Additive backend changes only for MVP — avoid route rewrites and API replacement.
- **Auth**: Existing username/password JWT login first — QR/device pairing is deferred.
- **Server setup**: Manual server URL entry first — local discovery is deferred.
- **Playback**: HLS-preferred on Apple TV, direct stream compatibility preserved elsewhere — align with AVKit without changing global backend behavior.
- **Verification**: Physical Apple TV playback proof required before broad Home/Search/TV-show polish — simulator success is insufficient.
- **Security**: Store tokens only in Keychain and never log or display JWTs, stream tokens, passwords, Authorization headers, local filesystem paths, SQL details, stack traces, or raw subprocess output.
- **Diagnostics**: Capture user-safe client diagnostics that can correlate with backend playback sessions — support debugging without becoming monetization analytics.
- **Repository hygiene**: `TVOS_CLIENT_PRD.md` is currently untracked and Xcode user state may need ignore rules — review before collaboration or PR preparation.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Build a native tvOS app rather than Flutter, React Native for TV, or Unity | Native SwiftUI/AVKit best matches Apple TV focus, player behavior, platform compliance, and PRD risk profile | — Pending |
| Use existing Lumina username/password JWT auth for MVP | Avoid delaying playback proof on a new device-pairing auth system | — Pending |
| Defer QR/device pairing | Remote-control sign-in is imperfect, but playback proof is higher risk and higher leverage | — Pending |
| Use manual server URL entry first | Local discovery can be added after the core server-auth-playback path works | — Pending |
| Prefer HLS playback on Apple TV | HLS aligns with AVKit and platform media expectations | — Pending |
| Preserve direct streaming support for existing clients | tvOS preferences should not break backend behavior used elsewhere | — Pending |
| Require physical Apple TV proof before broad catalog polish | HLS, remote behavior, track selection, buffering, and long playback can differ from simulator behavior | — Pending |
| Keep backend changes additive for MVP | The tvOS client should not become a backend rewrite project | — Pending |
| Defer household profiles but show current signed-in user clearly | Shared TV privacy matters, but a full profile system is outside MVP scope | — Pending |
| Defer Top Shelf until playback and Home are stable | Top Shelf is polish and platform integration, not the riskiest MVP path | — Pending |
| Start in this repository unless a later decision moves the client | The current workspace already contains the tvOS Xcode scaffold | — Pending |
| Treat `rest-client/` as the concrete endpoint inventory for v1.1 alignment | The endpoint collection exposes the real route names and payload shapes the tvOS client must call | — Pending |
| Keep v1.1 focused on movie playback proof before broad UI polish | The audit found hardware playback/progress/resume evidence is the highest-risk gap | — Pending |
| Start v1.2 as stabilization and usability hardening rather than feature expansion | The app now builds and has real client surfaces, but beta risk is in architecture concentration, focus behavior, playback lifecycle proof, diagnostics, and verification | — Pending |
| Continue roadmap numbering from Phase 11 | The existing v1.1 roadmap already owns phases 8-10 and should remain traceable | — Pending |
| Hide or explicitly disable unfinished actions before beta | On tvOS, selecting a focused item that only says "not wired yet" feels broken even if the underlying MVP path works | — Pending |
| Keep architecture refactoring right-sized | Split high-risk responsibilities out of `AppModel` without introducing a large framework or over-abstracted architecture | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-08 after v1.2 milestone start*
