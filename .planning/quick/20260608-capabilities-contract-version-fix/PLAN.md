---
date: 2026-06-08
task: capabilities-contract-version-fix
status: complete
---

# Quick Task: Capabilities Contract Version Fix

## Intent

Fix setup validation incorrectly rejecting current Lumina API servers as unsupported for Apple TV.

## Scope

- Compare tvOS client validation against `/Users/martin/Documents/Developement/Lumina-API` system capabilities.
- Update client validation to accept the current TV contract version advertised by the backend.
- Add focused tests so `ServerConnectionTester` accepts a `2026-05-tv` capabilities response and still rejects non-TV capability payloads.

## Verification

- Run focused tests or a generic tvOS test/build command if the local Xcode environment allows it.

## Result

- Backend inspection found the current Lumina API TV contract advertises `api.version` as `2026-05-tv`, not `v1`.
- Updated setup validation to accept Lumina servers by name and validate TV compatibility through the capabilities contract.
- Added a regression test proving `ServerConnectionTester` accepts the backend TV contract version.
- Attempted `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-capabilities-fix-derived-data CODE_SIGNING_ALLOWED=NO build-for-testing`; local Swift compilation advanced through the changed app files but stalled on a long compiler pass and was stopped cleanly.
