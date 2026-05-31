# tvOS Physical QA Matrix

Physical Apple TV verification is required before beta readiness is real.

| Area | Scenario | Evidence |
|------|----------|----------|
| HLS movie | Start, pause, scrub, exit, relaunch, resume | Video/photo plus backend progress record |
| HLS episode | Start, pause, scrub, exit, relaunch, resume | Video/photo plus backend progress record |
| Direct-compatible media | Confirm Apple TV still uses supported HLS/preferred path | Playback note |
| Transcoded media | Confirm manifest/segments load and buffering is acceptable | Playback note |
| Embedded subtitles | Select and render supported subtitle track | Video/photo |
| External subtitles | Select and render supported external subtitle track | Video/photo |
| Multiple audio tracks | Select alternate audio where supported | Video/photo |
| Missing media | Safe non-playable/error state, no local paths | Screenshot |
| Expired stream token | Safe retryable error and no token display | Screenshot/log excerpt with redaction |
| Server restart | Safe playback failure/recovery state | Notes |
| Buffering | Native AVKit behavior remains usable | Notes |
| Memory | Long browse/playback session does not terminate unexpectedly | Notes |
| Long playback | Progress cadence and completion/watched state remain correct | Backend progress record |

## Smoke Checklist

- Manual server setup validates capabilities.
- Password JWT sign-in succeeds.
- Session restores after relaunch.
- One movie starts through AVKit on physical Apple TV.
- Progress updates while playing and on exit.
- Resume works after relaunch.
- Settings sign-out clears token material.
- Diagnostics remain redacted.

