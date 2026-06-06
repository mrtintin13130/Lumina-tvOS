---
status: partial_completed
created: 2026-06-06
task: stability-roadmap-execution
---

# Stability Roadmap Execution

## Todo List

- [x] Add an auth/session layer so restore, sign-in, sign-out, server validation, capabilities, and current user are not spread across `AppModel`.
- [x] Treat HTTP 401/403 as an expired session and clear the stored token before returning to sign-in.
- [x] Add `AppModel` flow tests with fake API and in-memory settings/token stores.
- [x] Add stale-load/cancellation guards for search and detail flows so fast Siri Remote navigation cannot publish old data.
- [x] Keep expanding safe diagnostics as structured events, without tokens or backend internals.
- [x] Configure/cache networking intentionally with stable timeouts and URL cache policy.
- [x] Expand backend contract fixtures for auth expiration, no playable media, stream token expiry, and progress/session payloads.
- [ ] Prepare a physical Apple TV QA matrix for focus, Menu navigation, playback, progress, resume, and network instability.
- [ ] Keep tvOS focus defaults and focus memory explicit on every screen.
- [ ] Wire episode playback after movie proof is reliable.

## Current Execution Slice

- Auth/session extraction.
- 401/403 session expiration handling.
- `AppModel` flow tests.
- Search/detail stale-load guards.
- Generic tvOS build and test-build verification.

## Notes

- `gsd-sdk` is unavailable in this environment, so this file is the manual quick-task trace.
- Existing uncommitted changes are treated as user work and must not be reverted.

## Result

- Added `AuthSessionRepository` to own server validation, sign-in, restore, token lookup, and sign-out behavior.
- Mapped HTTP 401/403 to a session-expired app state and clear stored credentials before returning to sign-in.
- Reduced `AppModel` auth/network responsibilities and added central session-error handling.
- Added load identifiers for search and detail flows so stale async results cannot overwrite newer tvOS navigation state.
- Added unit-test coverage for HTTP session expiry and AppModel sign-in/restore flows using fake API clients and in-memory stores.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build` passed.
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing` passed.
- Simulator test execution is still blocked in this environment by CoreSimulatorService availability, so physical Apple TV and normal local simulator validation remain required.
