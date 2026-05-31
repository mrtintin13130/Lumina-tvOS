# TestFlight Beta Readiness

## Required Before Beta

- Physical Apple TV QA matrix completed with evidence.
- Small seed library includes movie, episode, direct-compatible media, transcoded media, subtitles, multiple audio tracks, missing media, and expired-token scenario.
- Demo/reviewer Lumina server path is documented and stable.
- Repeatable smoke checklist exists for every build.
- Privacy decisions confirm diagnostics are support-only and not monetization analytics.
- App icon and Top Shelf image assets are reviewed at tvOS sizes.
- Known post-MVP candidates are deferred or promoted to the next milestone.

## Reviewer Path

1. Install app from TestFlight.
2. Enter demo server URL.
3. Sign in with reviewer account.
4. Validate Home loads.
5. Play a known movie.
6. Exit, relaunch, and resume.
7. Open Settings and sign out.

## Release Decisions Captured

- MVP auth remains username/password JWT.
- QR/device pairing is deferred.
- Local discovery is deferred.
- Top Shelf product behavior is deferred until Home/playback stability is proven.
- Universal Search, Siri, Apple TV app integration, subscriptions, IAP, and commercial entitlements are out of MVP.

