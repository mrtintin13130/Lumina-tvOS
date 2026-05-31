# Phase 2: Native Shell, Server Setup, And Auth - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase replaces the placeholder SwiftUI scaffold with a native tvOS application shell that can validate a manually entered Lumina server, sign in with existing username/password JWT auth, restore or clear session state, and keep networking, storage, diagnostics, and UI boundaries separate. It does not need final catalog polish or physical playback proof.

</domain>

<decisions>
## Implementation Decisions

### Architecture
- Use a small MVVM-style app model as the app state coordinator.
- Keep API client, token storage, diagnostics redaction, and SwiftUI screens separate enough to test without adding third-party dependencies.
- Prefer async/await, URLSession, Codable, UserDefaults for non-secret server URL persistence, and Keychain Services for token material.
- Keep the first screen as the actual setup/auth experience, not a landing page.

### Setup And Auth UX
- Manual server URL entry remains the MVP path, with clear validation and retry states.
- Capability validation happens before sign-in so unsupported servers are explicit user-safe states.
- Username/password JWT login is the only MVP auth path.
- Sign-out clears token material and returns to setup/auth without exposing secrets.

### Error And Diagnostics
- Map backend and transport failures into safe display messages and stable categories.
- Redact tokens, Authorization headers, passwords, signed URLs, filesystem paths, stack traces, SQL, and raw subprocess output.
- Preserve support-useful context such as operation name, route key, status code, and correlation ID.
- Never log or display raw token values.

### the agent's Discretion
The agent may choose compact file boundaries appropriate for the current scaffold, as long as Phase 2 surfaces are testable and later phases can extend them.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `docs/tvos-api-contract.md` and `luminaTests/Fixtures/*.json` define Phase 1 DTO and error expectations.
- `lumina/luminaApp.swift` and `lumina/ContentView.swift` are currently the only app Swift files.
- Existing tests are generated placeholders and can be replaced with behavior tests.

### Established Patterns
- The Xcode project uses direct PBX file references rather than a generated project tool.
- tvOS target uses SwiftUI, generated Info.plist, and tvOS 17.2 deployment.
- Tests use XCTest with `@testable import lumina`.

### Integration Points
- `lumina/luminaApp.swift` is the composition point for app state and dependencies.
- `lumina/ContentView.swift` is the root view and can route between setup, auth, loading, Home, and Settings.
- Phase 3 will extend the app model and API client with playback proof.

</code_context>

<specifics>
## Specific Ideas

Keep UI remote-first: large focusable controls, clear status text, no marketing/explainer screen, and direct transitions from setup to sign-in to Home.

</specifics>

<deferred>
## Deferred Ideas

QR/device pairing, local discovery, broad catalog polish, full playback proof, and final diagnostics UI remain later phases.

</deferred>
