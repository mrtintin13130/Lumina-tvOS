---
last_mapped: 2026-05-30
last_mapped_commit: unknown
focus: arch
---

# Architecture

## Summary

The current architecture is the default Xcode SwiftUI app scaffold. It has a single app entry point, a single placeholder view, generated asset catalogs, and starter XCTest/XCUITest files. `TVOS_CLIENT_PRD.md` describes a future native tvOS client architecture, but that architecture has not been implemented yet.

## Current Runtime Shape

```text
luminaApp (@main)
  WindowGroup
    ContentView
      VStack
        SF Symbol globe
        "Hello, world!"
```

The runtime entry point is `lumina/luminaApp.swift`. `ContentView` is mounted directly with no environment objects, dependency injection, navigation stack, app state, services, repositories, or persistence layer.

## Entry Points

- App entry point: `lumina/luminaApp.swift`.
- Root view: `lumina/ContentView.swift`.
- Unit-test entry file: `luminaTests/luminaTests.swift`.
- UI-test entry files:
  - `luminaUITests/luminaUITests.swift`
  - `luminaUITests/luminaUITestsLaunchTests.swift`

## Targets

`lumina.xcodeproj/project.pbxproj` defines three native targets:

- `lumina`: tvOS app target.
- `luminaTests`: unit-test bundle depending on `lumina`.
- `luminaUITests`: UI-test bundle depending on `lumina`.

The UI-test target sets `TEST_TARGET_NAME = lumina`.

## Current Layers

There are effectively no application layers yet. Existing files map to these broad buckets:

- App shell: `lumina/luminaApp.swift`.
- View layer: `lumina/ContentView.swift`.
- Assets: `lumina/Assets.xcassets`.
- Unit tests: `luminaTests/luminaTests.swift`.
- UI tests: `luminaUITests/luminaUITests.swift` and `luminaUITests/luminaUITestsLaunchTests.swift`.
- Product requirements: `TVOS_CLIENT_PRD.md`.

## Data Flow Today

- No external data enters the app.
- No local data is persisted.
- No navigation state is represented.
- No model types are declared.
- No async work is performed.
- No errors are modeled.

## Intended Architecture Direction

`TVOS_CLIENT_PRD.md` calls for a native tvOS architecture using:

- SwiftUI app shell and screens.
- MVVM-style screens, services/repositories, and dependency injection.
- URLSession and Codable for API communication.
- Keychain-backed auth token storage.
- AVKit/AVFoundation playback.
- Diagnostics that can correlate local playback failures with backend sessions.

The PRD explicitly prioritizes a critical playback proof before broad Home/Search/TV-show polish.

## Expected Future Layering

A likely architecture, consistent with the PRD and current SwiftUI target, would separate:

- App composition in `lumina/luminaApp.swift`.
- Navigation and global session state in app-level models.
- Feature views for server setup, auth, Home, browse/search, details, playback, and settings.
- View models for remote-control-friendly screen state.
- API clients for Lumina endpoints.
- Repositories/services for auth, catalog, playback, library actions, and diagnostics.
- Secure token storage via Keychain.
- Lightweight cache via `URLCache`, `NSCache`, or local persistence if needed.

These are not implemented yet.

## Backend Boundary

The tvOS app is intended to be a client of the existing Lumina API. `TVOS_CLIENT_PRD.md` says the backend remains the source of truth for:

- Catalog composition.
- Media identity.
- Playback progress.
- Watched state.
- Watchlist and favorites.
- Stream tokens.
- HLS and direct streaming.
- Subtitles and track metadata.
- Scanner state.
- TMDB metadata.
- Diagnostics.

The client should prefer additive backend changes over route rewrites.

## Playback Boundary

Playback is planned as an AVKit boundary:

- The app should start playback sessions through backend APIs where supported.
- The app should prefer backend HLS manifests.
- The app should report progress and stop events.
- The app should preserve enough session identifiers for support diagnostics.

No playback code exists in `lumina/` yet.

## Error Handling Architecture

No error-handling architecture is implemented yet. The PRD requires:

- User-safe server validation errors.
- Auth expiration handling.
- Stream-token and HLS error mapping.
- Diagnostics without secret leakage.
- Backend error envelope compatibility.

These requirements should shape future API-client and service design.

## State Management

No state management pattern is currently visible beyond SwiftUI local view construction. Future state areas include:

- Selected server URL.
- Authentication session.
- Current user display.
- Home/catalog sections.
- Search and browse filters.
- Details and playback readiness.
- Playback session and progress cadence.
- Diagnostics and support data.

## Architectural Risks

- The scaffold has no implemented boundaries yet, so early feature work can easily concentrate too much logic in SwiftUI views.
- Playback, auth, networking, and diagnostics should be separated early because they have different testing and security needs.
- tvOS focus behavior can become fragile if screens are designed as phone-style SwiftUI views instead of remote-first layouts.
