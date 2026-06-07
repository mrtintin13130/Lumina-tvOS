---
date: 2026-06-07
task: lumina-server-discovery
status: in-progress
---

# Quick Task: Lumina Server Discovery

## Intent

Implement local Lumina server discovery on tvOS with Bonjour, API validation, persistence, manual fallback, and launch-time handling for saved servers.

## Scope

- Add local network and Bonjour Info.plist declarations.
- Add a stable discovered-server model and Bonjour discovery service.
- Validate servers through `/api/v1/health` and the existing capabilities contract.
- Persist selected server URLs through the existing settings store.
- Update setup UI for automatic discovery, manual entry, retry, and saved-server-unavailable flows.
- Add unit tests for URL normalization and server validation.

## Verification

- Run generic tvOS build with code signing disabled.
- Run generic tvOS build-for-testing with code signing disabled.
