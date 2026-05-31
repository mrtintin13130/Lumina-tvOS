# Phase 8: Backend Contract Reconciliation - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase reconciles the Phase 1 tvOS API contract, implemented capabilities fixtures, current Swift placeholder assumptions, and the `rest-client/` endpoint inventory into a concrete v1.1 proof-path contract. It delivers implementation-ready route keys, payload names, token transport rules, safe error semantics, and additive backend gap records for setup, auth, playable movie selection, stream token, HLS, playback sessions, progress, stop, relaunch, and resume. It does not implement broad catalog polish or physical playback proof; those belong to later phases.

</domain>

<decisions>
## Implementation Decisions

### Contract Scope And Source Of Truth
- Make the reconciled route matrix the source of truth for Phase 9 client alignment.
- Capabilities must list the concrete route keys required by the movie proof path, including setup, auth restore, catalog movie browse/detail, stream token, movie HLS manifest, playback session create/update/stop, movie progress read/write, tracks/subtitles where relevant, and safe diagnostics correlation.
- Treat existing placeholder route and payload assumptions in Swift/tests as mismatches to reconcile rather than silently preserving compatibility fallbacks.
- Record backend gaps as additive contract items with owner, route or route family, client impact, and test expectation.

### Stream Token And AVKit HLS Transport
- Document query-parameter `stream_token` as the required AVKit-compatible fallback for manifests, child playlists, segments, and subtitles because AVKit cannot reliably attach custom authorization headers to every derived segment/subtitle request.
- Keep Authorization-header examples for API and URLSession-controlled client requests, including login/session restore, catalog, stream-token creation, playback sessions, and progress.
- Require tokenized HLS URLs to be redacted from diagnostics, logs, tests, screenshots, and support evidence.
- Require backend tests or documented acceptance checks proving token propagation from manifest to playlists, segments, and subtitles.

### Payload And Naming Alignment
- Prefer the `rest-client/` payload spelling for real v1.1 calls: `media_type`, `media_id`, `position_seconds`, `duration_seconds`, `play_state`, `client_label`, and session IDs.
- Preserve Swift-friendly model names internally only behind DTO mapping; request/response fixtures must prove the wire shape.
- Define movie progress as the proof-path resume source through `/api/v1/playback/movies/:movieId/progress`.
- Treat the current generic `/api/v1/playback/progress` placeholder and camelCase proof payloads as Phase 9 replacement targets unless the backend explicitly supports them.

### Safe Error And Diagnostics Semantics
- Map setup, auth, capability, catalog, stream token, HLS manifest/playlist/segment, subtitle, playback session, progress, missing media, and server unavailable failures into stable safe categories.
- Never expose JWTs, stream tokens, Authorization headers, signed URLs, local filesystem paths, SQL details, stack traces, raw subprocess output, or private environment values.
- Preserve safe correlation fields: request correlation ID, playback session ID, media ID, media kind, operation, route key, status code, retryability, and safe message key.
- Use contract fixtures/tests to prove redaction and error decoding for the proof path before Phase 9 broadens the client calls.

### the agent's Discretion
The agent may choose exact document sections, fixture filenames, and test grouping as long as Phase 8 outputs are implementation-ready for Phase 9 and trace back to CONT-05 through CONT-09.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `docs/tvos-api-contract.md` contains the Phase 1 baseline contract, route matrix, capability shape, error envelope, redaction rules, and playback expectations.
- `docs/tvos-backend-contract-tests.md` contains baseline backend contract test requirements and the existing additive gap list.
- `rest-client/00-health-auth.http`, `rest-client/04-stream-playback.http`, and `rest-client/05-catalog.http` provide concrete auth, stream/playback, and catalog endpoint examples for this reconciliation.
- `lumina/LuminaCore.swift` and `luminaTests/luminaTests.swift` show current placeholder API assumptions that Phase 9 must align with the real route and payload shapes.
- `luminaTests/Fixtures/capabilities-supported.json`, `capabilities-unsupported.json`, and safe error fixtures provide a starting point for compatibility tests.

### Established Patterns
- Planning artifacts live under `.planning/`, product docs live under `docs/`, app code lives under `lumina/`, and fixtures live under `luminaTests/Fixtures/`.
- The app uses native Swift, SwiftUI, URLSession, Codable, async/await, Keychain Services, and XCTest with minimal third-party dependencies.
- Security conventions require token storage only in Keychain and aggressive redaction of secrets, signed URLs, local paths, SQL details, stack traces, and raw subprocess output.

### Integration Points
- Phase 9 will consume the reconciled contract to update Swift DTOs, URL construction, request payloads, route keys, fixture decoding, redaction, and unit tests.
- Phase 10 will consume the same contract for physical Apple TV movie playback proof, backend progress/resume evidence, stop behavior, and safe diagnostics evidence.
- Backend follow-up items should remain additive and should not require a route rewrite or break direct streaming compatibility for other clients.

</code_context>

<specifics>
## Specific Ideas

Use the `rest-client/` endpoint collection as the concrete route inventory for v1.1. Call out every current mismatch that would make Phase 9 guess: placeholder `/api/v1/playback/progress`, camelCase playback proof payloads, generic movie list assumptions, and unclear stream-token transport through derived HLS requests.

</specifics>

<deferred>
## Deferred Ideas

Physical Apple TV proof, broad Home/search/details polish, episode playback, track-selection UI, watchlist/favorite product flows, QR/device pairing, local discovery, Top Shelf behavior, TestFlight release execution, and backend route rewrites remain deferred outside Phase 8.

</deferred>
