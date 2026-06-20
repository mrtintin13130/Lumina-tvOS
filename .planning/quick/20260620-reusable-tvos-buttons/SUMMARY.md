---
status: complete
slug: reusable-tvos-buttons
date: 2026-06-20
---

# Quick Task: Reusable tvOS Buttons

Added shared Lumina action button primitives for command-style tvOS buttons. `LuminaActionButtonStyle` now centralizes primary, secondary, and destructive treatments with stable min widths, single-line labels, focused scale/shadow treatment, and disabled state handling. `LuminaActionRow` centralizes action-row spacing.

Migrated setup, unavailable-server, sign-in, search-submit, playback-cancel, settings, and detail-page action buttons to the shared style. Media cards and shelves remain on native card/borderless behavior.

Verification:

- Confirmed command-button call sites now use `LuminaActionButtonStyle`/`LuminaActionRow`.
- Attempted generic simulator and device tvOS builds with code signing disabled.
- Xcode reached Swift compilation for the changed files without Swift diagnostics, but local CoreSimulator/filecoordination service failures caused the builds to hang and require interruption before a clean build result.
