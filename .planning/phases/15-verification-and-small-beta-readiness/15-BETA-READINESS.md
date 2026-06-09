# Phase 15 TestFlight Readiness Notes

## Reviewer Path

1. Launch the tvOS app on physical Apple TV.
2. Enter the demo Lumina server URL manually.
3. Sign in with a demo username/password account.
4. Browse Home and open a demo movie.
5. Start HLS playback, watch briefly, exit playback, and confirm the app returns safely.
6. Open Settings and confirm the support surface shows app build, server/API summary, diagnostics count, and support ID without secrets.
7. Sign out and confirm the app returns to sign-in.

## Demo Server And Media

Required before TestFlight review:

- Stable demo Lumina server reachable from reviewer networks.
- Demo account with no private user data.
- At least one movie with Apple TV-compatible HLS media.
- Optional subtitles/audio tracks only if they are known to work through AVKit.
- Backend support for capabilities, catalog, details, stream token, HLS manifest, playback session, progress, and stop paths used by the client.

## Privacy And Diagnostics

Current posture:

- No third-party telemetry.
- Client diagnostics are local and user-safe.
- Tokens are stored through Keychain-backed storage.
- JWTs, stream tokens, passwords, Authorization headers, signed URLs, local filesystem paths, SQL details, stack traces, and raw subprocess output must not appear in user-visible diagnostics.

Privacy answers still need final owner review before App Store Connect submission.

## Assets And Metadata

Needs review before beta distribution:

- App icon and Top Shelf assets.
- TestFlight beta description.
- App Store Connect privacy questionnaire.
- Screenshots or preview material based on safe demo content.

## Deferred

- QR/device pairing.
- Local server discovery polish.
- Broad TV-show playback polish.
- Custom audio/subtitle picker.
- Watchlist and favorites actions.
- Full Home/Search editorial polish.

## Blockers

- Physical Apple TV playback proof.
- TestFlight signing and provisioning.
- Demo server credentials and demo media.
- App Store privacy answers.
- Review assets and beta metadata.
