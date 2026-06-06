---
status: completed
created: 2026-06-06
task: simulator-tokenstore-fallback
---

# Simulator Token Store Fallback

## Bug

The tvOS simulator still reports secure storage unavailable after adding app Keychain entitlements. Device builds must remain Keychain-backed, but simulator testing needs a non-persistent fallback so login, catalog, and playback proof can be exercised.

## Scope

- Add a fallback token store that can use memory when the primary Keychain store fails.
- Use that fallback only when compiling for simulator.
- Keep physical Apple TV/device builds using Keychain only.
- Add regression coverage for primary failure + fallback token behavior.
- Verify generic tvOS build and build-for-testing.

## Implementation

- Added `TokenStoreFactory.defaultStore()` so simulator builds wrap `KeychainTokenStore` in a fallback token store.
- Added `FallbackTokenStore`, which switches to an in-memory store only after the primary store fails.
- Kept physical Apple TV builds on `KeychainTokenStore` only.
- Added regression coverage for save/load/clear behavior when the primary token store fails.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build-for-testing`
