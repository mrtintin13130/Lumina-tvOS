---
date: 2026-06-08
task: discovery-health-validation-fix
status: complete
---

# Quick Task: Discovery And Health Validation Fix

## Intent

Fix setup reports where discovered servers cannot be resolved and manually entered Lumina API servers are incorrectly shown as unavailable for Apple TV.

## Scope

- Compare tvOS client setup validation with `Lumina-API` discovery and health contracts.
- Accept the backend's `/api/v1/health` response shape.
- Make Bonjour resolution tolerate missing `NetService.hostName` by falling back to resolved socket addresses.
- Add focused regression coverage for the validation behavior.

## Verification

- Run focused tests or generic tvOS build-for-testing if local Xcode allows it.

## Result

- `Lumina-API` inspection showed `/api/v1/health` returns `status: "OK"`, `app: "Lumina"`, and `version: "1.0.0"`.
- Updated setup validation to accept the backend health status case-insensitively.
- Hardened Bonjour discovery by retrying one failed resolve, using a longer timeout, and falling back to numeric socket addresses when `NetService.hostName` is unavailable.
- Added regression coverage for uppercase health status and numeric IPv4 address extraction.
- Verified with generic tvOS `build-for-testing` and code signing disabled.
