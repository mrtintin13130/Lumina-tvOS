# Phase 11: Architecture And State Hardening - Context

**Gathered:** 2026-06-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 11 hardens the tvOS client architecture by splitting high-risk session, catalog, playback, and diagnostics responsibilities out of the central `AppModel` while preserving current setup, sign-in, Home, detail, search, settings, and playback behavior. The phase should remain right-sized: use existing SwiftUI, async/await, repository, loader, token-store, and diagnostics patterns rather than introducing a large framework. Views may be split or polished where that supports clearer ownership, but feature expansion and broad tvOS UX cleanup belong to later phases.

</domain>

<decisions>
## Implementation Decisions

### Architecture Split Shape
- Extract session/auth, catalog, playback, and diagnostics into small focused `@MainActor` models/services, with `AppModel` becoming a thin app coordinator.
- Refactor incrementally, preserving the current SwiftUI-facing properties and methods until tests are in place.
- Use constructor injection for stores, API factories, repositories/loaders, and diagnostics so unit tests can use fakes.
- A thin app coordinator owns `AppPhase`; feature models own their own loading, selected item, playback proof, and diagnostics state.

### Async Stale-Result Boundaries
- Keep explicit request IDs or task tokens per domain, but move them into the owning session/catalog/playback models.
- Add first-class stale-load tests for search query changes, detail changes, editorial section changes, sign-out, playback cancellation, and session expiration.
- When sign-out or reset occurs mid-load, clear domain state, invalidate all in-flight domain IDs, and ignore late results without surfacing stale errors.
- Replace broad flags like `isCatalogLoading` where needed with domain-specific loading flags to prevent one workflow from masking another.

### Test And Verification Scope
- Focus Phase 11 tests on refactored state transitions, stale async guards, sign-out/reset cleanup, and security redaction boundaries.
- Preserve current behavior tests, then add tests against extracted models where ownership moves.
- Require generic tvOS build and build-for-testing with code signing disabled, plus targeted unit tests where the local Xcode environment allows.
- Keep redaction/token-store tests active and add regression coverage that extracted diagnostics/session paths still never expose secrets.

### Refactor Safety And Public Surface
- Take the chance to polish UI and split views more aggressively where it supports the architecture refactor.
- Leave placeholder-action hiding/disabling mainly to Phase 12, but avoid making existing placeholders harder to remove.
- Keep `DiagnosticsRecorder` as the redaction/event primitive and introduce a support/diagnostics-facing state owner only when Phase 14 needs UI data.
- Phase 11 is done when `AppModel` no longer directly owns most session/catalog/playback mechanics, behavior is preserved, and stale-load/security tests pass or are documented with local-tooling limits.

### the agent's Discretion
The agent may choose the exact type names, file grouping, method boundaries, and order of extraction as long as the resulting implementation follows existing Swift/Xcode conventions, keeps dependencies minimal, preserves security redaction, and avoids unrelated feature expansion.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lumina/App/AppModel.swift` currently owns app phase, setup/auth, catalog/search/detail/editorial, playback proof/progress, diagnostics recording, URL normalization, and reset/sign-out cleanup.
- `lumina/Auth/AuthSessionRepository.swift` already encapsulates restore, sign-in, sign-out, token access, and saved-server interactions.
- `lumina/Networking/CatalogRepository.swift` already encapsulates Home, search, movie detail, TV detail, episodes, and editorial section loading.
- `lumina/Playback/PlaybackProofLoader.swift` already encapsulates movie proof preflight and stops created playback sessions when preflight fails.
- `lumina/Diagnostics/DiagnosticsRecorder.swift` already provides redaction and structured safe diagnostics events.
- `luminaTests/luminaTests.swift` contains current behavior coverage for capabilities, API DTOs, token storage, diagnostics redaction, auth/session behavior, catalog repository snapshots, and playback proof loading.

### Established Patterns
- Application state is currently `@MainActor` and `ObservableObject` driven, with SwiftUI observing published properties.
- Async stale-result protection currently uses `UUID` load IDs for playback, search, detail, and editorial loads.
- Dependencies are injected through initializer parameters and lightweight protocols/factories where tests need fakes.
- User-facing errors should use `LuminaClientError.safeMessage` or redacted strings from `DiagnosticsRecorder`.
- Token and server settings are accessed through `TokenStore` and `ServerSettingsStore`; secrets must stay behind those abstractions.

### Integration Points
- `ContentView` and feature views currently interact with one `AppModel`; the refactor should preserve this surface initially or provide focused adapters so views remain stable.
- `AVKitPlayerView.Coordinator` calls `AppModel` for progress reporting, playback failure recording, media-option diagnostics, and playback exit; this is a key playback extraction boundary.
- Setup and sign-in screens use `serverURLString`, `email`, `password`, `statusMessage`, `capabilities`, and app phase transitions; this is the session extraction boundary.
- Catalog screens use Home sections, search state, selected detail/editorial state, loading flags, artwork URL resolution, and catalog action methods; this is the catalog extraction boundary.

</code_context>

<specifics>
## Specific Ideas

The user accepted recommended answers for architecture, stale async, testing/security, diagnostics ownership, and done criteria. The user changed the view-surface answer to allow UI polish and more aggressive view splitting where it directly supports the architecture refactor.

</specifics>

<deferred>
## Deferred Ideas

- Broad placeholder-action hiding/disabling is deferred mainly to Phase 12.
- Full Settings diagnostics UI is deferred to Phase 14 unless minimal ownership extraction is needed now.
- Physical playback lifecycle proof and hardware QA remain Phase 13 and Phase 15 work.

</deferred>
