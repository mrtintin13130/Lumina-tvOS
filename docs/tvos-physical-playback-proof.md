# tvOS Physical Movie Playback Proof

**Status:** Ready for user-run hardware validation

This checklist proves the v1.1 movie playback loop on a physical Apple TV against a live Lumina server. Do not capture JWTs, stream tokens, Authorization headers, tokenized URLs, local filesystem paths, SQL details, stack traces, raw subprocess output, or private server data.

## Setup

- Build and install the tvOS app on a physical Apple TV.
- Use a live Lumina server with `GET /api/v1/system/capabilities` enabled.
- Confirm the server has at least one playable movie with HLS support.
- Keep backend admin/debug views available only for safe, redacted observations.

## Proof Steps

| Step | Expected result | Safe evidence |
|------|-----------------|---------------|
| Validate server | App accepts the server and proceeds to sign-in. | Screenshot of success state or notes with server version/API version only. |
| Sign in | Password JWT login succeeds and current user displays. | Screenshot with no credentials visible. |
| Start proof | Home "Playback Proof" fetches one playable movie and opens AVKit. | Photo/video of title and player starting. |
| Session create | Backend has a playback session ID for the movie. | Redacted backend record showing session ID, media ID, media type, state. |
| HLS start | Physical Apple TV plays movie HLS. | Short video/photo of playback, no tokenized URL. |
| Progress update | Backend progress advances during playback or on exit. | Redacted backend progress record with movie ID, position, duration/state. |
| Exit/stop | Leaving playback records safe progress/session stop. | App returns Home; backend session/progress state updates. |
| Relaunch/resume | Relaunch restores session and proof playback resumes from backend progress. | Photo/video plus redacted progress record. |

## Failure Recording

For any failure, record:

- Operation: setup, auth, catalog movie, session create, stream token, HLS manifest, HLS segment, progress, stop, relaunch/resume.
- Safe error category/code/message if available.
- Whether retry worked.
- Redacted backend correlation ID or playback session ID if available.
- Follow-up owner: client, backend, hardware environment, or unknown.

## Completion Rule

Phase 10 passes only after physical Apple TV proof confirms HLS start, progress update, exit/stop, relaunch, and resume. Simulator or no-sign build success is not enough.
