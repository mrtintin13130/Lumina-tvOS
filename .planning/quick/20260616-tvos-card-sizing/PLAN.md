# tvOS Card Sizing And Focus Scale Plan

Date: 2026-06-16

## Goal

Tune tvOS media element sizing for better 10-foot readability and remove the extra artwork zoom inside focused media cards so focus uses card-level scale only.

## Scope

- Keep changes limited to SwiftUI catalog/detail/search sizing.
- Preserve existing staged hero-height work.
- Keep card dimensions stable and focus-friendly.
- Avoid backend, playback, or navigation behavior changes.

## Tasks

1. Adjust media sizing
   - Increase standard poster card dimensions and grid adaptive widths.
   - Slightly increase compact card text where it remains intentionally secondary.
   - Keep contextual hero backdrop artwork contained instead of cropped.

2. Remove inner image zoom
   - Disable the default tvOS hover highlight that zooms artwork inside custom media card buttons.
   - Keep explicit card-level scale, border, and shadow focus feedback.

3. Improve small tvOS text
   - Raise detail page menu/actions/overview and search field text closer to tvOS 10-foot guidance.

4. Refine contextual hero artwork
   - Align the contained backdrop artwork to the right side of the hero.
   - Fade the artwork in from the left so hero copy remains readable.
   - Let the backdrop artwork bleed below the hero without changing shelf layout height.

5. Verify
   - Inspect SwiftUI call sites for compile consistency.
   - Run a generic tvOS build if the local Xcode environment allows.
