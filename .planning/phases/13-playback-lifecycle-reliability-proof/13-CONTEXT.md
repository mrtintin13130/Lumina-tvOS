---
phase: 13
phase_name: "Playback Lifecycle Reliability Proof"
status: complete
created_at: 2026-06-08
---

# Phase 13 Context

## Decisions

- Harden and verify playback lifecycle code locally, then create an explicit physical Apple TV evidence checklist for live-server proof.
- Prioritize client correctness around start, periodic progress, pause/exit/stop, failure cleanup, stale proof state, and resume position handling.
- Add safe client handling/tests for expired token, missing media, HLS/preflight failure, server restart/unreachable, and cleanup after failure.
- Keep audio/subtitle work to safe diagnostics and proof checklist comparison between backend tracks, HLS manifest inspection, and AVKit media-selection counts.
- Produce a dedicated physical proof artifact with safe evidence fields, pass/fail checklist, backend inspection hints, and redaction rules.

## Current Code Shape

- `AVKitPlayerView.Coordinator` starts playback on `AVPlayerItem.status == .readyToPlay`, seeks to backend resume position, reports progress every 15 seconds, and sends a final event from dismantle/end/failure.
- `AppModel.reportPlaybackProgress` reports movie progress and updates/stops playback sessions when `sessionId` exists.
- `PlaybackStateModel` owns current proof, stale proof load IDs, AVKit failure redaction, and media selection diagnostic severity.
- `PlaybackProofLoader` handles stream-token/HLS proof construction and preflight cleanup.

## Risks To Harden

- Final playback cleanup should clear stale `playbackProof` and return the app to Home after failure/exit paths.
- Progress/session failures should not leak secrets or leave the app in a misleading playback phase.
- Missing media and HLS/preflight failure need safe user-facing messages and no stale playback proof.
- Audio/subtitle diagnostics should stay counts-only and never include stream URLs or tokens.

## Physical Proof Boundary

Local builds can prove compile-time and unit-level behavior. They cannot prove HLS segment behavior, AVKit scrubbing, physical remote input, real backend persistence, audio/subtitle selection, or relaunch/resume on Apple TV hardware. Those must be captured in `13-PHYSICAL-PROOF.md`.

