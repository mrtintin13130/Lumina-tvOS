# Setup/Auth Screen Split Summary

Date: 2026-06-03

## Outcome

Extracted the server setup and sign-in presentation views from `ContentView.swift` into `lumina/Views/SetupScreens.swift`.

## Changed

- Moved `ServerSetupView` to `SetupScreens.swift`.
- Moved `SignInView` to `SetupScreens.swift`.
- Moved shared `ContractBadge` to `SetupScreens.swift` so settings can keep using it.
- Added `SetupScreens.swift` to the app target in `lumina.xcodeproj/project.pbxproj`.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived-setup-split CODE_SIGNING_ALLOWED=NO`
- `xcodebuild test -project lumina.xcodeproj -scheme lumina -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath /tmp/lumina-derived-setup-split-tests CODE_SIGNING_ALLOWED=NO`

Both passed.
