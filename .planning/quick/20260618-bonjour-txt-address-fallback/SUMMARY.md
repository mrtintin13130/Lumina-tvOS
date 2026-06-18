---
status: complete
completed: 2026-06-18
slug: bonjour-txt-address-fallback
---

# Summary

Implemented support for backend-published TXT `address` and `host` LAN hints.

## Completed

- Resolved Bonjour socket addresses remain preferred.
- TXT `address` is used before TXT `host` as a fallback when socket addresses are unavailable.
- `didNotResolve` can now still add a discovered server from a valid TXT LAN address instead of only showing a resolution failure.
- Address hints are trimmed and rejected if they contain whitespace.
- Added focused tests for address/host hint selection and malformed hints.

## Verification

- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` succeeded.
- Live simulator execution remains blocked by local CoreSimulatorService.
