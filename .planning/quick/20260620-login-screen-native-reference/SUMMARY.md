# Summary

Adapted the auth screen toward the provided cinematic login reference while keeping native SwiftUI controls and tvOS focus handling.

## Verification

- `git diff --check`
- `plutil -lint lumina/en.lproj/Localizable.strings lumina/fr.lproj/Localizable.strings`
- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO` reached Swift compilation but failed at asset catalog compilation because the local CoreSimulator service cannot locate the tvOS 17.2 simulator runtime.
