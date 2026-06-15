# Focus UI

## Lockups And Shelves

- Use SwiftUI `Button` for media lockups whenever possible. On tvOS, button styles provide the platform focus lift, hover, and motion behavior.
- Use `.buttonStyle(.borderless)` for standard poster, landscape, and icon lockups.
- Use `.buttonStyle(.card)` for information-dense search results or rows where the whole platter should focus.
- Put separate `Image` and `Text` views in the button label for standard vertical media lockups. Avoid `Label` for poster buttons unless its layout has been verified.
- Attach `.hoverEffect(.highlight)` to the exact subview that should lift/highlight when the default first-image behavior is wrong.
- Build shelves with `ScrollView(.horizontal)` and `LazyHStack`, usually one lockup style per shelf.
- Add `.scrollClipDisabled()` to shelves so focused items can scale and lift without clipping.
- Prefer `containerRelativeFrame(.horizontal, count:spacing:)` for shelf item sizing so content aligns to the container and safe area.

## Focus Routing

- Use `@FocusState` with unique enum cases for screens that need programmatic focus, validation focus, or focus restoration.
- Use `defaultFocus` for initial focus on a screen, overlay, or action group.
- Use `focusSection()` around non-focusable hero/header regions that contain buttons so directional focus can move from lower shelves back into header actions.
- Remember that `focusSection()` guides movement to focusable descendants; it does not make the modified view focusable.
- Use `onMoveCommand` only for custom directional behavior. Let the focus engine handle ordinary grid and shelf movement.
- Never reuse the same `FocusState` value for multiple focusable views.

## Layout And 10-Foot Rules

- Keep primary content within Apple TV safe margins: approximately 60 pt top/bottom and 80 pt sides. Full-bleed artwork may extend beyond this, but text and focusable controls should not.
- Keep row spacing generous enough for focus scaling without overlap.
- Use stable dimensions and aspect ratios for posters, landscape cards, buttons, and grids so focus and loading states do not resize the layout.
- Keep on-page descriptions short. Show full long descriptions in a deliberate full-screen overlay or detail panel.
- Use high-quality poster, backdrop, and landscape artwork. On tvOS, imagery is often the interaction surface, not decoration.

## Search And Text Entry

- Treat Search as a first-class top-level destination.
- Use `.searchable(text:)` and `.searchSuggestions` for tvOS search flows. Apple notes tvOS searchable suggestions only support `Text` suggestions.
- Offer suggestions, recent searches, genres, and immediate results to reduce remote keyboard burden.
- Use `LazyVGrid` with landscape lockups for result walls. Sort results predictably before rendering.
- For server URL and login forms, use clear labels, secure password fields, validation focus, and short error copy. Never make remote text entry longer than necessary.

## Top Shelf

- Treat Top Shelf as personalized content, not marketing. Prefer resume, recently added, favorites, or watchlist items.
- Deep-link each Top Shelf item to playback or the relevant detail page.
- Provide a static fallback image for signed-out or unavailable server states.
- Use sectioned content rows by default for media libraries; use carousel-style layouts for a small featured set.
