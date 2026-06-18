---
status: complete
created: 2026-06-18
slug: bonjour-txt-address-fallback
---

# Bonjour TXT Address Fallback

Use the updated backend discovery contract where TXT records may include a LAN address.

## Tasks

1. Preserve resolved Bonjour socket addresses as the preferred endpoint.
2. Fall back to TXT `address`/`host` when Bonjour resolution does not expose a usable socket address.
3. Validate address hints conservatively before building discovered server URLs.
4. Add focused tests and run generic tvOS build-for-testing.
