## Why

The user curates their own history, and today the product only lets them append to it. Three founder-identified gaps: (1) notes in the Ficha show only the date — two same-day notes are indistinguishable — and the section reads as a second navigation list when its job is to be *read in place* (the post-it over the workbench, "what did I tell myself last time?"); (2) notes cannot be edited or deleted — a typo today is a typo forever, against the data-ownership promise; (3) there is no way to mark an attempt as the user's reference version ("my best 27, the one I'll re-listen before the exam, the one for the preparador").

All three share one theme: **the user curating their own training history**. Curation is user fact, not app judgment — it passes the foundation filter (datos > interpretación) cleanly.

## What Changes

- **Notas recientes as content**: each note in the Ficha shows date *and time*, and presents as readable content first (the text leads; the timestamp is discreet). Tapping still navigates to its attempt — Historial remains the chronological archive; Notas recientes is salience.
- **Edit and delete notes** (in the attempt detail): tap to edit in place, swipe to delete. Swipe without confirmation alert — destructive but minor (one note, not a recording), proportionate to the loss.
- **Highlighted attempt**: a star the user toggles on an attempt (detail view), visible in the topic's Historial rows. Scope deliberately minimal: no filters, no home surfacing, no counts — until real usage asks for them. This is the simple cousin of V2's listening markers and pairs with the existing per-attempt export.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `attempt-persistence`: `isHighlighted` flag on Attempt (default false, CloudKit-compatible); notes become editable and deletable.
- `tema-detail-history`: notes presented as content with full timestamp; highlight star visible in history rows.

## Impact

- Schema: `Attempt.isHighlighted: Bool = false` — additive, default value, CloudKit-safe; no migration concerns. Export contract: add Spanish key (`destacado`) to AttemptDTO — additive, contract v2 stays.
- Modified: `Views/TopicDetailView.swift` (notes presentation, star in rows), `Views/AttemptDetailView.swift` (star toggle, note edit/delete).
- Tests: highlight round-trip, note edit/delete persistence, export includes `destacado`.
- Docs: `Current Context.md`.
