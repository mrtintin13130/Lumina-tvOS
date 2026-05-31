# Phase 3: Critical Playback Proof - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase adds the minimum authenticated playback path: fetch a playable movie candidate, show detail/playability, obtain stream-token/session context when supported, launch HLS through AVKit, report progress, exit, relaunch, and resume. Physical Apple TV evidence is required for final proof, but this environment can only build the code path and record the manual verification requirement.

</domain>

<decisions>
## Implementation Decisions

### Playback Slice
- Add a minimal playable movie/detail model rather than full browse polish.
- Prefer HLS manifest URLs from backend routes and AVKit native playback.
- Preserve session IDs, progress position, and media IDs for diagnostics correlation.
- Report progress at app-controlled events and make cadence extensible.

### Error Handling
- Map stream-token, manifest, missing-media, and auth failures into safe status text.
- Never expose stream tokens, signed URLs, Authorization headers, local paths, or stack traces.
- Treat physical Apple TV proof as a manual verification artifact.
- Keep simulator/build success as supporting evidence only.

### the agent's Discretion
The agent may use a compact sample-proof UI as long as backend-connected code paths and AVKit entry points are real.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Phase 2 added `AppModel`, typed API client, diagnostics redaction, setup/auth UI, and settings shell.
- Phase 1 documented HLS, stream-token, playback session, progress, and redaction expectations.

### Established Patterns
- App state is phase-based in `AppModel`.
- UI is remote-first SwiftUI with large focusable buttons.
- Token material flows through `TokenStore`.

### Integration Points
- Extend `LuminaAPIClient` and `AppModel` with playback-proof methods.
- Extend `ContentView` Home with a Play Proof action and AVKit player screen.

</code_context>

<specifics>
## Specific Ideas

Keep this as one vertical movie proof, not a general playback refactor.

</specifics>

<deferred>
## Deferred Ideas

Episodes, track selection, full library actions, broad details, and exhaustive QA matrix remain later phases.

</deferred>
