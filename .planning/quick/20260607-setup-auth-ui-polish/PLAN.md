---
date: 2026-06-07
task: setup-auth-ui-polish
status: complete
---

# Quick Task: Setup Auth UI Polish

## Intent

Improve the production readiness of the tvOS setup, server unavailable, and sign-in screens with remote-first visual hierarchy, larger 10-foot typography, stronger focus states, and clearer connection/authentication context.

## Scope

- Refactor setup/auth screens around a shared onboarding shell.
- Add production-grade server discovery, manual entry, unavailable, and sign-in layout treatments.
- Preserve existing AppModel behavior, server validation, discovery, and auth flows.
- Keep sensitive data out of diagnostics and visible UI beyond user-entered non-secret server/account fields.

## Verification

- Ran a generic tvOS build with code signing disabled and workspace-local DerivedData.
