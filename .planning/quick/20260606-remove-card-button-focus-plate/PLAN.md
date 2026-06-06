---
status: completed
created: 2026-06-06
task: remove-card-button-focus-plate
---

# Remove Card Button Focus Plate

## Goal

Remove the remaining tvOS white focus plate from custom movie and person cards.

## Scope

- Replace card `Button` wrappers with custom focusable tappable views.
- Keep remote click behavior through `onTapGesture`.
- Preserve custom focus scale, border, z-index, and shadow.
- Verify tvOS build.

## Implementation

- Replaced featured catalog, poster, and person card `Button` wrappers with `focusable(true)` views.
- Kept remote click behavior through `onTapGesture`.
- Preserved accessibility button traits, labels, hints, and custom focus visuals.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
