# Milestones

## v1.2: Stability, Usability, And Beta Hardening

**Status:** Shipped 2026-06-17
**Phases:** 11-15
**Plans:** 20/20 complete
**Requirements:** 23/23 complete
**Known deferred items at close:** 4 (see STATE.md Deferred Items)

### Delivered

- Split session, catalog, playback, and diagnostics ownership out of the central app model while preserving SwiftUI-facing behavior.
- Hardened remote-first tvOS navigation, focus restoration, setup/search ergonomics, and unavailable placeholder actions.
- Improved playback lifecycle reliability around exit, failure cleanup, progress/session reporting, and safe diagnostics.
- Expanded Settings support context and redaction coverage without adding analytics or third-party telemetry.
- Replaced generated UI-test placeholders with deterministic tvOS smoke coverage and documented beta readiness gates.

### Archives

- .planning/milestones/v1.2-ROADMAP.md
- .planning/milestones/v1.2-REQUIREMENTS.md

### Known Gaps

- uat: Phase 10 physical playback proof has 5 pending evidence checks (acknowledged at v1.2 close)
- debug: simulator-playback-stall (active debug note retained)
- debug: tvos-focus-navigation-bugs (active debug note retained)
- quick_task: 21 quick-task PLAN files without matching SUMMARY files (acknowledged planning-history gap)
