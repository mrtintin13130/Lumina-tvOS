# Debug: tvOS Focus Navigation Bugs

**Started:** 2026-06-09
**Status:** fixed

## Trigger

Physical Apple TV can connect, but Home and detail navigation are not working well.

## Symptoms

- Home hero/banner is not full bleed.
- When the Home hero is focused, focus cannot move back to the top navigation tabs without pressing the remote back/Menu button.
- Selecting media opens a bugged detail page.
- Detail page navigation is unreliable.
- Cast/person cards on the detail page cannot be navigated.

## Expected Behavior

- Home hero should visually fill the first viewport as a full-bleed banner.
- Remote focus should move predictably between top navigation, hero, shelves, and detail controls.
- Detail pages should provide a clear default focus, navigable action row, scrollable content, and focusable cast/person cards.

## Current Focus

- completed: Inspected Home hero, tab shell, detail overlay, and card components against tvOS focus geometry rules.
- completed: Refactored Home away from a stock `TabView` chrome so the full-bleed hero and top navigation share explicit focus state.
- completed: Converted selectable catalog, shelf, logo, poster, cast, crew, season, and hero CTA surfaces to real SwiftUI `Button` controls instead of custom focusable views with tap gestures.
- completed: Added explicit detail default focus and a close/play focus bridge so the detail page always has a reachable control.

## Evidence

- Apple tvOS focus guidance says remote input indirectly moves a single focused item, and the focus engine searches visible focusable regions in the movement direction.
- Apple tvOS focus guidance notes that if no focusable view is found in the movement direction, focus stays on the current view.
- Apple tvOS focus guidance recommends preferred focus hints for initial/default focus and focus updates.
- The Home hero was a large custom focusable rectangle, so an upward move could fail to find the system `TabView` chrome from the hero's focus region.
- Cast/person cards were passive visual cards, despite being named as buttons, so the focus engine had nothing to land on.
- Movie details defaulted to Play, but non-playable/TV detail states had no reliable initial detail action. Closing depended on the remote back/Menu button.
- Catalog shelves mixed real `Button` controls with `.focusable(true)` plus `.onTapGesture`, which made selection semantics inconsistent across screens.

## Fixes

- Replaced Home `TabView` chrome with a custom top navigation bar bound to `HomeTab` and `@FocusState`.
- Made the Home hero full-bleed and non-focusable as artwork; only the "Open Details" CTA receives focus.
- Routed upward movement from the focused hero CTA back to the selected top navigation item.
- Added top padding to non-Home tabs so the owned top navigation does not overlap content.
- Added a detail close button, default focus, and play/close vertical focus bridge.
- Converted catalog cards and person cards to real `Button` controls with explicit focused styling.
- Added UI-test fixture cast/crew people and smoke assertions for person-card accessibility.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derived-data-focus-fix-tests CODE_SIGNING_ALLOWED=NO -jobs 1 build-for-testing`
- Result: passed after the Home/detail focus refactor.
- Result: passed again after converting remaining selectable card surfaces to real buttons.

## Eliminated

- Not a backend connection issue: user can connect and reach Home.
