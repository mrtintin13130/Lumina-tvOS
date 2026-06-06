---
status: complete
created: 2026-06-06
---

# AVKit Media Selection

## Goal

Wire Lumina tvOS playback to use AVKit's native audio and subtitle selection from HLS media selection groups, and add lightweight client-side track contract support for backend diagnostics.

## Scope

- Decode Lumina playback track listings for movies.
- Fetch movie track listings during playback proof load when available.
- Carry the listing into playback proof for diagnostics and future UI.
- Inspect AVAsset audible and legible media selection groups when the player item becomes ready.
- Record safe playback diagnostics about available native audio/subtitle options.

## Verification

- Build or test the tvOS target with `xcodebuild` if the local simulator/toolchain allows it.
- Keep tokenized URLs and sensitive values out of diagnostics.

## Result

- Added movie track listing DTOs and API client support.
- Playback proof now carries optional backend track listings without failing playback when the endpoint is unavailable.
- AVKit playback now inspects native audible and legible media selection groups once the item is ready.
- Diagnostics record safe counts for native AVKit options and backend track listings.
- Added HLS manifest inspection so diagnostics can compare backend track listings, HLS audio/subtitle renditions, and native AVKit media selection groups.
- Flagged non-playlist subtitle renditions because AVKit may not expose raw subtitle file URIs as native subtitle choices.
- Updated `Lumina-API` HLS external WebVTT subtitles to advertise playlist rendition URIs and serve the WebVTT file through the HLS subtitle segment route.
- Normalized HLS rendition language tags for Apple TV display, including common ISO-639 aliases like `fre`/`fra` -> `fr`, `eng` -> `en`, and generic subtitle labels like `CC` -> `English CC`.
- Verified with `xcodebuild build -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO`.
- Verified test compilation with `xcodebuild build-for-testing -project lumina.xcodeproj -scheme lumina -destination 'generic/platform=tvOS Simulator' -derivedDataPath .derived-data CODE_SIGNING_ALLOWED=NO`.
- Verified backend streaming coverage with `node --test tests/services/streamingService.test.js tests/routes/stream.test.js` from `Lumina-API`.
