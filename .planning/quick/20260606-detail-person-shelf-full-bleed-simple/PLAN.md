---
status: completed
created: 2026-06-06
task: detail-person-shelf-full-bleed-simple
---

# Detail Person Shelf Full Bleed Simple

## Goal

Remove the remaining horizontal shelf spacing with a simple full-bleed people row.

## Scope

- Keep section titles aligned to the detail page inset.
- Remove horizontal inset from the people card row content.
- Avoid extra layout helpers or complex scroll workarounds.
- Verify tvOS build.

## Implementation

- Removed the remaining leading padding from the people shelf `LazyHStack`.
- Kept only the section title inset so labels stay aligned with the page.
- Left the shelf `ScrollView` full-width with zero horizontal scroll content margins.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
