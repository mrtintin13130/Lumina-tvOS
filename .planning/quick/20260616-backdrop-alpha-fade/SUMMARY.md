# Backdrop Alpha Fade Summary

Date: 2026-06-16

## Completed

- Replaced the contextual hero backdrop's bottom black overlay with an alpha mask.
- Kept the existing left alpha mask so the backdrop still dissolves from the text side.
- Preserved backdrop sizing, right alignment, and shelf bleed behavior.

## Verification

- `git diff --check` passed.
