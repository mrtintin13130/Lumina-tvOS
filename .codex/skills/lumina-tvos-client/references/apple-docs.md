# Apple Documentation Map

Use official Apple docs for current API details. Keep this file as a map and summary, not a copied documentation dump.

## Primary Sample

- [Creating a tvOS media catalog app in SwiftUI](https://developer.apple.com/documentation/SwiftUI/Creating-a-tvOS-media-catalog-app-in-SwiftUI) - Modern sample for content lockups, shelves, product pages, search views, hero headers, fold behavior, and tvOS 18 sidebar patterns.
- [WWDC24: Migrate your TVML app to SwiftUI](https://developer.apple.com/wwdc24/10207/) - Session associated with the sample.
- [Sample code download](https://docs-assets.developer.apple.com/published/4151095c6511/CreatingATvOSMediaCatalogAppInSwiftUI.zip) - Download only when concrete sample source is needed.

Key sample guidance:

- Use borderless buttons for standard tvOS lockups.
- Use card buttons for information-dense lockups.
- Use horizontal shelves with disabled scroll clipping.
- Use `containerRelativeFrame` for shelf sizing.
- Use `focusSection()` to improve focus travel between hero/header regions and shelves.
- Use `.searchable` and text-only suggestions for tvOS search.
- Treat tvOS 18-only sample APIs as gated while Lumina targets tvOS 17.2.

## SwiftUI Catalog UI

- [PrimitiveButtonStyle.borderless](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/borderless) - Standard media lockup button style.
- [PrimitiveButtonStyle.card](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/card) - Denser card/platter style for search results and richer lockups.
- [View.hoverEffect(_:)](https://developer.apple.com/documentation/swiftui/view/hovereffect(_:)) and [HoverEffect.highlight](https://developer.apple.com/documentation/swiftui/hovereffect/highlight) - Use when the default focused subview is wrong.
- [View.containerRelativeFrame(_:count:span:spacing:alignment:)](https://developer.apple.com/documentation/swiftui/view/containerrelativeframe(_:count:span:spacing:alignment:)) - Size shelves relative to the safe container.
- [LazyVGrid](https://developer.apple.com/documentation/swiftui/lazyvgrid) - Use for search/result grids.
- [ScrollTargetBehavior](https://developer.apple.com/documentation/swiftui/scrolltargetbehavior) - Use for custom snapping behavior.
- [View.onScrollVisibilityChange(threshold:_:)](https://developer.apple.com/documentation/swiftui/view/onscrollvisibilitychange(threshold:_:)) - tvOS 18+ visibility transitions; gate before use.
- [View.fullScreenCover(isPresented:onDismiss:content:)](https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:)) - Use for full text or modal flows when appropriate.

## Focus And Remote

- [FocusState](https://developer.apple.com/documentation/swiftui/focusstate) - Programmatic focus state.
- [View.focused(_:equals:)](https://developer.apple.com/documentation/swiftui/view/focused(_:equals:)) - Bind enum cases to focusable controls.
- [View.defaultFocus(_:_:priority:)](https://developer.apple.com/documentation/swiftui/view/defaultfocus(_:_:priority:)) - Initial focus for screens and panels.
- [View.focusSection()](https://developer.apple.com/documentation/swiftui/view/focussection()) - Guide focus movement through a region and its descendants.
- [View.focusable(_:interactions:)](https://developer.apple.com/documentation/swiftui/view/focusable(_:interactions:)) - Use when custom views must participate in focus.
- [EnvironmentValues.isFocused](https://developer.apple.com/documentation/swiftui/environmentvalues/isfocused) - Read focus state inside reusable components.
- [View.onMoveCommand(perform:)](https://developer.apple.com/documentation/swiftui/view/onmovecommand(perform:)) - Custom directional handling; avoid for ordinary navigation.
- [UIPress.PressType.playPause](https://developer.apple.com/documentation/uikit/uipress/presstype/playpause) - Raw play/pause input when needed outside system playback.

## Search And Navigation

- [View.searchable(text:placement:prompt:)](https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:)-18a8f) - tvOS search field integration.
- [View.searchSuggestions(_:)](https://developer.apple.com/documentation/swiftui/view/searchsuggestions(_:)) - Search suggestions; keep tvOS suggestions text-only.
- [TabViewStyle.sidebarAdaptable](https://developer.apple.com/documentation/swiftui/tabviewstyle/sidebaradaptable) - tvOS 18+ sidebar-adaptable navigation; defer or gate for Lumina.
- [App organization](https://developer.apple.com/documentation/swiftui/app-organization) - Top-level SwiftUI app structure.

## AVKit And HLS

- [AVKit VideoPlayer](https://developer.apple.com/documentation/avkit/videoplayer) - Simple SwiftUI player view for previews or limited playback.
- [AVPlayerViewController](https://developer.apple.com/documentation/avkit/avplayerviewcontroller) - Preferred full-screen system player UI for Lumina playback.
- [Customizing the tvOS Playback Experience](https://developer.apple.com/documentation/avkit/customizing-the-tvos-playback-experience) - Use system extension points instead of replacing controls.
- [HTTP Live Streaming](https://developer.apple.com/documentation/http-live-streaming) - HLS overview and Apple platform support.
- [HLS Authoring Specification for Apple Devices](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices) - Server/media output expectations to validate when playback fails.
- [AVAsset](https://developer.apple.com/documentation/avfoundation/avasset) - Asset model for streamed media, tracks, and metadata.
- [Selecting Subtitles and Alternative Audio Tracks](https://developer.apple.com/documentation/avfoundation/selecting-subtitles-and-alternative-audio-tracks) - Media selection groups and track selection.
- [Configuring Your App for Media Playback](https://developer.apple.com/documentation/avfoundation/configuring-your-app-for-media-playback) - Audio session and playback behavior setup.

## Human Interface Guidelines

- [Top Shelf](https://developer.apple.com/design/human-interface-guidelines/top-shelf) - Personalized content and deep links from Apple TV Home.
- [Layout](https://developer.apple.com/design/human-interface-guidelines/layout) - Safe areas and spatial organization.
- [Images](https://developer.apple.com/design/human-interface-guidelines/images) - Artwork quality expectations.
- [Focus and selection](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection) - Focus behavior expectations.
- [Remotes](https://developer.apple.com/design/human-interface-guidelines/remotes) - Siri Remote conventions.
- [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars) - Top-level navigation.
- [Sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars) - Sidebar navigation guidance.
- [Search fields](https://developer.apple.com/design/human-interface-guidelines/search-fields) - Search interaction.
- [Text fields](https://developer.apple.com/design/human-interface-guidelines/text-fields) and [Virtual keyboards](https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards) - Remote text entry.
