---
status: completed
created: 2026-06-06
task: card-focus-style
---

# Card Focus Style

## Goal

Remove the unwanted white/gray tvOS focus plate from movie and person cards while keeping a clear remote-friendly focus state.

## Scope

- Disable the system focus effect on Home/detail poster cards.
- Disable the system focus effect on detail person cards.
- Keep custom scale, border, and shadow feedback.
- Verify tvOS build.

## Implementation

- Added `focusEffectDisabled()` to featured catalog cards, poster cards, and reusable person credit cards.
- Kept the custom tvOS focus treatment based on scale, border, z-index, and shadow.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
