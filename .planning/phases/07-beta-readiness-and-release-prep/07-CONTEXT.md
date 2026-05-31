# Phase 7: Beta Readiness And Release Prep - Context

**Gathered:** 2026-05-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Prepare the TestFlight beta path: physical-device QA evidence, seed-library coverage, reviewer path, smoke checklist, privacy/App Store decisions, icon/Top Shelf asset readiness, and next-milestone deferrals.

</domain>

<decisions>
## Implementation Decisions

### the agent's Discretion
Capture beta readiness as explicit checklists and do not claim physical QA evidence until it is performed on hardware.

</decisions>

<code_context>
## Existing Code Insights

The app now builds for generic tvOS and test-builds, but simulator execution and physical Apple TV verification are not available in this environment.

</code_context>

<specifics>
## Specific Ideas

See `docs/tvos-qa-matrix.md` and `docs/testflight-beta-readiness.md`.

</specifics>

<deferred>
## Deferred Ideas

QR pairing, local discovery, household profiles, Top Shelf behavior, and platform integrations remain future work.

</deferred>
