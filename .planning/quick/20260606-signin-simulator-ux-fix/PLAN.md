---
status: completed
created: 2026-06-06
task: signin-simulator-ux-fix
---

# Sign-In Simulator UX Fix

## Scope

- Add app Keychain entitlement so tvOS simulator/device sign-in can store JWTs through Keychain.
- Rename sign-in input state and copy from username to email.
- Show an explicit loading state while the login request is in flight.
- Update regression tests and verify generic tvOS build/build-for-testing.

## Result

- Added `lumina/lumina.entitlements` with a Keychain access group and wired it to the app target Debug/Release settings.
- Renamed the sign-in state from `username` to `email`, updated the login protocol/repository naming, and kept the backend payload as `email`.
- Updated the sign-in screen placeholder/content type/keyboard type to Email.
- Added visible sign-in loading feedback with disabled fields/actions and a `ProgressView` while `AppPhase.signingIn` is active.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build` passed.
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing` passed.
