## Why

MVP validation surfaced a conceptual error: Temario is acting as the system root, so users create "Judicatura" *as a temario* — but Judicatura is an oposición; Civil, Penal or Procesal are its temarios. The confusion is baked into six foundation documents, the onboarding suggestions, previews and tests. The domain must reflect reality before release: **Oposición → Temarios → Temas → Intentos**.

## What Changes

- New root entity `Oposicion` (Spanish ubiquitous language, confirmed): 1:N cascade to `Temario`; `Temario` gains a required-by-initializer `oposicion` relationship. The rest of the chain (Tema → Sesión → Intento → Grabación/Métricas/Notas) is unchanged.
- The UI stays single-oposición: an "active" oposición (the only one, or the one in `@AppStorage`) scopes the Temarios tab and Progreso. The domain, storage and relationships fully support multiple oposiciones; no multi-oposición UI yet.
- Idempotent startup backfill: pre-refactor temarios without oposición are adopted by an auto-created "Mi oposición".
- Onboarding gains a phase: bienvenida → **oposición** (Judicatura, Notarías, Inspección de Hacienda) → **primer temario** (Civil, Penal, Procesal) → alta rápida de temas.
- Temarios tab navigation title becomes the active oposición's name; temario creation sheet gains oposición context and corrected examples.
- Ajustes gains an editable "Oposición" row (rename only — no destructive deletion of an oposición from the UI).
- Tema title editing UI added in the tema detail (the model already supported it; the UX was missing — closes a gap against `define-topic-management-flow`).
- Export format bumps to **version 2**: `oposiciones.json`, `oposicionId` in temarios, `oposicion` column in the CSV, manifest counts oposiciones. No importers exist yet, so the bump is safe.
- All foundation documents corrected so Judicatura is always an oposición and Civil/Penal/Procesal are temarios.

**BREAKING**: export package format v2 (additive fields; v1 packages remain readable by humans, no importer affected).

## Capabilities

### New Capabilities

- `oposicion-domain`: the Oposicion root entity, its relationships, the active-oposición rule, and the startup backfill.
- `tema-editing`: editing a tema's number and title from its detail.

### Modified Capabilities

- `temario-management`: temarios belong to the active oposición; list scoping, navigation title, creation context and corrected examples.
- `onboarding-flow`: new oposición phase before the temario phase; corrected examples per level.
- `export-package`: format v2 with oposiciones.
- `navigation-shell`: Ajustes gains the editable Oposición row.

## Impact

- New: `Models/Oposicion.swift`, `Storage/OposicionBackfill.swift`, edit-tema sheet.
- Modified: `Temario`, `opospeakApp` (schema + backfill), `OnboardingDecision`, `OnboardingView`, `ContentView`, `TemariosListView`, `TemarioDetailView` (sheet copy), `TemaDetailView`, `AjustesView`, `ProgresoView`, `ExportModels`, `ExportService`, previews and three test suites.
- Docs: 6 foundation documents + Current Context.
- Migration: additive SwiftData schema (lightweight, CloudKit-safe — container not yet in production).
