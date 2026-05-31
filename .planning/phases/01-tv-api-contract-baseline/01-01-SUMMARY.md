---
phase: 01-tv-api-contract-baseline
plan: 01
subsystem: "api-contract"
tags: ["tvos", "capabilities", "contract"]
provides: ["route-matrix", "capability-contract", "capability-fixtures"]
affects: ["docs/tvos-api-contract.md", "luminaTests/Fixtures"]
tech-stack:
  added: []
  patterns: ["safe-json-fixtures", "capability-first-validation"]
key-files:
  created:
    - docs/tvos-api-contract.md
    - luminaTests/Fixtures/capabilities-supported.json
    - luminaTests/Fixtures/capabilities-unsupported.json
  modified: []
key-decisions:
  - "Server compatibility is determined through an explicit capabilities response before feature use."
  - "Backend remains source of truth; tvOS requests only additive gaps."
patterns-established:
  - "Contract docs pair with JSON fixtures for future client decoding tests."
duration: "25min"
completed: 2026-05-30
status: complete
---

# Phase 1: Define TV client route matrix and capability contract Summary

**Defined the TV route matrix and capability compatibility contract for the native tvOS client.**

## Performance

- **Duration:** 25min
- **Tasks:** 3 completed
- **Files modified:** 3

## Accomplishments

- Added `docs/tvos-api-contract.md` with compatibility flow, capability schema, and route matrix.
- Added supported and unsupported capability fixtures for Phase 2 decoding and state tests.

## Task Commits

1. **Route matrix and capability fixtures** - uncommitted workspace changes

## Files Created/Modified

- `docs/tvos-api-contract.md` - Defines route ownership and capability compatibility.
- `luminaTests/Fixtures/capabilities-supported.json` - Supported MVP server fixture.
- `luminaTests/Fixtures/capabilities-unsupported.json` - Unsupported server fixture.

## Decisions & Deviations

None - followed plan as specified.

## Next Phase Readiness

Phase 2 can use the capability fixture shape to implement typed DTOs, compatibility validation, setup states, and decoding tests.
