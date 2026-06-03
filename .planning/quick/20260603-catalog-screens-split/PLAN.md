# Catalog Screens Split Plan

Date: 2026-06-03

## Goal

Extract the remaining catalog browsing screens from `ContentView.swift` while preserving the root app-phase switch.

## Tasks

1. Move `HomeShellView`, `CatalogHomeView`, `CatalogGridView`, `CatalogSearchView`, and any still-needed catalog action card into `lumina/Views/CatalogScreens.swift`.
2. Add `CatalogScreens.swift` to the app target in `lumina.xcodeproj/project.pbxproj`.
3. Verify with a generic tvOS build and the tvOS simulator test suite.
