---
phase: 12
plan: 1
title: "Default Focus And Focus Restoration"
status: complete
completed_at: 2026-06-08
---

# Summary

Added explicit focus state and default focus targets for setup, server unavailable, sign-in, search, settings, detail, editorial, and playback loading surfaces.

`HomeShellView` now binds `TabView` selection to `AppModel.selectedHomeTab`, preserving the user's current primary tab while overlays and playback come and go.

## Verification

- Passed generic tvOS app build.
- Passed generic tvOS build-for-testing.

