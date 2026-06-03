---
status: complete
completed: 2026-06-03
---

# Content View Playback Detail Split Summary

Split the highest-complexity pieces out of `ContentView.swift` without changing behavior.

## Changes

- Moved `CatalogDetailOverlay`, TV season/episode detail UI, and detail badges into `lumina/Views/CatalogDetailOverlay.swift`.
- Moved the AVKit bridge and playback KVO coordinator into `lumina/Playback/AVKitPlayerView.swift`.
- Updated the Xcode project source references for the two new Swift files.
- Relaxed shared helper visibility for `CatalogShelfView`, `CatalogArtwork`, `EmptyCatalogState`, `CatalogItem` display helpers, and `StatusText` so extracted views can reuse them across files.

## Verification

- `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath /tmp/lumina-derived CODE_SIGNING_ALLOWED=NO` passed.
- `xcodebuild test -project lumina.xcodeproj -scheme lumina -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath /tmp/lumina-derived-tests CODE_SIGNING_ALLOWED=NO` passed in the escalated simulator-capable environment.
- `.xcresult` status was `succeeded` with `testsCount = 24`.

## Notes

- A duplicate quiet test rerun was interrupted after the original successful result was confirmed; it produced a cancelled `.xcresult` due to a locked build database and is not a code failure.
