# Quick Task 20260604: detail back navigation auth regression

## Goal

Fix the Apple TV remote back behavior from the media detail page so it returns to the previous catalog page instead of unexpectedly showing the login screen.

## Tasks

### 1. Make session restore idempotent

- Files: `lumina/App/AppModel.swift`
- Action: Prevent `restoreSession()` from re-running once the app has already moved past startup/setup into sign-in, home, loading, or playback states.
- Verify: Detail back navigation can pop the detail route without a root `.task` forcing auth state changes.

### 2. Build verification

- Action: Run the generic tvOS build with signing disabled.
- Verify: Build passes or document the local blocker.
