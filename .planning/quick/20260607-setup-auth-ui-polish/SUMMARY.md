---
date: 2026-06-07
task: setup-auth-ui-polish
status: complete
---

# Summary

Improved the setup, server unavailable, and sign-in screens with a shared tvOS onboarding shell, larger 10-foot typography, clearer side-panel context, larger manual/auth input fields, Siri dictation guidance, and custom focus-aware buttons/cards.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /Users/martin/Documents/Developement/lumina/.derivedData CODE_SIGNING_ALLOWED=NO build`
