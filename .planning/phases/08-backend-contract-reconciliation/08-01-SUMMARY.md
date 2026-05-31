---
phase: 08-backend-contract-reconciliation
plan: 01
subsystem: contract
tags:
  - tvos
  - api-contract
provides:
  - v1.1 route-key matrix
affects:
  - docs/tvos-api-contract.md
tech-stack:
  added: []
  patterns:
    - route-key compatibility contract
key-files:
  created: []
  modified:
    - docs/tvos-api-contract.md
key-decisions:
  - Capabilities route keys are the Phase 9 source of truth.
  - Placeholder Swift route assumptions are explicit alignment targets.
patterns-established:
  - Proof-path route keys map directly to rest-client route families.
duration: "15min"
completed: 2026-05-30
status: complete
---

# Phase 8 Plan 01 Summary: Reconciled Route Matrix

Updated `docs/tvos-api-contract.md` with a v1.1 route-key matrix for setup, auth, catalog movie proof, stream token, movie HLS, playback session lifecycle, movie progress, tracks/subtitles, watchlist, favorites, and diagnostics-adjacent routes.

## Accomplishments

- Reconciled proof-path routes against `rest-client/00-health-auth.http`, `rest-client/04-stream-playback.http`, and `rest-client/05-catalog.http`.
- Added Phase 9 alignment targets for current Swift placeholder calls such as fallback auth routes, generic progress endpoint usage, and camelCase playback payload assumptions.

## Verification

- Confirmed route-key coverage against CONT-05 and CONT-06.
- Confirmed no real secrets, local paths, signed URLs, SQL details, stack traces, or raw subprocess output were added.

## Next Plan Readiness

Playback payload, stream-token, and error semantics can now reference concrete route keys.
