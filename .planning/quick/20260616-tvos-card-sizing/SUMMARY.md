# tvOS Card Sizing And Focus Scale Summary

Date: 2026-06-16
Status: Implemented, partially compiler-gated before local Xcode stall/interruption

## What changed

- Removed the shared custom media-card `.hoverEffect(.highlight)` so focused custom cards no longer apply a second artwork/image zoom on top of the explicit card scale.
- Increased standard poster cards from `220 x 330` to `250 x 375`.
- Increased compact poster cards from `172 x 258` to `190 x 285` and raised their overlay title size.
- Increased people credit cards from `206 x 384` to `220 x 410` with larger credit/person text.
- Increased movie/TV grid adaptive sizing from `220-240` to `250-270` with slightly wider spacing.
- Raised search input/search button text and detail-page overview/action/menu typography closer to tvOS 10-foot sizing.
- Changed the contextual Home hero backdrop from fill/crop behavior to contained right-aligned artwork with a left-edge fade mask.
- Let the contextual hero backdrop render 150pt taller than the hero frame so artwork can bleed beneath the shelves without pushing layout down.
- Increased the contextual hero backdrop left fade so it dissolves more forcefully over a wider portion of the image.
- Moved the contextual hero bottom fade onto the taller backdrop image layer so it stays aligned with the artwork bleed.
- Strengthened the contextual hero bottom fade and increased its maximum height for the taller artwork.
- Reduced reusable catalog/detail section title sizing to a quieter `32pt` bold style.

## Verification

- Ran `git diff --check`; no whitespace errors were reported.
- Ran `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-card-sizing-derived-data CODE_SIGNING_ALLOWED=NO`.
- The build reached Swift compilation for the changed files and produced `lumina.swiftmodule`, but the local Xcode/CoreSimulator environment entered the known stuck/interrupted state. No Swift compiler diagnostics were observed before interruption.

## Remaining follow-up

- Run a full generic tvOS build in a healthy Xcode environment.
- Check focused cards on physical Apple TV or simulator to confirm the card scales while the artwork no longer zooms independently.
