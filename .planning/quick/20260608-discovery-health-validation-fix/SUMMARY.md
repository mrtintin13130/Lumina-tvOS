# Discovery And Health Validation Fix

## Summary

Manual setup was rejected before capabilities validation because the client expected lowercase `ok` from `/api/v1/health`, while the Lumina API returns uppercase `OK`.

Bonjour setup could also report an unresolved address too aggressively. Discovery now retries one resolve, waits longer, and can create a server entry from resolved numeric socket addresses if `hostName` is missing.

## Verification

- `xcodebuild -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath /private/tmp/lumina-discovery-health-fix-derived-data CODE_SIGNING_ALLOWED=NO build-for-testing`
- Result: `TEST BUILD SUCCEEDED`
