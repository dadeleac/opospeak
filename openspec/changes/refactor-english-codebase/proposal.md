## Why

The product targets Spain (Spanish UI, Spanish documentation, Spanish ubiquitous domain language), but code-level identifiers must be English — the industry convention that keeps the codebase approachable — and user-facing strings must live in iOS's localization system (String Catalog) instead of being scattered literals. With zero users and no production CloudKit schema, this is the cheapest moment this refactor will ever be.

## What Changes

- **Ubiquitous language rule amended** in `define-core-domain-model`: Spanish for product/docs/UI, English for code, with an official mapping table (Oposición→`Opposition`, Temario→`Syllabus`, Tema→`Topic`, Sesión→`PracticeSession`, Intento→`Attempt`, Grabación→`Recording`, Métrica→`Metric`, Nota→`Note`). Echoed in Current Context and the README collaboration rules.
- **All Swift identifiers renamed to English**: 8 models with their properties (`nombre→name`, `fechaCreacion→createdAt`, `activo→isActive`, …), logic types (`TemaBulkCreator→TopicBulkCreator`, `TemaSortOrder→TopicSortOrder`, `SesionPolicy→SessionPolicy`, `OposicionBackfill→OppositionBackfill`), storage/audio (recorder states, availability cases, sync status), views (`TemariosListView→SyllabusListView`, `AjustesView→SettingsView`, `ProgresoView→ProgressOverviewView` to avoid the SwiftUI clash), test suites and test function names, UserDefaults keys.
- **Export contract preserved (Option A, confirmed)**: package file names, JSON keys, CSV header and persisted raw values stay Spanish — user-facing data a Spanish opositor must be able to read. Implemented with English Swift properties + explicit `CodingKeys`. `define-export-format` unchanged.
- **String Catalog**: development language set to Spanish (`developmentRegion = es`); `Localizable.xcstrings` added; SwiftUI literals auto-extract; non-View user-facing strings move to `String(localized:)`. Data strings (CSV header, JSON keys, raw values) are NOT localized.
- **Color tokens renamed to English** (`Ink, Slate, Paper, Sand, ElevatedSand, Sage, Amber, MutedRed`) — matching the foundation doc, which already names them in English.
- No behavior changes: the 74-test suite (renamed) is the safety net. Local stores reset (no users); dev CloudKit schema to be reset in the Console.

## Capabilities

### New Capabilities

- `code-language-policy`: the Spanish-domain/English-code rule, the mapping table, and the localization architecture (Spanish as source language in a String Catalog).

### Modified Capabilities

<!-- none at requirement level — purely internal renaming plus localization plumbing; all user-visible behavior and the export contract are unchanged -->

## Impact

- ~20 source files renamed/rewritten, 8 test files, 8 colorsets, pbxproj (developmentRegion, knownRegions), new `Localizable.xcstrings`.
- Docs: `define-core-domain-model` (lenguaje ubicuo), `Current Context.md`, `README.md`.
- Export DTOs gain CodingKeys; package bytes identical before/after (asserted by existing export tests).
