---
date: 2026-06-07
task: home-hero-full-width
status: completed
---

# Quick Task: Home Hero Full Width

## Intent

Make the Home hero slider artwork fill the screen width without black side borders and behave predictably with the Siri Remote.

## Scope

- Keep the Home hero carousel at a 16:9 aspect ratio.
- Let the hero width drive its height instead of pinning the height to a smaller fixed value.
- Keep the Home page top safe area so remote Up can move from the hero toward the app menu.
- Let remote Left/Right move to the previous or next hero slide while the hero has focus.
- Preserve fixed-ratio rendering for poster, card, and shelf artwork.

## Verification

- Run a generic tvOS build with code signing disabled.
