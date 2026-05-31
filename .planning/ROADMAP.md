# Roadmap: Lumina Native tvOS Client v1.1

## v1.1 Backend Contract Alignment And Hardware Playback Proof

## Overview

This roadmap turns the endpoint inventory in `rest-client/` and the implemented capabilities endpoint into the concrete contract the native tvOS client calls. It deliberately narrows the milestone around the highest-risk loop from the audit: live server sign-in, playable movie selection, playback session creation, tokenized HLS through AVKit on physical Apple TV, progress reporting, stop, relaunch, and resume.

## Phases

**Phase Numbering:**

- Integer phases (8, 9, 10): Planned v1.1 milestone work continuing from the previous roadmap.
- Decimal phases (8.1, 8.2): Urgent insertions if needed.

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 8: Backend Contract Reconciliation** - Reconcile the implemented capabilities response and `rest-client/` endpoint inventory with the tvOS client contract before changing playback code. (completed 2026-05-30)
- [x] **Phase 9: Real API Client Alignment** - Update Swift networking, DTOs, request payloads, and tests to call the real Lumina endpoints for the proof path. (completed 2026-05-30)
- [ ] **Phase 10: Physical Movie Playback Proof** - Prove movie HLS playback, progress, stop, relaunch, and resume on physical Apple TV against a live Lumina server.

## Phase Details

### Phase 8: Backend Contract Reconciliation

**Goal**: A developer can implement the tvOS proof path without guessing route keys, payload names, token transport, or safe error semantics.
**Mode:** mvp
**Depends on**: v1.0 audit and `rest-client/` endpoint inventory
**Requirements**: [CONT-05, CONT-06, CONT-07, CONT-08, CONT-09]
**Success Criteria** (what must be TRUE):

  1. The tvOS contract document lists the real v1.1 route keys and payload shapes consumed by setup, auth, catalog movie proof, stream token, HLS, playback sessions, progress, and safe errors.
  2. The implemented capabilities response is represented by fixtures or documentation sufficient for client compatibility tests.
  3. Token transport for AVKit HLS is explicit for manifests, playlists, segments, and subtitles.
  4. Any backend gaps are captured as additive contract items with owner, route, and test expectation.

**Plans**: 3 plans

Plans:

- [x] 08-01: Compare `rest-client/` endpoints, capabilities response, and existing tvOS contract; produce the reconciled route matrix.
- [x] 08-02: Define playback session, progress, watched, stream-token, HLS, and error payload contracts for the proof loop.
- [x] 08-03: Add or update contract fixtures/tests/docs for capabilities and proof-path backend behavior.

### Phase 9: Real API Client Alignment

**Goal**: The tvOS app's networking layer uses the real Lumina endpoint shapes for setup/auth/catalog/playback proof instead of placeholder proof calls.
**Mode:** mvp
**Depends on**: Phase 8
**Requirements**: [API-01, API-02, API-03, API-04, API-05, API-06, API-07]
**Success Criteria** (what must be TRUE):

  1. Server validation decodes the implemented capabilities response and gates only truly unsupported servers.
  2. Auth restore, playable catalog movie selection, playback session create/update/stop, stream-token handling, and movie progress save/read all use the real route and JSON shapes.
  3. Diagnostics and errors redact JWTs, stream tokens, Authorization headers, signed URLs, filesystem paths, SQL details, stack traces, and raw subprocess output.
  4. Unit tests cover request construction, DTO decoding, compatibility gating, payload naming, progress/resume behavior, token URL redaction, and safe error mapping.

**Plans**: 4 plans

Plans:

- [x] 09-01: Align capabilities, auth, and catalog movie DTOs plus fixtures with the real backend responses.
- [x] 09-02: Align playback session and progress client calls with real payloads and route families.
- [x] 09-03: Implement stream-token-aware movie HLS URL construction and diagnostic redaction.
- [x] 09-04: Add focused unit tests for the proof path and run generic tvOS build/test-build.

### Phase 10: Physical Movie Playback Proof

**Goal**: A physical Apple TV can play one movie through HLS, report progress, stop cleanly, relaunch, and resume from backend state.
**Mode:** mvp
**Depends on**: Phase 9
**Requirements**: [PLAY-11, PLAY-12, PLAY-13, PLAY-14, PLAY-15, VER-01, VER-02, VER-03, VER-04]
**Success Criteria** (what must be TRUE):

  1. User can sign in to a live Lumina server, select a playable catalog movie, and enter playback with a backend playback session ID.
  2. AVKit starts HLS playback on physical Apple TV using the backend-supported token or authorized manifest path.
  3. Progress/session updates are visible in backend state during playback and after exit.
  4. Relaunch/session restore reads backend progress and offers or starts resume from the saved position.
  5. Safe evidence is captured for hardware playback, progress, resume, and any failure cases without exposing secrets or private backend details.

**Plans**: 3 plans

Plans:

- [x] 10-01: Build the proof playback screen/state path from playable catalog movie to AVKit player.
- [ ] 10-02: Execute physical Apple TV movie playback, progress, exit, stop, and relaunch/resume verification.
- [ ] 10-03: Record proof evidence, backend observations, diagnostics review, and follow-up gaps.

## Progress

**Execution Order:**
Phases execute in numeric order: 8 -> 9 -> 10

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 8. Backend Contract Reconciliation | 3/3 | Complete    | 2026-05-30 |
| 9. Real API Client Alignment | 4/4 | Complete   | 2026-05-30 |
| 10. Physical Movie Playback Proof | 1/3 | In Progress|  |
