# Phase 4: Home, Browse, Search, And Details - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the signed-in library discovery surfaces: Home, search, browse, movie detail, TV detail, loading/empty/error states, artwork fallback behavior, and safe non-playable states.

</domain>

<decisions>
## Implementation Decisions

### the agent's Discretion
Use backend-supported routes and preserve backend ordering. Keep UI remote-first and do not add marketing screens.

</decisions>

<code_context>
## Existing Code Insights

The Phase 2 shell and Phase 3 playback proof provide the app state, API client, and Home entry point that catalog screens extend.

</code_context>

<specifics>
## Specific Ideas

See `docs/tvos-feature-readiness.md`.

</specifics>

<deferred>
## Deferred Ideas

Final physical-device catalog polish remains tied to the QA matrix.

</deferred>
