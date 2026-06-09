# 15-01 Summary - Repeatable Build Gates

## Result

The generic tvOS app build and generic build-for-testing commands both passed with `-jobs 1`.

## Notes

Parallel Xcode jobs intermittently failed at link with `posix_spawn failed: Resource temporarily unavailable`. Retrying with serial jobs produced stable successful builds.

CoreSimulatorService emitted connection and runtime-discovery warnings throughout the run. These warnings did not block generic device build outputs, but they do block confidence in local simulator test execution.
