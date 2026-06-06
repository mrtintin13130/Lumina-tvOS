---
date: 2026-06-07
task: api-driven-home-section-layouts
status: completed
---

# Quick Task: API-Driven Home Section Layouts

## Intent

Render every Home shelf from `presentation.layout` instead of section ids, and make poster-based rows such as Recent Movies use portrait media cards when the API returns `poster_rail`.

## Scope

- Expand Home layout mapping to cover current catalog presentation layouts.
- Add explicit compact poster, logo card, and continue-watching landscape variants.
- Keep `spotlight_rail` as larger landscape cards and `cinematic_banner` as a wide editorial banner.
- Add tests for layout selection behavior.

## Verification

- Run generic tvOS build with code signing disabled.
- Run generic tvOS build-for-testing with code signing disabled.
