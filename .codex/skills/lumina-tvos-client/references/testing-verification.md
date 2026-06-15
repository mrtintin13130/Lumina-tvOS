# Testing And Verification

## Unit Tests

- Test DTO decoding and mapping into domain/view state.
- Test URL normalization and capabilities interpretation.
- Test auth state transitions without exposing token values.
- Test redaction helpers with JWT-like strings, Authorization headers, stream tokens, HLS URLs, local paths, SQL fragments, and stack-trace-like text.
- Test playback state machines and progress throttling with fake clock/player abstractions where practical.

## UI Tests

- Add XCUITest smoke coverage for launch, setup/auth screen, Home loading/error/empty states, detail navigation, Search, and Settings.
- Give important buttons and fields stable accessibility identifiers.
- Verify focusable controls exist and primary flows are reachable by remote-like navigation where XCUITest support allows it.

## Simulator Checks

- Use simulator for build, basic navigation, decoding, view rendering, and non-DRM/non-hardware-specific playback smoke tests.
- Treat simulator media results as provisional. Record them as simulator checks, not physical playback proof.

## Physical Apple TV Checklist

- Server URL entry and login work with Siri Remote text entry.
- Home shelves load and preserve predictable focus movement.
- Detail screen actions are readable, focusable, and not clipped.
- HLS starts through AVKit from a Lumina stream token.
- Play/pause, scrub, Menu/back, subtitles/audio menus, and system overlays behave normally.
- Progress reports during playback and final stop/end reports reach the backend.
- Resume starts near the expected position.
- User-safe diagnostics contain correlation data and no secrets.

## Build Hygiene

- Use `xcodebuild -list -project lumina.xcodeproj` to confirm schemes and targets when needed.
- Use focused test commands first, then broader app/UI tests as risk grows.
- Expect CoreSimulatorService warnings in sandboxed environments; distinguish toolchain/sandbox noise from app failures.
