---
status: in_progress
created: 2026-06-15
task: tvos-episode-playback-foundation
---

# Quick Task: tvOS Episode Playback Foundation

## Goal

Turn the existing movie-only playback proof path into a media-aware playback path that can prepare movies and TV episodes for AVKit playback while preserving the current backend contract and redaction rules.

## Tasks

1. Extend catalog and playback models with safe episode identity fields and a media descriptor.
2. Update the API client/playback loader to create movie or episode playback sessions, request scoped stream tokens, build HLS URLs, fetch progress/tracks when supported, and keep movie behavior compatible.
3. Wire detail episode cards into playback and add focused unit coverage for URL/session/progress payload behavior.

## Verification

- Run focused unit tests where the local Xcode environment permits.
- If simulator services remain unavailable, record that limitation and rely on compile/test commands to the extent possible.
