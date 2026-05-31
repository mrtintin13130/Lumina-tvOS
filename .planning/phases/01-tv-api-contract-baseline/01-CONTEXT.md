# Phase 1: TV API Contract Baseline - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase defines the TV-facing Lumina API contract needed before the native tvOS client starts relying on backend behavior. It delivers a route matrix, capability contract, error envelope and safe diagnostics rules, playback/progress expectations, artwork expectations, and a list of additive backend gaps with focused contract-test requirements. It does not implement the tvOS app shell, authentication UI, playback UI, or broad catalog surfaces.

</domain>

<decisions>
## Implementation Decisions

### Contract Scope And Ownership
- Create repository documentation plus focused test fixtures for route, capability, playback, progress, artwork, and error expectations.
- Keep the backend as the source of truth; tvOS consumes existing Lumina routes and asks only for additive gaps.
- Define the required `GET /api/v1/system/capabilities` response shape before the client relies on server features.
- Explicitly defer QR pairing, local discovery, household profiles, Top Shelf behavior, commercial integrations, FairPlay DRM, and offline playback.

### Capability And Compatibility Semantics
- Treat server compatibility as an explicit capabilities decision, not a best-effort collection of route probes.
- Require API version, auth modes, playback features, library feature support, diagnostics support, and route availability to be represented in safe JSON.
- Model unsupported server behavior as user-safe states the tvOS client can present before sign-in or feature use.
- Keep capability additions additive so older clients and non-TV clients are not forced through a route rewrite.

### Error And Diagnostics Contract
- Use stable machine codes, safe user-message mapping, retryability, request correlation, and optional field-level context for TV-consumed failures.
- Redact JWTs, stream tokens, passwords, Authorization headers, signed URLs, local filesystem paths, SQL details, stack traces, and raw subprocess output.
- Preserve enough diagnostics context to correlate playback failures with backend sessions without becoming monetization analytics.
- Define safe client categories for validation, auth, stream-token, manifest, segment, unsupported track, missing media, and server restart failures.

### Playback Contract Baseline
- Prefer HLS for Apple TV while preserving direct streaming behavior for other clients.
- Define how playback sessions, scoped stream tokens, HLS manifest URLs, progress cadence, completion, watched state, and resume positions fit together.
- Require focused backend contract tests or explicit test requirements for every additive gap discovered.
- Treat physical Apple TV playback proof as a later verification gate; simulator success alone is not enough.

### the agent's Discretion
The agent may choose exact file names, fixture structure, and documentation organization as long as the output is readable by a client developer and maps back to CONT-01 through CONT-04.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `TVOS_CLIENT_PRD.md` contain the source product and requirement context.
- `.planning/codebase/STACK.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`, and `.planning/codebase/CONVENTIONS.md` describe the current scaffold and intended native tvOS stack.
- The app source is still an Xcode-generated SwiftUI scaffold, so Phase 1 should mostly produce contract documentation and backend-facing test requirements.

### Established Patterns
- Planning artifacts live under `.planning/`.
- Application code currently lives directly under `lumina/`, with tests in `luminaTests/` and `luminaUITests/`.
- The project direction favors minimal third-party dependencies, native SwiftUI/AVKit/AVFoundation, Codable DTOs, async/await networking, Keychain Services, and XCTest/XCUITest.

### Integration Points
- Phase 2 will consume the Phase 1 contract when building API client, server validation, auth/session restoration, diagnostics, and setup UI.
- Phase 3 and Phase 5 will consume playback, stream-token, progress, resume, and HLS error behavior.
- Backend additive gaps should be documented so backend route tests can be added without replacing existing Lumina APIs.

</code_context>

<specifics>
## Specific Ideas

Use the PRD and requirements traceability as the source of truth. Keep the contract developer-facing and implementation-ready, with concrete route ownership and response expectations instead of vague product prose.

</specifics>

<deferred>
## Deferred Ideas

QR/device pairing, local network discovery, full household profiles, Top Shelf product behavior, Apple TV app integrations, FairPlay DRM, offline downloads, and commercial App Store entitlement work remain deferred.

</deferred>
