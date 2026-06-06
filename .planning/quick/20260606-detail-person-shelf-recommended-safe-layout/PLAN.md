---
status: completed
created: 2026-06-06
task: detail-person-shelf-recommended-safe-layout
---

# Detail Person Shelf Recommended Safe Layout

## Goal

Return the detail page people shelves to a simple tvOS-safe SwiftUI layout that does not snap on first render.

## Scope

- Remove the GeometryReader-based viewport sizing.
- Remove explicit shelf width propagation.
- Keep people shelves inside the same safe content inset as the rest of the detail page.
- Reuse the simple Home shelf structure: title, horizontal ScrollView, LazyHStack, small vertical padding.
- Verify tvOS build.

## Implementation

- Removed `GeometryReader` from the detail page root.
- Removed `viewportWidth` propagation from `DetailPeopleShelves` and `DetailPersonShelf`.
- Put people shelves back inside the detail page's normal horizontal content padding.
- Simplified `DetailPersonShelf` to match the Home shelf structure.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- Result: passed.
