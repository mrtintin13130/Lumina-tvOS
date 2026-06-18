---
status: complete
completed: 2026-06-18
slug: bonjour-resolution-warning-fix
---

# Summary

Fixed Swift concurrency warnings in Bonjour discovery and improved local resolution behavior.

## Completed

- Removed `Task { @MainActor in ... }` delegate hops that captured non-Sendable `NetService`.
- Kept `NetServiceBrowserDelegate` and `NetServiceDelegate` handling on the `@MainActor` discovery object directly.
- Enabled peer-to-peer browsing/resolution.
- Increased resolve timeout and retry attempts.
- Prefer numeric resolved addresses over Bonjour hostnames when available.
- Normalize trailing DNS root dots from discovered hostnames before building URLs and display addresses.
- Added unit coverage for normalized discovered server fallback IDs and URLs.

## Verification

- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` succeeded.
- Live simulator execution remains blocked by local CoreSimulatorService.
