# Phase 14 Context

Phase 14 adds a local-only support surface in Settings and strengthens safe diagnostics for support correlation. It builds on Phase 11 state separation and Phase 13 playback lifecycle findings.

Recommended decisions accepted:

- Keep diagnostics local/support-oriented; do not add analytics, telemetry, uploads, or third-party SDKs.
- Show app/build, server/API capability summary, signed-in display name, last safe error, event count, and last support/correlation ID in Settings.
- Preserve only redacted, category-based diagnostic events suitable for support conversations.
- Expand tests for signed URLs, tokens, credentials, paths, SQL details, stack traces, and raw subprocess-like output.

