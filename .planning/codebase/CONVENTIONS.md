---
last_mapped: 2026-05-30
last_mapped_commit: unknown
focus: quality
---

# Conventions

## Summary

The repository mostly follows Xcode-generated SwiftUI conventions. There is too little handwritten application code to infer mature project-specific patterns. Future conventions should be established deliberately as the app grows beyond the starter shell.

## Swift Style Today

- Source files use standard Xcode file headers.
- Imports are placed at the top of each Swift file.
- SwiftUI view bodies are declared as computed `var body: some View`.
- XCTest files subclass `XCTestCase`.
- Braces and indentation follow Xcode defaults.

Examples:

- `lumina/luminaApp.swift` imports `SwiftUI` and declares `@main struct luminaApp: App`.
- `lumina/ContentView.swift` declares `struct ContentView: View`.
- `luminaTests/luminaTests.swift` declares `final class luminaTests: XCTestCase`.

## Naming

- The app target is lowercase `lumina`.
- The app type is currently `luminaApp`, matching the generated target name.
- The root view is `ContentView`, matching Xcode's generated SwiftUI template.
- Test case classes are lowercase-prefixed generated names: `luminaTests`, `luminaUITests`, and `luminaUITestsLaunchTests`.

As the project matures, feature and domain types should probably use standard UpperCamelCase names such as `ServerSetupView`, `AuthService`, `CatalogClient`, and `PlaybackSession`.

## File Organization

- App source currently lives directly under `lumina/`.
- Unit tests live under `luminaTests/`.
- UI tests live under `luminaUITests/`.
- Asset catalogs live under `lumina/Assets.xcassets` and `lumina/Preview Content/Preview Assets.xcassets`.
- Product requirements live at `TVOS_CLIENT_PRD.md`.

No module, feature, service, or model subdirectories exist yet.

## SwiftUI Conventions

Current SwiftUI code is minimal:

- `lumina/luminaApp.swift` uses `WindowGroup`.
- `lumina/ContentView.swift` composes a `VStack`.
- `lumina/ContentView.swift` uses SF Symbols through `Image(systemName:)`.
- `lumina/ContentView.swift` includes a `#Preview` block.

No conventions exist yet for:

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

Future conventions should centralize error mapping rather than placing raw backend or URLSession errors directly into views.

## Async And Concurrency

- No async application code exists yet.
- `TVOS_CLIENT_PRD.md` names `async/await` as part of the intended networking stack.
- Future API code should define consistent cancellation behavior for tvOS screens where focus changes and navigation can happen quickly.

## Security Conventions

`TVOS_CLIENT_PRD.md` sets several security conventions that should become coding standards:

- Store tokens only in Keychain.
- Never log JWTs, stream tokens, passwords, or Authorization headers.
- Never expose stream tokens in user-visible diagnostics.
- Avoid exposing local filesystem paths in user-facing details or diagnostics.
- Redact sensitive values before local logging.

No code enforces these rules yet.

## Networking Conventions

No networking code exists. The PRD implies future conventions:

- Use `URLSession`.
- Use `Codable` DTOs.
- Validate `/api/v1/system/capabilities` before relying on server features.
- Treat unsupported backend capabilities as explicit user-safe states.
- Keep sorting/filter choices aligned to backend-supported parameters.

## Playback Conventions

No playback code exists. The PRD implies:

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
