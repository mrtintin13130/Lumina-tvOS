---
phase: 12
phase_name: "Remote-First tvOS UX Hardening"
status: complete
created_at: 2026-06-08
---

# Phase 12 Context

## Decisions

- Add explicit default focus targets on setup, sign-in, server unavailable, search, settings, detail, editorial, and playback loading screens.
- Preserve focus memory pragmatically where SwiftUI state can support it cleanly, especially tab selection and current overlay actions.
- Hide polished placeholder controls when there is no useful user flow yet; use clear unavailable copy only when the unavailable state helps explain missing backend/client support.
- Improve current manual setup and search flows with clearer URL normalization, saved-server affordances, dictation-friendly labels, and safe empty/error states.
- Defer QR/device-code pairing, Universal Search, Siri app integration, full XCUITest replacement, and hardware playback evidence to later phases.

## Current Code Shape

- `ContentView` routes app phases and presents detail/editorial overlays above `HomeShellView`.
- `HomeShellView` uses a standard tvOS `TabView` with Home, Movies, TV Shows, Search, and Settings tabs.
- Existing cards and hero components already provide custom focus scale, stroke, and shadow effects.
- Setup/sign-in screens are large-format tvOS views but do not yet declare default focus.
- Search uses a text field plus button but lacks remembered query affordances or stronger empty-state recovery.
- Detail page still exposes Trailer and person buttons that only produce placeholder messages.
- Genre pills call `openCatalogLink`, which is also placeholder-only.

## Constraints

- Keep the Phase 11 state-owner split intact; use `AppModel` as the SwiftUI binding surface.
- Do not introduce third-party dependencies.
- Keep text readable at living-room distance and avoid layout jumps from async artwork or focused scaling.
- Do not expose secrets or raw diagnostics in user-visible copy.
- Simulator runtime execution is unavailable in this environment; generic tvOS build and build-for-testing remain the repeatable local gates.

## Deferred

- QR/device-code sign-in.
- Siri/Universal Search/Apple TV app integration.
- Full Top Shelf implementation.
- Full XCUITest replacement.
- Physical Apple TV playback evidence.
