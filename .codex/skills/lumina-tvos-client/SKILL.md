---
name: lumina-tvos-client
description: Use when building or reviewing the Lumina native tvOS client, including SwiftUI Apple TV catalog screens, focus-first remote navigation, media lockups and shelves, AVKit/HLS playback, Lumina API integration, Keychain authentication, diagnostics, Top Shelf, and tvOS XCTest/XCUITest or physical-device verification.
---

# Lumina tvOS Client

## Core Workflow

1. Preserve the Lumina backend contract. Keep backend changes additive, validate server capabilities before using optional features, and avoid rewriting existing API behavior for the TV client.
2. Design every screen for Apple TV first: focus-driven navigation, Siri Remote input, 10-foot readability, stable spatial layouts, and low text-entry cost.
3. Keep SwiftUI views thin. Shape network DTOs into domain models, then into screen view state through services, repositories, and view models.
4. Prefer standard tvOS components where they carry platform behavior: SwiftUI `Button` lockups, `.buttonStyle(.borderless)` or `.buttonStyle(.card)`, `TabView`, `.searchable`, and AVKit playback UI.
5. Treat playback as a separate boundary. Prefer HLS on Apple TV, use `AVPlayerViewController` for full-screen playback, report progress safely, and never log tokens or media URLs.
6. Verify claims at the right level: unit-test state and mapping logic, XCUITest app flows, and require physical Apple TV evidence before declaring playback reliable.

## Load References

- Read `references/architecture.md` for app composition, feature boundaries, state ownership, and tvOS 17 versus tvOS 18 decisions.
- Read `references/focus-ui.md` for lockups, shelves, focus routing, Search, Top Shelf, safe areas, and 10-foot UI rules.
- Read `references/media-playback.md` for AVKit, HLS, subtitles/audio tracks, progress reporting, and remote playback behavior.
- Read `references/networking-auth-security.md` for Lumina API boundaries, URLSession/Codable, Keychain, capabilities validation, redaction, and diagnostics.
- Read `references/testing-verification.md` for unit, UI, simulator, and physical Apple TV verification guidance.
- Read `references/apple-docs.md` for official Apple documentation links and which pages to consult for a task.

## Implementation Defaults

- Target tvOS 17.2 unless the project owner explicitly raises the deployment target. Gate or avoid tvOS 18-only APIs such as `.sidebarAdaptable` and `onScrollVisibilityChange(threshold:_:)`.
- Use `ScrollView(.horizontal)` plus `LazyHStack` for browse shelves, with `.scrollClipDisabled()` and a single button style per shelf.
- Use `Button` for media cards instead of manually focusable custom views unless a custom focus interaction is truly required.
- Use `@FocusState` with unique `Hashable` enum cases for programmatic focus. Use `defaultFocus` for entry points and `focusSection()` to guide movement between hero/header regions and shelves.
- Keep image-heavy surfaces stable: deterministic ordering, fixed aspect ratios, predictable spacing, and no focus jumps caused by async reloads.
- Keep user-facing diagnostics safe. Never expose JWTs, stream tokens, passwords, Authorization headers, raw HLS URLs, local filesystem paths, SQL details, stack traces, or raw subprocess output.

## Review Checklist

- Does focus have a visible state, a default destination, predictable movement, and return memory?
- Do shelves allow focus lift without clipping or overlapping titles?
- Are long descriptions, errors, and setup forms readable from across the room?
- Is playback using AVKit/AVFoundation behavior rather than reimplementing system controls?
- Are tokens stored only in Keychain and redacted from logs, errors, and diagnostics?
- Are tvOS 18 APIs avoided or guarded while the project target remains tvOS 17.2?
- Are simulator results not overstated as physical Apple TV playback proof?
