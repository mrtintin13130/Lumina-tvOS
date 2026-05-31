---
phase: 08-backend-contract-reconciliation
plan: 02
subsystem: playback-contract
tags:
  - hls
  - progress
  - diagnostics
provides:
  - playback payload contract
  - AVKit token transport contract
affects:
  - docs/tvos-api-contract.md
  - docs/tvos-backend-contract-tests.md
tech-stack:
  added: []
  patterns:
    - AVKit-compatible stream-token transport
key-files:
  created: []
  modified:
    - docs/tvos-api-contract.md
    - docs/tvos-backend-contract-tests.md
key-decisions:
  - Query `stream_token` is the documented AVKit-compatible fallback for protected HLS derived requests.
  - Wire payloads use backend snake_case names for playback sessions and movie progress.
patterns-established:
  - Safe diagnostics must redact tokenized URLs before proof evidence is captured.
duration: "15min"
completed: 2026-05-30
status: complete
---

# Phase 8 Plan 02 Summary: Playback Payload And Safe Error Contract

Defined the v1.1 proof-loop payload semantics for stream-token creation, playback session create/update/stop, movie progress read/write, and protected HLS token transport.

## Accomplishments

- Added session and progress payload tables for `media_type`, `media_id`, `position_seconds`, `duration_seconds`, `play_state`, `client_label`, and session IDs.
- Documented why AVKit needs an authorized URL/token path for manifests, child playlists, segments, and subtitles.
- Updated backend contract-test requirements for HLS token propagation, safe error categories, and redaction.

## Verification

- Confirmed CONT-07, CONT-08, and CONT-09 are represented in docs and test requirements.
- Confirmed token transport examples are abstract and do not contain real token values.

## Next Plan Readiness

Fixtures and tests can now assert v1.1 proof-path route keys and compatibility behavior.
