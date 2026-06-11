## Context

The domain model (previous change) is in place; the UI is a placeholder. `define-information-architecture.md` fixes the structure: three tabs, drill-down inside Temarios, Practicar born from the tema, sessions invisible, one tema per intento. `define-design-principles.md` and the HIG/WCAG docs constrain the feel: native patterns, editorial over dashboard, accessibility from day one. Audio recording/playback is explicitly the next change — this one builds every screen around it.

## Goals / Non-Goals

**Goals:**

- Tab shell (`TabView`) with three `NavigationStack`s and native navigation.
- Full temario/tema management: create (single + bulk), list, search, sort, archive.
- Tema detail with intento history; intento detail with notes.
- Progreso derived read-only from intentos; Ajustes minimal.
- Empty states for every main screen.
- Unit tests for the pure logic (bulk creation, sorting, progress derivation).

**Non-Goals:**

- No recording, playback, export, or iCloud logic (separate changes).
- No custom visual identity yet (Deep Ink/Warm Sand theming is its own change; system styling now keeps this change reviewable).
- No onboarding sequence (own change; the empty states already guide).
- No iPad/macOS layout work.

## Decisions

### 1. Plain SwiftUI + @Query, no view-model layer

Views observe SwiftData directly with `@Query`; mutations go through small service types where logic exists (bulk creation, deletion via `PracticeRepository`). Rationale: `define-product-foundation` mandates "simplicity over abstraction"; introducing MVVM around `@Query` duplicates state. Pure logic that deserves tests lives in plain testable types (`TemaBulkCreator`, `TemaSortOrder`, `ProgressSummary`), not in view models. Alternative considered: full MVVM — rejected as ceremony without testable benefit here.

### 2. Sorting and derived counts computed in Swift, not in fetch descriptors

Last-attempt date and intento counts come from the tema's `intentos` relationship; sort orders are implemented as a `TemaSortOrder` enum with a pure `sort(_:)` function over fetched temas. Rationale: SwiftData predicates/sorts cannot express "max of related dates" reliably, syllabi are ≤ ~1000 temas, and pure functions are unit-testable. Re-evaluate only if profiling shows list lag (performance-review skill exists for that).

### 3. Bulk creation as a pure planner + a thin persister

`TemaBulkCreator.plan(existingNumbers:range:)` returns the numbers to create (skipping existing, validating bounds); the caller inserts models. Rationale: the interesting logic (skip/validate) becomes trivially testable without a container.

### 4. Progreso derives from a value-type summary

`ProgressSummary(intentos:temas:)` computes volumen/consistencia/cobertura/distribución as plain values; the view renders them. No persistence, matching "statistics are derived views" from the domain model. Consistency is presented as "days with practice" facts — no streak framing, per `define-progress-and-history-model`.

### 5. Practicar button present but disabled

The tema detail renders the primary Practicar button (the screen's center of gravity per the foundation) in a disabled state with a short "próximamente" hint. Rationale: the IA must already teach the action's home; shipping the screen without the button would re-train users later. Alternative — hiding it — rejected for that reason.

### 6. Archiving via `activo` flag; no destructive deletes in UI

Archive toggles `tema.activo`/a new `temario.activo` … the Temario model lacks an `activo` flag. **Schema addition**: add `var activo: Bool = true` to `Temario` (additive, CloudKit-safe, no migration concern). Lists filter on it. Destructive deletion stays out of the UI until the confirmation flow is specced.

### 7. Accessibility baked in

Every interactive element gets a label; rows expose combined accessibility text ("Tema 42, último intento 12 de mayo, 3 intentos"); Dynamic Type works by using text styles only (no fixed font sizes); color is never the only signal. This is a hard requirement from `define-wcag-accessibility-compliance`, not polish.

## Risks / Trade-offs

- [Computing counts from relationships may be slow on huge syllabi] → Bounded (≤1000 temas), measured later via performance review; fetch-level optimization is a contained refactor behind the same view API.
- [Adding `Temario.activo` changes the schema] → Additive with default value: SwiftData lightweight migration handles it; CloudKit-compatible.
- [Disabled Practicar may frustrate] → Copy explains it's coming; this state ships only between this change and the practice-flow change.
- [System styling now, identity later] → Conscious sequencing; the theming change restyles without structural rework because views use semantic styles.

## Migration Plan

1. Add `activo` to `Temario` (default true) — no data migration needed.
2. Build views bottom-up (rows → screens → tabs), replacing `ContentView` last so the app compiles at each step.

Rollback: revert commits; schema addition is additive and harmless.

## Open Questions

- None blocking. Visual identity (colors/typography) intentionally deferred to its own change.
