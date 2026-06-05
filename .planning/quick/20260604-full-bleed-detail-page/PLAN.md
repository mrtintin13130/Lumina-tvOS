# Quick Task 20260604: full bleed detail page

## Goal

Make the media detail screen read as a real full-screen tvOS page instead of a contained card/section.

## Tasks

### 1. Convert the hero to full-bleed

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Move the hero out of the padded content flow, remove card clipping/stroke/shadow treatment, and let the backdrop fill the first screen.
- Verify: The top of the detail page uses the full screen width and height while preserving Play/Resume focus.

### 2. Keep lower content aligned and navigable

- Files: `lumina/Views/CatalogDetailOverlay.swift`
- Action: Keep progress/status/seasons below the full-bleed hero with tvOS-safe horizontal margins.
- Verify: TV season and episode controls remain reachable and readable.

### 3. Build verification

- Action: Run the generic tvOS build with signing disabled.
- Verify: Build passes or document the local blocker.
