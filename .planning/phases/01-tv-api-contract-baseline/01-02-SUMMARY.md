---
phase: 01-tv-api-contract-baseline
plan: 02
subsystem: "api-contract"
tags: ["tvos", "errors", "diagnostics", "redaction"]
provides: ["error-envelope-contract", "redaction-policy", "error-fixtures"]
affects: ["docs/tvos-api-contract.md", "luminaTests/Fixtures"]
tech-stack:
  added: []
  patterns: ["safe-error-envelope", "diagnostics-correlation"]
key-files:
  created:
    - luminaTests/Fixtures/error-envelope-stream-token-expired.json
    - luminaTests/Fixtures/error-envelope-validation.json
  modified:
    - docs/tvos-api-contract.md
key-decisions:
  - "TV-consumed errors use stable code, category, safe message, retryability, and correlation ID."
  - "Diagnostics allow support correlation but forbid secrets and backend internals."
patterns-established:
  - "Representative error fixtures define client decoding expectations."
duration: "20min"
completed: 2026-05-30
status: complete
---

# Phase 1: Define TV error envelope redaction rules and diagnostics correlation fields Summary

**Defined stable, user-safe error and diagnostics contracts for TV-consumed backend failures.**

## Performance

- **Duration:** 20min
- **Tasks:** 3 completed
- **Files modified:** 3

## Accomplishments

- Added error envelope fields, client categories, retryability, and safe-message behavior.
- Added redaction rules and allowed diagnostics fields for support correlation.
- Added validation and stream-token error fixtures.

## Task Commits

1. **Error envelope and diagnostics fixtures** - uncommitted workspace changes

## Files Created/Modified

- `docs/tvos-api-contract.md` - Error envelope and redaction rules.
- `luminaTests/Fixtures/error-envelope-stream-token-expired.json` - Retryable playback token error fixture.
- `luminaTests/Fixtures/error-envelope-validation.json` - Unsupported capability error fixture.

## Decisions & Deviations

None - followed plan as specified.

## Next Phase Readiness

Phase 2 can implement error DTOs, redaction helpers, diagnostics boundaries, and user-safe setup/auth error mapping.
