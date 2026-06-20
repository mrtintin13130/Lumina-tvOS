---
status: complete
slug: profile-browse-background
date: 2026-06-20
---

# Quick Task: Profile Browse Background

Made the existing Movies and TV Shows browse background reusable and applied it behind the Profile tab. Profile keeps its current layout and actions, but no longer overrides the tab with a flat black background.

Verification:

- Confirmed Profile now uses `CatalogBrowseBackground`, the same view used by the shared Movies and TV Shows `CatalogGridView`.
- Attempted generic tvOS simulator and device builds with code signing disabled.
- Both builds were blocked by local Xcode/CoreSimulator asset catalog failures: `actool` could not locate the tvOS 17.2 simulator runtime and CoreSimulatorService was unavailable. No source-level diagnostic was emitted for the Profile background change.
