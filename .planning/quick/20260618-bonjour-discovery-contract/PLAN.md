---
status: complete
created: 2026-06-18
slug: bonjour-discovery-contract
---

# Bonjour Discovery Contract

Align tvOS Bonjour/mDNS discovery with the backend API documents attached to the task.

## Tasks

1. Carry backend TXT hints through the discovery model.
   - Preserve `_lumina._tcp` browsing.
   - Ignore non-Lumina services using `app=lumina`.
   - Prefer TXT `id` as the discovered identity, falling back to host and port.
   - Preserve `api`, `capabilities`, `apiVersion`, `version`, and `secure` hints as non-authoritative metadata.

2. Keep capabilities verification authoritative.
   - Continue validating selected servers through `GET /api/v1/system/capabilities`.
   - Do not expose or store secrets from discovery.

3. Add unit coverage for discovered server URL construction and TXT-driven identity.
