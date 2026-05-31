<!-- GSD:project-start source:PROJECT.md -->

## Project

**Lumina Native tvOS Client**

Lumina Native tvOS Client is a first-class Apple TV app for browsing and playing a user's Lumina media library from the living room. It is a native SwiftUI, AVKit, and AVFoundation client that consumes the existing Lumina API as the source of truth for catalog, identity, playback, progress, watched state, watchlist, favorites, stream tokens, HLS/direct streaming, subtitles, track metadata, scanner state, metadata, and diagnostics.

The repository currently contains an Xcode-generated tvOS SwiftUI scaffold. The next work is to turn that scaffold into a remote-control-first media app while keeping backend changes additive and focused on the TV client contract.

**Core Value:** One authenticated Apple TV client can connect to a Lumina server, play HLS video through native AVKit on physical Apple TV, report progress, and resume reliably.

### Constraints

- **Platform**: Native tvOS / Apple TV app — the user experience must be remote-control-first and focus-driven.
- **Minimum OS**: tvOS 17+ by default — raise to tvOS 18+ only after hardware/toolchain confirmation.
- **Stack**: SwiftUI, AVKit, AVFoundation, URLSession, Codable, async/await, URLCache/NSCache, Keychain Services, XCTest/XCUITest — matches PRD and current scaffold.
- **Dependencies**: Minimal third-party dependencies — reduce platform, privacy, and App Store risk.
- **Backend compatibility**: Additive backend changes only for MVP — avoid route rewrites and API replacement.
- **Auth**: Existing username/password JWT login first — QR/device pairing is deferred.
- **Server setup**: Manual server URL entry first — local discovery is deferred.
- **Playback**: HLS-preferred on Apple TV, direct stream compatibility preserved elsewhere — align with AVKit without changing global backend behavior.
- **Verification**: Physical Apple TV playback proof required before broad Home/Search/TV-show polish — simulator success is insufficient.
- **Security**: Store tokens only in Keychain and never log or display JWTs, stream tokens, passwords, Authorization headers, local filesystem paths, SQL details, stack traces, or raw subprocess output.
- **Diagnostics**: Capture user-safe client diagnostics that can correlate with backend playback sessions — support debugging without becoming monetization analytics.
- **Repository hygiene**: `TVOS_CLIENT_PRD.md` is currently untracked and Xcode user state may need ignore rules — review before collaboration or PR preparation.

<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->

## Technology Stack

## Summary

## Languages

- Swift is the only application source language currently present.
- Project metadata is stored in Xcode `.pbxproj`, `.plist`, and asset-catalog JSON files.
- Markdown is used for product documentation in `TVOS_CLIENT_PRD.md`.

## Runtime And Platform

- Target platform: tvOS / Apple TV.
- Xcode project: `lumina.xcodeproj/project.pbxproj`.
- App target: `lumina`.
- Unit-test target: `luminaTests`.
- UI-test target: `luminaUITests`.
- SDK root: `appletvos` in `lumina.xcodeproj/project.pbxproj`.
- Deployment target: `TVOS_DEPLOYMENT_TARGET = 17.2` in `lumina.xcodeproj/project.pbxproj`.
- Targeted device family: `TARGETED_DEVICE_FAMILY = 3`, which corresponds to Apple TV.
- Swift language version: `SWIFT_VERSION = 5.0`.
- Xcode project compatibility: `compatibilityVersion = "Xcode 14.0"`.
- Created with Xcode tools version `15.2`.

## Frameworks In Use Today

- `SwiftUI` is imported by `lumina/luminaApp.swift`.
- `SwiftUI` is imported by `lumina/ContentView.swift`.
- `XCTest` is imported by `luminaTests/luminaTests.swift`.
- `XCTest` and `XCUITest` APIs are used in `luminaUITests/luminaUITests.swift` and `luminaUITests/luminaUITestsLaunchTests.swift`.

## Intended Frameworks From Product Direction

- `SwiftUI` for app shell, navigation, catalog, details, settings, loading, and error states.
- `AVKit` and `AVFoundation` for playback.
- `URLSession`, `Codable`, `async/await`, `URLCache`, and `NSCache` for networking and cache behavior.
- Keychain Services for token and credential persistence.
- `XCTest`, Swift Testing where appropriate, and XCUITest for verification.
- `AVMetrics`, `MetricKit`, and lightweight app logs for diagnostics.
- `SwiftData` or Core Data only if local state outgrows simple cache and settings storage.

