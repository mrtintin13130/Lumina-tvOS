---
status: testing
phase: 10-physical-movie-playback-proof
source:
  - .planning/phases/10-physical-movie-playback-proof/10-01-SUMMARY.md
  - .planning/phases/10-physical-movie-playback-proof/10-02-SUMMARY.md
  - .planning/phases/10-physical-movie-playback-proof/10-03-SUMMARY.md
started: 2026-06-04T20:15:59Z
updated: 2026-06-04T20:20:19Z
---

## Current Test

number: 2
name: Backend Playback Session Creation
expected: |
  Starting movie playback creates or confirms a backend playback session, and safe evidence can identify that a session exists without exposing secrets, tokenized URLs, Authorization headers, filesystem paths, SQL details, stack traces, or raw subprocess output.
awaiting: user response

## Tests

### 1. Physical Sign-In And Movie Playback Start
expected: On a physical Apple TV, you can sign in to the live Lumina server, navigate to a playable movie, open its detail page without underlying Home focus moving behind it, and start playback through the native player.
result: pass

### 2. Backend Playback Session Creation
expected: Starting movie playback creates or confirms a backend playback session, and safe evidence can identify that a session exists without exposing secrets, tokenized URLs, Authorization headers, filesystem paths, SQL details, stack traces, or raw subprocess output.
result: [pending]

### 3. Progress Update Evidence
expected: While playback is running or after exiting playback, backend state shows progress was saved for the movie, and the evidence is user-safe and redacted.
result: [pending]

### 4. Stop Or Exit State Evidence
expected: Stopping or exiting playback updates backend session/progress state cleanly, and returning to the app does not leave the proof path stuck in playback or loading state.
result: [pending]

### 5. Relaunch And Resume Evidence
expected: After relaunching the app and signing/restoring in, the movie reads backend progress and offers or starts resume from the saved position.
result: [pending]

### 6. Safe Failure Evidence
expected: If any proof step fails, the app or backend evidence provides only a safe error category or correlation detail and does not expose secrets, tokenized URLs, Authorization headers, filesystem paths, SQL details, stack traces, or raw subprocess output.
result: [pending]

## Summary

total: 6
passed: 1
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps

[none yet]
