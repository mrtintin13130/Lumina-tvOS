# Phase 15 Verification

## Passed

Generic tvOS build-for-testing:

```sh
xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derived-data-phase15-tests CODE_SIGNING_ALLOWED=NO -jobs 1 build-for-testing
```

Result: passed.

Generic tvOS app build:

```sh
xcodebuild -project lumina.xcodeproj -scheme lumina -destination generic/platform=tvOS -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO -jobs 1 build
```

Result: passed after a retry.

## Earlier Attempt Notes

Without serial jobs, Xcode intermittently failed during link with `posix_spawn failed: Resource temporarily unavailable`. Serial `-jobs 1` builds resolved the local resource issue.

## Not Run

Simulator UI test execution was not run. CoreSimulatorService was unavailable in this environment and repeatedly reported connection and runtime-discovery failures.

## Residual Required Proof

Physical Apple TV playback proof is still required before the playback MVP can be considered complete.
