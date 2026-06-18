---
status: complete
created: 2026-06-18
slug: bonjour-resolution-warning-fix
---

# Bonjour Resolution Warning Fix

Fix the tvOS Bonjour discovery warning and improve resolution reliability.

## Tasks

1. Remove `NetService` captures from `@Sendable` `Task` closures in discovery delegates.
2. Keep discovery state updates on the main actor.
3. Improve Bonjour resolution behavior for local/peer network service discovery.
4. Add focused unit coverage where practical and verify with generic tvOS build/test-build.
