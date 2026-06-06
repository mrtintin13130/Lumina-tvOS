---
status: completed
created: 2026-06-06
task: detail-person-shelf-edge-to-edge-scroll
---

# Detail Person Shelf Edge-To-Edge Scroll

## Goal

Make movie detail person shelf scroll viewports reach the screen edges so cards clip at the physical left/right edges while navigating.

## Scope

- Remove the parent left padding from the shelf viewport.
- Keep section titles visually aligned with the detail page inset.
- Keep the first card aligned at rest through scroll content inset only.
- Remove any automatic horizontal scroll content margin where possible.
- Verify tvOS build.

## Implementation

- Removed the parent `DetailPeopleShelves` leading padding so horizontal shelf viewports span the full screen width.
- Moved the 92pt inset to shelf titles and scroll content start only.
- Added zero horizontal scroll content margins for the people shelf scroll views.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
