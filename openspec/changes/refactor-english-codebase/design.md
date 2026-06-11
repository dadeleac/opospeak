## Context

David confirmed: Spain-oriented product, English code, iOS-native localization, export contract stays Spanish (Option A). No users, no production CloudKit schema — renames are free now and expensive forever after. The 74-test suite is the behavioral safety net.

## Goals / Non-Goals

**Goals:** every Swift identifier English; Spanish UI via String Catalog with Spanish as source language; export contract byte-identical; docs amended with the mapping rule.

**Non-Goals:** no behavior changes; no new translations (the catalog ships with Spanish only); no export format changes; no entity redesign.

## Decisions

### 1. Naming choices that avoid collisions

`PracticeSession` (not `Session` — ambiguity with URL/AVAudioSession conventions); `ProgressOverviewView` (SwiftUI owns `ProgressView`); `MigrationResult` (Swift owns `Result`); `Recording` model coexists with `RecordingStore` naturally. Property conventions: `createdAt/updatedAt`, `isActive/isCompleted`, `startedAt/endedAt`, `displayName`, `fileSize`.

### 2. Spanish development language, not English-source-plus-translation

`developmentRegion = es` + `Localizable.xcstrings`. UI literals in code remain Spanish and ARE the source of truth — no artificial English copy to maintain for an app whose only market is Spain. Future languages are catalog entries. Alternative (English source, Spanish translation) doubles the copywriting for zero current benefit.

### 3. Export DTOs: English properties, Spanish CodingKeys

The package is user-facing data for Spanish opositores (Option A). Each DTO declares explicit `CodingKeys` (`case name = "nombre"`, `case createdAt = "fechaCreacion"`, …). Manifest counts keys, file names (`oposiciones.json`), CSV header and `TipoSesion`-style raw values are contract, untouched. The existing export tests assert the contract, so drift fails loudly.

### 4. Localization boundaries

`String(localized:)` for: sort-order titles, sync status descriptions, recorder error messages, CSV-unrelated computed display strings (`"Tema \(n)"` display name). NOT localized: CSV header/rows, JSON keys, UserDefaults keys, enum raw values, asset names, log strings.

### 5. Stores reset instead of migration

Renaming SwiftData entities/attributes without versioned migration breaks existing stores. With zero users: delete simulator app; reset the dev CloudKit container schema in the Console before the next device build. Recorded as a release-checklist note, not code.

## Risks / Trade-offs

- [Massive diff obscures review] → Pure-rename commits verified by compiler + unchanged test assertions; export byte-compat asserted by tests.
- [Missed Spanish identifier] → Final grep sweep for Spanish tokens in code (excluding string literals and CodingKeys).
- [Auto-extraction misses non-View strings] → Explicit `String(localized:)` list in tasks; visual check of the generated catalog.

## Migration Plan

Models → logic/storage/audio → views/colors → tests → catalog/pbxproj → docs. Suite green at the end (intermediate states won't compile until each layer completes; this is a single atomic change).

## Open Questions

- None. Option A confirmed by David.
