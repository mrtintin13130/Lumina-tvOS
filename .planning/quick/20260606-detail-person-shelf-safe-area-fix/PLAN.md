---
status: completed
created: 2026-06-06
task: detail-person-shelf-safe-area-fix
---

# Detail Person Shelf Safe Area Fix

## Goal

Restore the preferred initial left inset for person shelves while removing the persistent horizontal margins caused by the parent viewport.

## Scope

- Let the detail vertical scroll viewport ignore horizontal safe area.
- Restore the people row initial left inset.
- Keep the fix small and localized to the detail page layout.
- Verify tvOS build.

## Implementation

- Added horizontal safe-area ignoring to the detail page's vertical `ScrollView`.
- Restored the 92pt initial leading inset on people shelf rows.
- Kept the shelf title inset and zero horizontal scroll content margins.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
