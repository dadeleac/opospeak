## Why

The domain model is implemented but the app still shows a placeholder view — there is no way to create temarios, browse temas, or reach any future practice screen. The information architecture is fully specified in `Doc OpenSpeak/foundation/define-information-architecture.md` (three tabs, Practicar always launched from a Tema, Sesión invisible) and is the prerequisite for every user-facing feature.

## What Changes

- Replace the placeholder `ContentView` with a `TabView` of three tabs: **Temarios**, **Progreso**, **Ajustes** — each with its own `NavigationStack`.
- Temarios tab: list of temarios (name, tema count, recent activity), create temario (name only, optional description), navigation into temario detail.
- Temario detail: list of temas (number, title if any, last attempt, attempt count), single tema creation, bulk creation ("crear temas del 1 al N"), search, sort (natural order / most / least / last practiced / pending), archive via swipe.
- Tema detail: basic info, attempt history list, prominent **Practicar** button (disabled placeholder until the practice-flow change), navigation to intento detail.
- Intento detail: date, duration, notes list with add-note (playback arrives with the practice-flow change).
- Progreso tab: editorial summary of the four indicator groups (volumen, consistencia, cobertura, distribución) computed from existing intentos; empty state explaining progress appears with practice.
- Ajustes tab: minimal MVP screen (app info, privacy statement, placeholders for export and iCloud status pointing at future changes).
- Empty states for every main screen per the foundation (no temarios / no temas / no intentos / no progreso).
- No audio recording, no playback, no export, no iCloud UI logic — those are separate changes.

## Capabilities

### New Capabilities

- `navigation-shell`: the three-tab structure, per-tab navigation stacks, and where each domain entity surfaces.
- `temario-management`: create, list, and archive temarios; empty states.
- `tema-management`: create (single and bulk), list, search, sort, and archive temas inside a temario.
- `tema-detail-history`: tema detail screen with attempt history, intento detail with notes.
- `progress-overview`: read-only editorial progress indicators derived from intentos.

### Modified Capabilities

<!-- none — domain-model requirements are unchanged; this change only reads/writes through the existing models -->

## Impact

- `opospeak/opospeak/ContentView.swift` — replaced by the tab shell.
- New view files under `opospeak/opospeak/Views/` (Temarios, Temas, TemaDetail, IntentoDetail, Progreso, Ajustes) plus small view-model/helper types for bulk creation and sorting.
- `opospeakTests` — unit tests for bulk creation, sorting, and progress derivation logic (pure logic, no UI tests in this change).
- No new dependencies; SwiftUI + SwiftData only. No schema changes.
