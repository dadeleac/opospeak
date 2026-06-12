## Why

An attempt is undeletable from the UI. The plumbing has existed since the first change — `PracticeRepository.delete(attempt:)` cascades recording, metrics and notes and removes the audio file, with a test guarding it — but no screen exposes it. For a product whose argument is data ownership, not being able to remove a mic test, a duplicate, or a failed practice is incoherent.

## What Changes

- **Delete an attempt (option A, founder-approved)**: swipe on the Ficha's Historial rows and an "Eliminar intento" action in the attempt detail. Both require a **confirmation alert** — unlike note deletion, this destroys irreversible audio (the cost of each destruction dictates its friction, as with Descartar práctica). Deletion goes through `PracticeRepository` (never raw `modelContext.delete`), so files never orphan.
- Semantic consequence, accepted: insights recalculate — the deleted practice no longer counts toward state, cadence or evolution. That is what deletion means.
- **Deferred (noted, not built)**: audio-only deletion keeping the attempt (storage management for years of practice) — its own future change, with its own questions (bulk? by age?).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `attempt-persistence`: user-initiated attempt deletion via the single repository path, confirmed.
- `tema-detail-history`: swipe-to-delete on Historial rows; delete action in the attempt detail.

## Impact

- Modified: `Views/TopicDetailView.swift` (swipe + alert), `Views/AttemptDetailView.swift` (toolbar menu + alert + dismiss).
- No schema changes; repository and its test already exist.
