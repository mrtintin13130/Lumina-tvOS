# Media Playback

## Player Choice

- Use `AVKit.VideoPlayer` only for simple inline preview playback.
- For full-screen Lumina playback, bridge `AVPlayerViewController` into SwiftUI with `UIViewControllerRepresentable` and keep system playback controls enabled.
- Configure `AVPlayerViewController`; do not subclass it for ordinary customization.
- Let the system player handle Siri Remote play/pause, scrubbing, subtitles/audio menus, AirPlay, Picture in Picture where available, and standard overlays.

## HLS And Stream Tokens

- Prefer backend HLS manifests for Apple TV playback.
- Build playback through `AVURLAsset`, `AVPlayerItem`, and `AVPlayer`. Do not parse HLS playlists in the app unless diagnosing a specific issue.
- Keep stream tokens short-lived, scoped, and absent from logs, UI, diagnostics, and analytics.
- Preserve direct stream compatibility elsewhere through backend behavior; do not globally change server playback behavior just for tvOS.

## Tracks And Metadata

- Prefer HLS media selection for subtitles, captions, and alternate audio.
- Load media selection groups asynchronously before showing custom track UI.
- Let `AVPlayer` honor system/user media selection preferences unless Lumina needs explicit app-level selection.
- Attach safe external metadata such as title, artwork, episode information, and description. Do not include URLs, tokens, local paths, or server internals.

## Session Lifecycle

- A typical Play action should validate auth and capabilities, request a playback/session or stream token, create the HLS URL, build the player item, present `AVPlayerViewController`, observe progress, and report stop/end events.
- Use `addPeriodicTimeObserver` or equivalent player observation for progress cadence. Throttle network reports and send a final update when playback ends or exits.
- Map playback failures into user-safe errors: unavailable stream, unsupported media, token expired, manifest failed, segment failure, subtitle/audio issue, or network timeout.
- Include a safe correlation ID with diagnostics when available so support can match client events to backend sessions.

## Physical Device Rule

- Simulator playback success is useful but insufficient. Do not claim playback reliability until HLS playback, track selection, remote controls, progress reporting, and resume are verified on a physical Apple TV.
