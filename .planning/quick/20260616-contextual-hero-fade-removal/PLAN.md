# Contextual Hero Fade Removal Plan

Date: 2026-06-16

## Goal

Remove the contextual Home hero's separate fade overlay while preserving the backdrop image's own left and bottom fades.

## Scope

- Remove only the hero-level gradient overlay in `ContextualHomeHeroView`.
- Keep `ContextualHeroBackdrop` masks/overlays unchanged.
- Run a lightweight diff check.
