---
status: completed
created: 2026-06-06
task: detail-person-shelf-right-bleed
---

# Detail Person Shelf Right Bleed

## Goal

Let movie detail person shelves scroll all the way to the right edge so focused cards can move off-screen naturally.

## Scope

- Keep the shelf title and first card aligned with the detail page left inset.
- Remove the right-side max-width constraint from person shelves.
- Preserve vertical page spacing and focus behavior.
- Verify tvOS build.

## Implementation

- Split the detail page layout so the hero and lower status content remain width-limited, while person shelves render in a full-width band.
- Kept the people shelves' left inset at 92pt, matching the detail page content.
- Removed trailing horizontal padding from the shelf `LazyHStack` so cards can continue past the right edge during horizontal navigation.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