## Dependencies

- No Swift Package Manager dependencies are currently declared.
- No CocoaPods, Carthage, or other package manager manifests are present.
- No third-party frameworks are linked in `lumina.xcodeproj/project.pbxproj`.
- The product direction explicitly calls for minimal third-party dependencies in `TVOS_CLIENT_PRD.md`.

## Entry Points

- `lumina/luminaApp.swift` defines the `@main` application type `luminaApp`.
- `lumina/luminaApp.swift` creates a `WindowGroup` and mounts `ContentView()`.
- `lumina/ContentView.swift` is the only current view implementation.

## Current UI Surface

- `lumina/ContentView.swift` renders a placeholder `VStack`.
- The placeholder contains `Image(systemName: "globe")`.
- The placeholder contains `Text("Hello, world!")`.
- A SwiftUI preview is declared in `lumina/ContentView.swift`.

## Build Configuration

- Generated Info.plist files are enabled with `GENERATE_INFOPLIST_FILE = YES`.
- Launch screen generation is enabled with `INFOPLIST_KEY_UILaunchScreen_Generation = YES`.
- Interface style is automatic via `INFOPLIST_KEY_UIUserInterfaceStyle = Automatic`.
- App version settings are `MARKETING_VERSION = 1.0` and `CURRENT_PROJECT_VERSION = 1`.
- Bundle identifiers:

## Assets

- Main asset catalog: `lumina/Assets.xcassets`.
- Accent color asset: `lumina/Assets.xcassets/AccentColor.colorset/Contents.json`.
- App icon and Top Shelf brand assets live under `lumina/Assets.xcassets/App Icon & Top Shelf Image.brandassets`.
- Preview asset catalog: `lumina/Preview Content/Preview Assets.xcassets`.

## Tooling

- Primary build and test tool is Xcode / `xcodebuild`.
- `xcodebuild -list -project lumina.xcodeproj` reports targets `lumina`, `luminaTests`, and `luminaUITests`, plus scheme `lumina`.
- During mapping, `xcodebuild -list` completed but emitted CoreSimulatorService and sandbox-related warnings, so simulator availability should be verified in a normal developer environment before relying on simulator tests.

## Missing Stack Pieces

- There is no networking layer yet.
- There is no persistence layer yet.
- There is no Keychain wrapper yet.
- There is no media playback implementation yet.
- There is no app architecture beyond the generated SwiftUI app and placeholder view.

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

## Summary

## Swift Style Today

- Source files use standard Xcode file headers.
- Imports are placed at the top of each Swift file.
- SwiftUI view bodies are declared as computed `var body: some View`.
- XCTest files subclass `XCTestCase`.
- Braces and indentation follow Xcode defaults.
- `lumina/luminaApp.swift` imports `SwiftUI` and declares `@main struct luminaApp: App`.
- `lumina/ContentView.swift` declares `struct ContentView: View`.
- `luminaTests/luminaTests.swift` declares `final class luminaTests: XCTestCase`.

## Naming

- The app target is lowercase `lumina`.
- The app type is currently `luminaApp`, matching the generated target name.
- The root view is `ContentView`, matching Xcode's generated SwiftUI template.
- Test case classes are lowercase-prefixed generated names: `luminaTests`, `luminaUITests`, and `luminaUITestsLaunchTests`.

## File Organization

- App source currently lives directly under `lumina/`.
- Unit tests live under `luminaTests/`.
- UI tests live under `luminaUITests/`.
- Asset catalogs live under `lumina/Assets.xcassets` and `lumina/Preview Content/Preview Assets.xcassets`.
- Product requirements live at `TVOS_CLIENT_PRD.md`.

## SwiftUI Conventions

- `lumina/luminaApp.swift` uses `WindowGroup`.
- `lumina/ContentView.swift` composes a `VStack`.
- `lumina/ContentView.swift` uses SF Symbols through `Image(systemName:)`.
- `lumina/ContentView.swift` includes a `#Preview` block.
- Navigation.
- Focus management.
- Remote-control interactions.
- Loading states.
- Error states.
- Empty states.
- Shared visual components.
- Dependency injection.

