---
status: complete
completed: 2026-06-20
slug: first-launch-server-discovery
---

# Summary

Removed the extra first-launch setup and server-unavailable screens so pre-home auth always shows the sign-in page.

## Completed

- Restore without a saved server now returns to sign-in.
- Restore failures now return to sign-in while preserving the saved server and safe error.
- Removed the obsolete server discovery/manual-entry and server-unavailable SwiftUI screens from the rendered app surface.
- Added unit coverage for the no-saved-server restore path.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` succeeded.
- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` succeeded.
