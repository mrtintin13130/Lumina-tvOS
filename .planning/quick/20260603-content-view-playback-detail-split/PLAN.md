# Quick Task: content-view-playback-detail-split

## Goal

Split the logic-heavy detail overlay and AVKit playback bridge out of `lumina/ContentView.swift` without changing app behavior.

## Tasks

1. Extract `CatalogDetailOverlay`, TV season/episode detail UI, and detail badges into `lumina/Views/CatalogDetailOverlay.swift`.
2. Extract `AVKitPlayerView` into `lumina/Playback/AVKitPlayerView.swift`.
3. Update Xcode project source references and run the existing unit/UI test suite.
