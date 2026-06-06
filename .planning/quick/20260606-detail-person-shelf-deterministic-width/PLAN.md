---
status: completed
created: 2026-06-06
task: detail-person-shelf-deterministic-width
---

# Detail Person Shelf Deterministic Width

## Goal

Make person shelves stable on detail page load and avoid persistent horizontal margins while keeping the preferred initial left inset.

## Scope

- Remove safe-area ignoring from the shelf scroll views.
- Use the detail page geometry to give person shelves an explicit viewport width.
- Keep the initial people row left inset.
- Keep the change localized and avoid custom scroll engines.
- Verify tvOS build.

## Implementation

- Wrapped the detail page content in a `GeometryReader`.
- Passed the measured viewport width into the people shelf section.
- Gave each people shelf and its horizontal scroll view an explicit viewport width.
- Removed the localized horizontal safe-area ignoring from the people shelf scroll views.
- Preserved the preferred initial 92pt left inset for titles and first-row content.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- Result: passed.
