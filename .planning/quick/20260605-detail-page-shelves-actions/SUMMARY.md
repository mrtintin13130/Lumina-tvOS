---
status: complete
date: 2026-06-05
---

# Quick Task 20260605 Summary: detail page shelves and actions

## Completed

- Replaced the detail hero's reusable shelf artwork with a dedicated fill-mode backdrop so the hero image no longer appears letterboxed inside a card-like box.
- Removed the non-actionable `Ready` pill from the hero action row.
- Replaced trailer title text such as `Final Trailer` with a focusable `Trailer` button.
- Replaced the unreachable static `Details` block with Cast and Behind the Scenes shelves.
- Added flexible catalog credit decoding for direct `cast`/`crew` arrays and nested `credits.cast`/`credits.crew` detail payloads.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO build` passed.
