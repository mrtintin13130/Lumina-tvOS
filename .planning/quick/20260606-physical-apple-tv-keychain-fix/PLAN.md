---
status: completed
created: 2026-06-06
task: physical-apple-tv-keychain-fix
---

# Physical Apple TV Keychain Fix

## Goal

Fix sign-in on physical Apple TV when token persistence reports secure storage unavailable.

## Scope

- Remove unnecessary explicit Keychain access-group entitlement.
- Keep token persistence in Keychain on physical Apple TV.
- Split Keychain query attributes from add-only attributes.
- Keep simulator fallback behavior unchanged.
- Verify tvOS build.

## Implementation

- Removed the explicit `keychain-access-groups` entitlement because the app does not share Keychain items with another target.
- Kept physical Apple TV token storage backed by Keychain only.
- Moved `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` to the `SecItemAdd` item attributes instead of including it in every lookup/update/delete query.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- Result: passed.
