---
status: complete
date: 2026-06-05
---

# Quick Task 20260605: detail page shelves and actions

## Goal

Make the tvOS media detail page feel less like a static hero and more like a navigable Apple TV media page.

## Scope

- Remove remaining hero artwork letterboxing by using a fill-style backdrop view.
- Remove the non-actionable `Ready` pill.
- Rename trailer copy to `Trailer` and make it a focusable action.
- Replace the unreachable `Details` block with horizontal person shelves for cast and behind-the-scenes crew where the catalog detail payload provides credits.
- Keep changes focused to the detail page and catalog detail DTO decoding.

## Verification

- Passed: `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO build`
