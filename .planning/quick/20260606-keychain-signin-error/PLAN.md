---
status: completed
created: 2026-06-06
task: keychain-signin-error
---

# Keychain Sign-In Error

## Bug

The simulator can surface a raw `lumina.TokenStoreError 0` message after login when the token store fails. Authentication errors must remain user-safe, and Keychain replacement should avoid fragile delete-then-add behavior.

## Scope

- Map token storage failures to a user-safe client error.
- Replace Keychain token writes with update-or-add behavior.
- Add an AppModel regression test so raw `TokenStoreError` does not appear as the sign-in status.
- Verify generic tvOS build and build-for-testing.

## Result

- `KeychainTokenStore.saveToken` now updates an existing token or adds one when absent, avoiding a fragile delete-then-add sequence.
- `TokenStoreError` now has a safe localized description.
- `AuthSessionRepository` maps token load/save failures to `LuminaClientError.secureStorageUnavailable`.
- `AppModel` sign-in regression coverage verifies raw `TokenStoreError` is not shown to the user.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build` passed.
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing` passed.
