# Phase 13 Verification

## Local Verification

- PASS: `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derived-data-phase13-tests CODE_SIGNING_ALLOWED=NO build-for-testing`
- PASS: `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO -jobs 1 build`

The first plain app build retry failed with an environment-level Swift frontend spawn error. A serial retry passed without code changes.

## Coverage Added

- Playback exit preserves proof until AVKit final stop can report progress and stop the session.
- Final playback cleanup returns to sign-in when progress reporting sees expired auth.
- Missing playable media is rejected before stream-token acquisition.
- Existing preflight failure coverage confirms created playback sessions are stopped on HLS preflight failure.

## Not Locally Proven

Physical Apple TV playback remains unproven. Simulator and generic tvOS builds do not prove HLS playback, AVKit behavior, Siri Remote interaction, backend progress cadence, or audio/subtitle visibility on hardware.

Use `13-PHYSICAL-PROOF.md` for the required hardware run.

