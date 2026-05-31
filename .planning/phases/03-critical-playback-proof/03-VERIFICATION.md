---
phase: 03-critical-playback-proof
status: human_needed
verified: 2026-05-30
---

# Phase 3 Verification

## Result

status: human_needed

## Automated Checks

- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`

## Implemented

- Minimal playable movie fetch through the API client.
- Playback session creation before launch when supported.
- Native AVKit HLS player entry from Home.
- Resume-position seek and progress reporting hook.
- Safe diagnostics capture for playback preparation/progress failures.

## Human Verification Required

- Run on a physical Apple TV.
- Validate authenticated HLS movie starts through AVKit.
- Exit playback and confirm progress reaches the backend.
- Relaunch and confirm resume position is restored.
- Confirm no JWTs, stream tokens, Authorization headers, signed URLs, local paths, SQL details, or stack traces are visible in UI or diagnostics.

## Notes

Simulator services are unavailable in this environment, and simulator success would not satisfy the roadmap's hardware proof requirement anyway.
