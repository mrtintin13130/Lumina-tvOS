---
phase: 06-settings-diagnostics-and-tv-ux-hardening
status: human_needed
verified: 2026-05-30
---

# Phase 6 Verification

## Result

status: human_needed

## Automated Checks

- `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-derived-data CODE_SIGNING_ALLOWED=NO`

## Delivered

- Settings surface shows server, user, validation status, revalidation, and sign-out.
- Diagnostics redaction boundary exists and is covered by unit-test build.
- UI hardening expectations are documented in `docs/tvos-feature-readiness.md`.

## Human Verification Required

- Run focus, artwork, typography, contrast, VoiceOver, Settings, diagnostics, and logout checks on a real Apple TV and simulator environment with working CoreSimulatorService.

