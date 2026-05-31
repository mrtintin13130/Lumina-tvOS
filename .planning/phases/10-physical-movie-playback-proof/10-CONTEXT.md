# Phase 10: Physical Movie Playback Proof - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase proves the v1.1 movie playback loop on physical Apple TV against a live Lumina server: sign in, select a playable movie, create a playback session, start AVKit HLS playback with supported token transport, report progress, stop/exit, relaunch, and resume from backend state. In this environment, the agent can prepare the proof path and evidence checklist, but final pass requires user-run hardware validation.

</domain>

<decisions>
## Implementation Decisions

### Proof Scope
- Validate one movie playback path only; broad Home/search/details polish remains deferred.
- Use the Phase 9 client path as the executable proof path.
- Treat simulator/build success as supporting evidence only, not release proof.
- Require backend-correlatable evidence for session ID, movie ID, progress position, resume, and stop behavior.

### Evidence And Safety
- Evidence should be safe: no JWTs, stream tokens, Authorization headers, tokenized URLs, local paths, SQL details, stack traces, raw subprocess output, or private server data.
- Prefer screenshots/photos of user-safe app states plus backend records with sensitive fields redacted.
- Record failures as explicit gaps instead of burying them in local notes.

### the agent's Discretion
The agent may create a runbook/checklist and verification artifact. The user must perform the physical Apple TV run and report results.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Phase 9 aligned the proof API path in `lumina/LuminaCore.swift`.
- `docs/tvos-qa-matrix.md` already lists physical playback evidence areas.
- `docs/tvos-api-contract.md` documents the v1.1 contract and token transport rules.

### Established Patterns
- Hardware proof is a manual gate.
- Verification docs should clearly distinguish automated build evidence from physical device evidence.

### Integration Points
- `ContentView` exposes "Playback Proof" from Home and opens AVKit playback.
- `AppModel.loadPlaybackProof()` fetches one movie, reads progress, creates a session, gets stream token where required, and builds HLS URL.
- `AppModel.reportPlaybackProgress()` writes progress and updates/stops the playback session.

</code_context>

<specifics>
## Specific Ideas

Create a concise physical proof checklist that can be followed with a live Lumina server and Apple TV, then pause for results.

</specifics>

<deferred>
## Deferred Ideas

Episode playback, subtitles/audio track selection proof, full beta readiness, and broad catalog polish remain later work.

</deferred>
