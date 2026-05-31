# Phase 9: Real API Client Alignment - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase updates the tvOS Swift networking layer, DTOs, request payloads, fixtures, and tests so the proof path uses the real v1.1 Lumina endpoint shapes from Phase 8. It covers capabilities gating, auth/session restore, playable movie selection, playback session create/update/stop, movie progress read/write, stream-token-aware HLS URL construction, safe errors, and diagnostic redaction. It does not perform physical Apple TV playback proof; that is Phase 10.

</domain>

<decisions>
## Implementation Decisions

### Endpoint Alignment
- Use `/api/v1/auth/login` and `/api/v1/auth/me` without legacy fallback paths.
- Use capability route keys where available, falling back only to the documented v1.1 default route templates.
- Keep the proof path narrowly movie-focused: fetch one playable movie from catalog, read its progress, create a movie playback session, build HLS URL, report progress, stop, and allow resume data to flow.
- Treat broad Home/search/details/catalog polish as out of scope.

### DTO And Payload Shape
- Match backend wire names for playback: `media_type`, `media_id`, `position_seconds`, `duration_seconds`, `play_state`, and `client_label`.
- Keep Swift model names idiomatic behind `CodingKeys` and targeted DTOs.
- Decode flexible backend IDs as strings when needed, because current fixtures and prior code tolerate numeric IDs.
- Prefer backend progress route `/api/v1/playback/movies/:movieId/progress` over generic placeholder progress routes.

### Stream Token And HLS
- Request stream-token behavior before protected HLS playback when capabilities require it.
- Build AVKit-compatible HLS URLs by appending scoped `stream_token` query data to the manifest route when a token is returned.
- Do not attach or expose Authorization headers as proof playback diagnostics; the prior header-only AVURLAsset path is not enough for AVKit-derived requests.
- Redact tokenized URLs and token-like query strings in diagnostics/tests.

### Testing And Verification
- Add focused XCTest coverage for route-key construction, DTO decoding, snake_case payload encoding, progress/resume route usage, stream-token URL construction, and redaction.
- Use JSON fixtures derived from the v1.1 contract.
- Verify with JSON parsing and `xcodebuild build-for-testing` in no-sign mode; simulator execution remains dependent on local CoreSimulator health.

### the agent's Discretion
The agent may keep implementation compact inside `LuminaCore.swift` for this proof phase, but should leave clear seams for Phase 10 playback proof and later refactoring.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `docs/tvos-api-contract.md` is the Phase 8 source of truth for route keys and payload semantics.
- `lumina/LuminaCore.swift` already contains `ServerCapabilities`, `URLSessionLuminaAPIClient`, `TokenStore`, `DiagnosticsRecorder`, and `AppModel`.
- `luminaTests/luminaTests.swift` already decodes fixtures and exercises safe error/redaction behavior.

### Established Patterns
- Codable DTOs live in `LuminaCore.swift`.
- Tests use inline JSON for small payloads and fixture files for capability/error contracts.
- Token material stays in `TokenStore`; diagnostics record only redacted safe values.

### Integration Points
- `AppModel.loadPlaybackProof()` should read token, fetch playable movie, read resume progress, create session, obtain stream token when needed, build HLS URL, and enter playback.
- `AppModel.reportPlaybackProgress()` should write movie progress and update session state through the real routes.
- `PlaybackProofView` should avoid depending on Authorization headers for derived HLS requests when a stream token exists.

</code_context>

<specifics>
## Specific Ideas

Add a small route-template helper for capability route keys; add request/response DTOs for stream token, playback session create/update/stop, and movie progress; expand diagnostics redaction for query-token URLs.

</specifics>

<deferred>
## Deferred Ideas

Physical Apple TV proof, backend evidence capture, full catalog UI, episode playback, track selection UI, watchlist/favorite product flows, and TestFlight readiness remain deferred.

</deferred>
