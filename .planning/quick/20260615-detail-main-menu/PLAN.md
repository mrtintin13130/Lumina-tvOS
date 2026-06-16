# Detail Main Menu Plan

Date: 2026-06-15

## Goal

Restore main app navigation from media detail pages without replacing the existing full-screen cinematic detail layout.

## Tasks

1. Add an app model navigation helper
   - Set the selected home tab.
   - Close detail/editorial overlays so the selected tab is visible.

2. Add a compact detail-page menu
   - Mirror Home, Movies, TV Shows, Search, and Settings.
   - Use standard SwiftUI buttons, SF Symbols, and focus behavior.
   - Keep it visually light and inside the top safe detail area.

3. Verify
   - Static sweep for new method and menu view.
   - Run compile gate as far as local Xcode allows.
