---
date: 2026-06-07
task: setup-auth-ui-simplify
status: complete
---

# Quick Task: Setup Auth UI Simplify

## Intent

Simplify the setup, unavailable-server, and sign-in screens by removing implementation-detail side panels and focusing the UI on the user's immediate remote-control action.

## Scope

- Remove setup/auth sidebar panels that describe backend/auth mechanics.
- Keep the improved tvOS typography, spacing, focus states, and larger controls.
- Preserve setup, discovery, validation, unavailable-server, and sign-in behavior.

## Verification

- Attempted a generic tvOS build with code signing disabled. Xcode reached Swift compilation, then the local Swift frontend processes stalled and the run was interrupted.
