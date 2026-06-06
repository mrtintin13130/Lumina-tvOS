---
status: completed
created: 2026-06-06
task: person-card-size-tweak
---

# Person Card Size Tweak

## Goal

Slightly increase person credit card size on detail shelves for better tvOS readability and focus presence.

## Scope

- Increase reusable `PersonCreditButton` width and height modestly.
- Keep text styling and card behavior unchanged.
- Verify tvOS build.

## Implementation

- Increased `PersonCreditButton` from 190x356 to 206x384.
- Increased profile artwork height from 254 to 276.
- Left typography, focus scale, and card behavior unchanged.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO build`
- Result: passed.
