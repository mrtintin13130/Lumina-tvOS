# Capabilities Contract Version Fix

## Summary

The setup flow was rejecting discovered Lumina servers because the tvOS client still required `api.version == "v1"`, while the current backend TV contract in `Lumina-API` advertises `2026-05-tv`.

## Changes

- Added `ServerCapabilities.supportedAPIVersions` with the current backend TV contract version.
- Moved API version compatibility into `ServerCapabilities.isTvMVPCompatible`.
- Removed the stale `v1` guard from `ServerConnectionTester`.
- Added a regression test covering `/health` plus a backend-compatible capabilities response.

## Verification

- Attempted generic tvOS `build-for-testing` with code signing disabled.
- The build advanced through the changed app files and emitted only existing discovery sendability warnings before stalling on a Swift compiler pass.
- The stalled build was stopped and no `xcodebuild` or Swift compiler processes were left running.
