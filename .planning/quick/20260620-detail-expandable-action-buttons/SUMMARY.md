---
status: complete
slug: detail-expandable-action-buttons
date: 2026-06-20
---

# Quick Task: Detail Expandable Action Buttons

Added an opt-in expandable presentation to `LuminaActionButtonStyle` so command buttons can collapse to icon-only circles and expand to their natural icon-plus-text width when focused. Existing setup, search, settings, playback, and other command buttons keep the default full-label presentation.

Applied the expandable presentation to the media detail Play/Resume, Watchlist, and Favorite actions. The buttons remain native SwiftUI `Button`/`Label` controls driven by the existing tvOS `@FocusState`, with explicit accessibility labels preserved for the collapsed visual state.

After screenshot review, removed the label-level full-width frame that made expanded buttons stretch to the available row width. Also moved the detail content width constraint from the whole hero stack to the text/details group only, so the action row can use the wider hero area while the overview remains readable.

Converted the trailer unavailable control from a static label into the same expandable focus-driven button treatment, so it remains icon-only until focused while still clearly communicating that trailer playback is not available.

Refined the collapse animation by clipping label content to the button bounds and using an opacity-only title transition, preventing text from sliding outside the capsule during focus changes.

Verification:

- Confirmed only the detail action row opts into expandable action buttons.
- Ran generic tvOS build with workspace-local DerivedData and code signing disabled:
  `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO build`
- Build succeeded. Xcode still emitted local CoreSimulatorService warnings, but they did not block the generic tvOS build.
