---
phase: 12
plan: 2
title: "Unfinished Action Hardening"
status: complete
completed_at: 2026-06-08
---

# Summary

Removed focused placeholder behavior from unfinished affordances:

- Trailer playback is now shown as unavailable information instead of a selectable action.
- Person credit cards are informational rather than tappable placeholder controls.
- Genre pills are informational rather than browse buttons.
- Logo cards backed by collection links are passive and non-focusable until collection browsing is implemented.

Movie playback and implemented detail navigation remain active.

## Verification

- Grep confirmed placeholder functions are no longer called from visible controls.
- Passed generic tvOS app build.
- Passed generic tvOS build-for-testing.

