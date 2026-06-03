# Quick Task: catalog-components-split

## Goal

Extract shared catalog presentation helpers out of `ContentView.swift` so screen files and detail overlays reuse components from dedicated view files.

## Tasks

1. Move reusable catalog UI components and `CatalogItem` display helpers into `lumina/Views/CatalogComponents.swift`.
2. Move `StatusText` into `lumina/Views/StatusText.swift`.
3. Update Xcode project source references and verify the app still builds/tests.
