---
date: 2026-06-07
task: editorial-banners-api-contract
status: completed
---

# Quick Task: Editorial Banners API Contract

## Intent

Align the tvOS Home catalog UI with the updated Lumina API contract for editorial cinematic banners.

## Scope

- Decode new Home/catalog metadata used by editorial banner rows.
- Fetch full editorial collections from `GET /api/v1/catalog/editorial/:sectionId`.
- Render Home cinematic banners as section-level cards, not ordinary media cards.
- Present the loaded editorial collection in a remote-friendly overlay.
- Add focused decoding/repository tests.

## Verification

- Run `xcodebuild build` for generic tvOS with code signing disabled.
- Run `xcodebuild build-for-testing` for generic tvOS with code signing disabled.
