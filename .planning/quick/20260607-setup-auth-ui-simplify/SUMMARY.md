---
date: 2026-06-07
task: setup-auth-ui-simplify
status: complete
---

# Summary

Removed the setup/auth implementation-detail right rail and simplified the screens around the user's immediate action. The setup screen now focuses on discovered servers, retry, and manual entry. The sign-in and unavailable-server screens keep only a compact current-server pill so users can confirm where they are connecting without reading technical details.

## Verification

- Attempted `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-setup-auth-simplify-derived-data CODE_SIGNING_ALLOWED=NO build`.
- The build reached Swift compilation, then local Swift frontend child processes stalled and the run was interrupted.
