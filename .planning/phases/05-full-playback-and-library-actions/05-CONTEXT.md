# Phase 5: Full Playback And Library Actions - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Expand playback from the Phase 3 movie proof into movie and episode playback behavior, progress cadence, watched state, track behavior, and watchlist/favorite actions.

</domain>

<decisions>
## Implementation Decisions

### the agent's Discretion
Preserve native AVKit controls, backend progress authority, safe diagnostics, and optimistic library actions with refresh recovery.

</decisions>

<code_context>
## Existing Code Insights

Phase 3 added AVKit HLS entry, playback session creation, and progress reporting hooks.

</code_context>

<specifics>
## Specific Ideas

See `docs/tvos-feature-readiness.md`.

</specifics>

<deferred>
## Deferred Ideas

FairPlay DRM and offline downloads remain out of scope.

</deferred>
