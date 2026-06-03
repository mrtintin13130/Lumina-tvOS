# Quick Task: setup-auth-screen-split

## Goal

Extract setup and sign-in presentation from `ContentView.swift` while preserving the existing app phase routing and behavior.

## Tasks

1. Move `ServerSetupView`, `SignInView`, and shared `ContractBadge` into `lumina/Views/SetupScreens.swift`.
2. Update Xcode project source references.
3. Verify with generic tvOS build and simulator tests.
