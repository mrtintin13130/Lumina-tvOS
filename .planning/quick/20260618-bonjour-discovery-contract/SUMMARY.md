---
status: complete
completed: 2026-06-18
slug: bonjour-discovery-contract
---

# Summary

Aligned tvOS Bonjour discovery with the backend discovery contract.

## Completed

- Discovery now ignores resolved services unless TXT `app=lumina` is present.
- Discovered servers now carry TXT `id`, `version`, `apiVersion`, `api`, `secure`, and `capabilities` hints.
- Discovered identity now prefers the stable server id hint and falls back to host and port.
- Capabilities decoding now preserves optional `server.id` and `discovery` metadata.
- The supported capabilities fixture now includes canonical discovery fields.
- tvOS local network usage copy now matches the backend docs.
- Added focused unit coverage for discovery TXT parsing and URL construction.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` succeeded.
- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` succeeded.
- `xcodebuild test ... -destination 'platform=tvOS Simulator,name=Apple TV'` could not run because CoreSimulatorService was unavailable and Xcode fell back to a non-concrete tvOS destination.
