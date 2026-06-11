## Context

MVP validation caught Temario acting as system root: "Judicatura" gets created as a temario when it is an oposición containing temarios (Civil, Penal, Procesal). The confusion spans six foundation docs, the onboarding suggestions, previews and tests. All MVP features are shipped and green (66 tests); the CloudKit container is not yet in production — the cheapest possible moment for a root-level schema change. Spanish ubiquitous language confirmed by David (`Oposicion`, keeping `Temario`/`Tema`/`Intento`).

## Goals / Non-Goals

**Goals:**

- `Oposicion` as root (1:N cascade to Temario); domain/storage/relations fully multi-oposición.
- Single-active-oposición UI; backfill for pre-refactor data; onboarding with the correct hierarchy; corrected terminology everywhere (docs, UI copy, examples, tests).
- Tema title editing UX (model already supported it).
- Export format v2.

**Non-Goals:**

- No oposición picker/switcher UI (future change; the active-oposición seam is built for it).
- No oposición deletion UI (cascade from the root erases years of history).
- No English entity renaming.
- No importer work (still post-MVP; v2 bump is safe with zero importers).

## Decisions

### 1. Same modeling pattern as the rest of the chain

`Oposicion` mirrors `Temario`'s shape: CloudKit-safe (UUID default, optionals/defaults, `@Relationship(deleteRule: .cascade, inverse: \Temario.oposicion)`), initializer-enforced parenthood (`Temario(nombre:oposicion:)`). One pattern across the tree keeps the model boring — boring is correct here.

### 2. Active oposición = device-local pointer with safe fallback

`@AppStorage("oposicionActivaId")` holding a UUID string; resolution: stored id → first oposición → nil (empty states). Device-local on purpose (like the onboarding flag): which oposición you're working on is UX state, not user data, and must not sync. Exposed via `AppEnvironment.oposicionActiva(in:)` helper so views share one resolution path. Alternative — an `activa` flag on the entity — rejected: it syncs, creating cross-device fights over which oposición is "active".

### 3. Backfill runs in `opospeakApp` init, synchronously, before any view queries

`OposicionBackfill.run(context:)`: fetch temarios with `oposicion == nil`; if any, find-or-create "Mi oposición" and attach. Idempotent by construction (second run finds zero orphans). Synchronous because it must complete before `TemariosListView` filters by oposición — and the data volume (a handful of temarios) makes async ceremony pointless.

### 4. Onboarding phase persistence stays per-transition

New phase order: bienvenida → oposición → temario → temas. The oposición is inserted when leaving its phase, the temario when leaving its phase — same abandonment semantics as before, now two resumable artifacts. `OnboardingDecision` keeps its shape with `tieneDatos` (oposiciones OR orphan temarios) replacing `tieneTemarios`.

### 5. List scoping by relationship traversal, not store-wide queries

`TemariosListView` keeps `@Query` for all temarios but filters in-memory by `temario.oposicion?.id == activaId` (SwiftData predicates over optional relationships are fragile; counts are tiny). `ProgresoView` scopes temas/intentos the same way. The seam is small and contained; a future multi-oposición change only touches the resolution, not the views.

### 6. Export v2: additive, embedded in the same files

`oposiciones.json` added; `TemarioExport` gains `oposicionId`; CSV gains an `oposicion` column right after `intentoId`; manifest `version: 2` + `counts.oposiciones`. All oposiciones export (completeness over active-scoping — export is a right over *all* data). No v1 reader exists, so no compatibility shim; `define-export-format` is updated as the public contract.

### 7. Tema editing as a sheet from the tema detail toolbar

`EditarTemaSheet` (número + título) mirroring `NuevoTemaSheet`'s validation: number unique within the temario (excluding itself), empty title allowed and clears to nil. Updates `fechaActualizacion`. This closes the documented gap with `define-topic-management-flow` ("El usuario puede editar: número, título…").

## Risks / Trade-offs

- [Root cascade can erase everything] → No deletion UI for oposiciones; rename only in Ajustes. Same policy precedent as temarios.
- ["Mi oposición" is a guess] → Unavoidable (can't infer the real oposición); renameable in Ajustes; pre-release impact only.
- [In-memory scoping cost] → Negligible at real volumes (≤ tens of temarios); profiled later if ever needed.
- [Synced data from a future multi-oposición device] → Hidden but intact; documented limitation until the picker change.
- [Schema change on CloudKit] → Additive entity + optional relationship = lightweight migration; container not deployed to production yet, so zero migration debt.

## Migration Plan

1. Model + schema + backfill (app still compiles; views unscoped).
2. Onboarding + scoping + Ajustes + tema editing.
3. Export v2 + docs + tests.

Rollback: revert commits; the backfill-created oposición is plain data, harmless under the old code only if reverted before shipping (pre-release: acceptable).

## Open Questions

- None blocking. The oposición picker (multi-oposición UI) is a deliberate future change.
