# Architecture

## App Shape

- Compose the app as a SwiftUI tvOS shell with a small number of top-level destinations: setup/auth, Home, Library or Browse, Search, Settings, Detail, and full-screen playback.
- Prefer a conventional `TabView` or established project navigation shell for tvOS 17.2. Use tvOS 18 sidebar-adaptable tab APIs only after the deployment target is raised and hardware/toolchain support is confirmed.
- Map Apple sample concepts into Lumina features: `StackView` -> Home with hero plus shelves, `DescriptionView` -> MediaDetailView, `SearchView` -> first-class Search tab, `HeroHeaderView` -> reusable artwork/material header.

## Boundaries

- Keep SwiftUI screens focused on rendering and user intent. Move API calls, playback session creation, token refresh, progress reporting, and diagnostics into services/repositories.
- Use separate layers for:
  - DTOs matching Lumina API envelopes.
  - Domain models for media identity, playback availability, tracks, watched state, progress, and actions.
  - View state for shelves, hero content, detail actions, loading, empty, and user-safe error states.
- Avoid fetching directly from poster/card rows. Rows should receive already-shaped display models so focus movement does not depend on network side effects.
- Preserve stable IDs and deterministic ordering for all focusable content. Async refreshes should update content without reordering focused rows unless the user initiated a new sort/filter/search.

## State Ownership

- Keep selected server URL, auth session, capabilities, and current user in app-level session state.
- Keep feature view models responsible for screen state and cancellation. Cancel obsolete requests when focus or navigation changes makes the result stale.
- Keep playback session state separate from catalog state: stream token, AV player item, media selection, progress cadence, stop/end reporting, and safe diagnostics belong to playback services.

## tvOS Version Discipline

- Current project target is tvOS 17.2. APIs from Apple's tvOS 18 sample are useful design references but not automatic implementation choices.
- Defer or guard tvOS 18-only patterns such as `.sidebarAdaptable` and `onScrollVisibilityChange(threshold:_:)`.
- Prefer tvOS 17-compatible equivalents: `TabView`, explicit scroll state, view model booleans for above/below fold, and simpler transitions.
