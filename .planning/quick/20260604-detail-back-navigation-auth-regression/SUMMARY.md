---
status: complete
date: 2026-06-04
---

# Quick Task 20260604 Summary: detail back navigation auth regression

## Completed

- Made `AppModel.restoreSession()` idempotent after startup/setup so a repeated SwiftUI root `.task` cannot move an active Home/detail/playback session back to sign-in.
- Kept catalog detail navigation state unchanged: the remote back action should now pop the detail route and leave the app in Home/catalog state.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO build` passed.
