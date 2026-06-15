# Networking, Auth, And Security

## Networking

- Use `URLSession`, `Codable`, async/await, and explicit endpoint clients.
- Validate the selected server URL before login and normalize it conservatively.
- Query `/api/v1/system/capabilities` before relying on optional TV, HLS, scanner, metadata, or diagnostics features.
- Keep sorting, filtering, pagination, and search aligned with backend-supported parameters.
- Use user-safe error envelopes in the UI. Avoid raw status dumps or backend internals.

## Auth

- Implement existing username/password JWT login first. QR/device pairing remains deferred unless the product plan changes.
- Store tokens only in Keychain. Use simulator-only fallbacks only when clearly labeled and excluded from production paths.
- Handle token expiration centrally. Retry only when safe and idempotent, and route the user back to sign-in when refresh cannot recover.
- Never display, log, print, attach, or include JWTs, passwords, stream tokens, Authorization headers, or tokenized media URLs.

## Diagnostics

- Diagnostics should help correlate playback and API problems without becoming monetization analytics.
- Redact secrets before logs, errors, attachments, and support payloads leave the component that observed them.
- Do not expose local filesystem paths, SQL details, stack traces, subprocess output, private IP-sensitive details beyond what the user explicitly entered, or raw backend responses.
- Prefer safe fields: app version, tvOS version, device family, server capability version, endpoint category, HTTP status class, correlation/session ID, media type, playback phase, and sanitized error code.

## Backend Compatibility

- Keep backend changes additive for MVP.
- Avoid route rewrites, response replacement, and global stream behavior changes.
- Treat unsupported capabilities as explicit states in the TV app: unsupported server, sign-in required, playback unavailable, HLS unavailable, metadata unavailable, scanner unavailable, or diagnostics unavailable.
