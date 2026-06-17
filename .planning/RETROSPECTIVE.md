# Retrospective

## Milestone: v1.2 - Stability, Usability, And Beta Hardening

**Shipped:** 2026-06-17
**Phases:** 5 | **Plans:** 20

### What Was Built

- Split session, catalog, playback, and diagnostics ownership out of the central app model while preserving SwiftUI-facing behavior.
- Hardened remote-first tvOS navigation, focus restoration, setup/search ergonomics, and unavailable placeholder actions.
- Improved playback lifecycle reliability around exit, failure cleanup, progress/session reporting, and safe diagnostics.
- Expanded Settings support context and redaction coverage without adding analytics or third-party telemetry.
- Replaced generated UI-test placeholders with deterministic tvOS smoke coverage and documented beta readiness gates.

### What Worked

- Keeping v1.2 focused on stabilization made architecture, focus, diagnostics, and verification improvements easier to reason about.
- Build-for-testing remained useful when CoreSimulatorService made simulator execution unreliable.
- Safe diagnostics and redaction tests kept support features aligned with the security constraints.

### What Was Inefficient

- GSD SDK commands were unavailable locally, so milestone state and archival required manual workflow-compatible updates.
- Some quick-task planning folders still lack SUMMARY files, making automated open-artifact audit output noisy.
- Physical Apple TV proof still depends on human/device evidence and cannot be fully closed from local automation.

### Patterns Established

- Use focused state models for session, catalog, playback, and diagnostics ownership.
- Treat physical Apple TV playback evidence as a beta confidence gate, even when local builds pass.
- Keep diagnostics support-oriented and redact aggressively before user-visible or recorded state.

### Key Lessons

- Milestone completion should run after a milestone audit file exists to avoid close-time ambiguity.
- Quick tasks should consistently write SUMMARY files when they are considered complete.
- tvOS verification needs separate tracks for local compile confidence, simulator smoke coverage, and physical-device proof.

### Cost Observations

- Model mix: not recorded.
- Sessions: multiple local planning and quick-task sessions.
- Notable: serial Xcode jobs were more reliable than parallel jobs in this environment.

## Cross-Milestone Trends

| Trend | Evidence | Next Action |
|-------|----------|-------------|
| Physical-device proof remains decisive | Playback/resume evidence is still deferred from Phase 10 and v1.2 close | Prioritize device QA before widening beta |
| Planning tool availability affects hygiene | GSD SDK unavailable during v1.2 close | Restore or reinstall local GSD SDK before next milestone |
| tvOS focus details need repeated checks | Active focus/navigation debug note remains | Include focus regression checks in next milestone scope |
