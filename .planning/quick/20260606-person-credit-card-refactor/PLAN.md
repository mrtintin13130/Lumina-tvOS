---
status: completed
created: 2026-06-06
task: person-credit-card-refactor
---

# Person Credit Card Refactor

## Goal

Improve movie detail person cards so cast and crew shelves use a reusable, Home-inspired card treatment with clear image, primary label, and secondary label.

## Scope

- Extract a reusable person credit button/card component.
- Display cast as character/role first and actor name underneath.
- Display behind-the-scenes credits as job/department first and person name underneath.
- Keep tvOS focus feedback clear and predictable.
- Verify tvOS build.

## Implementation

- Added a reusable `PersonCreditButton` with stable tvOS card dimensions, focus scale, focus border, portrait artwork, and two-line metadata.
- Added `PersonCreditCardTextStyle` so cast cards prioritize character/role, while crew cards prioritize job/department.
- Replaced the movie detail page's local person-card implementation with the shared component.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
