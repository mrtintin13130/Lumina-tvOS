---
status: complete
slug: standard-tvos-card-focus
date: 2026-06-17
---

# Quick Task Summary: Standard tvOS Card Focus

## Completed

- Updated media shelf card buttons to use the shared standard tvOS borderless button style.
- Removed manual focused scale, shadow, animation, and focus-dependent strokes from media cards.
- Applied `.hoverEffect(.highlight)` to the card surfaces so tvOS can provide the built-in lift/light/motion treatment.
- Left shelves' existing `.scrollClipDisabled()` behavior in place so focused cards are not clipped.

## Verification

- `git diff --check`
- `rg -n "focusedScale|scaleEffect\\(isFocused|buttonStyle\\(\\.card\\)|buttonStyle\\(\\.borderless\\)" lumina/Views/CatalogCards.swift`
- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath ./.derivedData CODE_SIGNING_ALLOWED=NO build`
