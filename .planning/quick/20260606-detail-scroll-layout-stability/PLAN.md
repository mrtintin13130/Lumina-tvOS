---
status: completed
created: 2026-06-06
task: detail-scroll-layout-stability
---

# Detail Scroll Layout Stability

## Goal

Remove the initial full-bleed layout jump when opening a movie detail page.

## Scope

- Stop the whole detail page vertical scroll view from ignoring horizontal safe area.
- Keep horizontal safe-area handling localized to person shelf rows.
- Preserve the preferred initial people row inset.
- Verify tvOS build.

## Implementation

- Removed horizontal safe-area ignoring from the detail page's vertical `ScrollView`.
- Applied horizontal safe-area ignoring only to the people shelf horizontal `ScrollView`.
- Kept the 92pt initial row inset and zero horizontal scroll content margins.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
