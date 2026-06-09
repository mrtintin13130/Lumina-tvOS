# Phase 13 Physical Apple TV Playback Proof

## Scope

This checklist is the required physical-device proof for playback lifecycle reliability. Local builds and test builds can prove compile-time integration and state-model behavior, but they do not prove AVKit playback on Apple TV hardware.

## Evidence Safety

Do not capture or paste JWTs, stream tokens, passwords, Authorization headers, full HLS URLs with query strings, local filesystem paths, SQL details, stack traces, or raw subprocess output.

Acceptable evidence:

- App build identifier and phase under test.
- Apple TV model, tvOS version, network type, and test date.
- Server version and capability/API contract version.
- Safe media identifier or title, media kind, and duration.
- Playback session ID when it is not a secret.
- Redacted timestamps, position seconds, play state, and correlation ID.
- Safe screenshots that do not expose secrets or private server details.

## Environment

- Date:
- Tester:
- Apple TV model:
- tvOS version:
- Lumina app build:
- Lumina server version:
- Network type:
- Test media:
- Notes:

## PLAY-21 Normal Lifecycle

| Step | Expected Result | Result | Notes |
| --- | --- | --- | --- |
| Launch app and authenticate | App reaches Home with no stale playback state |  |  |
| Start playback from the proof entry point | AVKit player appears and begins HLS playback |  |  |
| Let playback run at least 30 seconds | Progress updates occur at approximately 15 second cadence |  |  |
| Pause and resume with Siri Remote | AVKit controls respond and app remains in playback |  |  |
| Exit playback with Menu/Back | App returns Home, final progress is reported, session is stopped |  |  |
| Relaunch app and start same media | Resume position matches the last reported position within tolerance |  |  |

## PLAY-22 Backend Evidence

Record safe backend evidence for each playback attempt:

- Session ID:
- Media ID/kind:
- Initial resume position:
- Progress updates observed:
- Stop event observed:
- Final position:
- Correlation ID:
- Any discrepancy:

Expected backend pattern:

- Playback session is created before manifest playback.
- Progress reports use the current position.
- Exit maps to paused progress state.
- Exit or stopped event stops the backend session.
- A new playback attempt creates a new session instead of reusing stale client proof.

## PLAY-23 Failure Cleanup

| Scenario | Expected Result | Result | Notes |
| --- | --- | --- | --- |
| Expired token during proof/progress | App signs out or returns sign-in; no token is displayed |  |  |
| Missing playable media | App shows safe no-playable-media message; no stream token is requested |  |  |
| HLS manifest/preflight failure | Created session is stopped and safe message is shown |  |  |
| Server restart during playback | App exits or recovers without stale proof; backend session is not left active |  |  |
| Server unreachable before playback | App remains usable and shows safe connectivity state |  |  |

## PLAY-24 Audio And Subtitle Notes

Record counts only; do not add custom picker requirements for this phase.

- Backend audio track count:
- Backend subtitle count:
- Manifest audio rendition count:
- Manifest subtitle rendition count:
- AVKit visible audio/subtitle options:
- Mismatch or warning:

## PLAY-25 Cleanup State

| Check | Expected Result | Result | Notes |
| --- | --- | --- | --- |
| After normal exit | App phase is Home and playback proof is cleared after final stop |  |  |
| After playback failure | No stale proof remains and retry creates fresh proof |  |  |
| After sign-out | Tokens are cleared and playback/catalog state is reset |  |  |
| After relaunch | App does not resume phantom playback state |  |  |

## Outcome

| Area | Status | Notes |
| --- | --- | --- |
| Normal playback lifecycle | NEEDS PHYSICAL PROOF |  |
| Backend progress/session evidence | NEEDS PHYSICAL PROOF |  |
| Failure cleanup | NEEDS PHYSICAL PROOF |  |
| Audio/subtitle diagnostics | NEEDS PHYSICAL PROOF |  |
| Security/redaction | NEEDS REVIEW DURING PROOF |  |