## Error Handling

- No app error handling is implemented yet.
- Generated tests use `throws` signatures, matching Xcode templates.
- `TVOS_CLIENT_PRD.md` requires user-safe errors for server validation, auth, stream tokens, HLS manifests, segment failures, unsupported tracks, and missing media.

## Async And Concurrency

- No async application code exists yet.
- `TVOS_CLIENT_PRD.md` names `async/await` as part of the intended networking stack.
- Future API code should define consistent cancellation behavior for tvOS screens where focus changes and navigation can happen quickly.

## Security Conventions

- Store tokens only in Keychain.
- Never log JWTs, stream tokens, passwords, or Authorization headers.
- Never expose stream tokens in user-visible diagnostics.
- Avoid exposing local filesystem paths in user-facing details or diagnostics.
- Redact sensitive values before local logging.

## Networking Conventions

- Use `URLSession`.
- Use `Codable` DTOs.
- Validate `/api/v1/system/capabilities` before relying on server features.
- Treat unsupported backend capabilities as explicit user-safe states.
- Keep sorting/filter choices aligned to backend-supported parameters.

## Playback Conventions

- Prefer AVKit and platform-native controls.
- Prefer HLS routes on Apple TV.
- Keep direct stream compatibility available for other clients through backend behavior.
- Record enough local playback context to correlate with backend sessions.
- Validate HLS on physical Apple TV before broad UI polish.

## Testing Conventions

- Unit tests use XCTest in `luminaTests/luminaTests.swift`.
- UI tests use XCUITest in `luminaUITests/luminaUITests.swift`.
- Launch screenshot tests use `XCTAttachment` in `luminaUITests/luminaUITestsLaunchTests.swift`.
- Test methods are currently generated placeholders and do not assert app behavior.

## Comments

- Existing comments are generated Xcode instructional comments.
- As app code grows, comments should be reserved for non-obvious behavior such as playback edge cases, security redaction decisions, and tvOS focus workarounds.

## Repository Hygiene

- `TVOS_CLIENT_PRD.md` is untracked at the time of mapping.
- `.planning/codebase/` was created by this mapping workflow.
- Xcode user state exists under `lumina.xcodeproj/project.xcworkspace/xcuserdata/.../UserInterfaceState.xcuserstate`; consider excluding user-local Xcode state if not intentionally tracked.

<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

## Summary

## Current Runtime Shape

```text

```

## Entry Points

- App entry point: `lumina/luminaApp.swift`.
- Root view: `lumina/ContentView.swift`.
- Unit-test entry file: `luminaTests/luminaTests.swift`.
- UI-test entry files:

## Targets

- `lumina`: tvOS app target.
- `luminaTests`: unit-test bundle depending on `lumina`.
- `luminaUITests`: UI-test bundle depending on `lumina`.

## Current Layers

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

- SwiftUI app shell and screens.
- MVVM-style screens, services/repositories, and dependency injection.
- URLSession and Codable for API communication.
- Keychain-backed auth token storage.
- AVKit/AVFoundation playback.
- Diagnostics that can correlate local playback failures with backend sessions.

## Expected Future Layering

- App composition in `lumina/luminaApp.swift`.
- Navigation and global session state in app-level models.
- Feature views for server setup, auth, Home, browse/search, details, playback, and settings.
- View models for remote-control-friendly screen state.
- API clients for Lumina endpoints.
- Repositories/services for auth, catalog, playback, library actions, and diagnostics.
- Secure token storage via Keychain.
- Lightweight cache via `URLCache`, `NSCache`, or local persistence if needed.

## Backend Boundary

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

## Playback Boundary

- The app should start playback sessions through backend APIs where supported.
- The app should prefer backend HLS manifests.
- The app should report progress and stop events.
- The app should preserve enough session identifiers for support diagnostics.

## Error Handling Architecture

- User-safe server validation errors.
- Auth expiration handling.
- Stream-token and HLS error mapping.
- Diagnostics without secret leakage.
- Backend error envelope compatibility.

## State Management

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

<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:

- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
