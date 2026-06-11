## Why

The Xcode project still contains Apple's scaffold (`Item.swift` placeholder), while the foundation documents already define a complete, stable domain model (Temario → Tema → Sesión → Intento → Grabación → Métricas → Notas). Every feature of the MVP — practice recording, history, progress, export, iCloud sync — depends on these models existing first, so this is the foundational change that unblocks all development.

## What Changes

- Replace the scaffold `Item` model with the real SwiftData domain models: `Temario`, `Tema`, `Sesion`, `Intento`, `Grabacion`, `Metrica`, `Nota`.
- Model all relationships and cardinalities defined in `define-core-domain-model`: Temario→Tema (1:N), Tema→Intento (1:N), Sesión→Intento (1:N), Intento→Grabación (1:0..1), Intento→Métricas (1:N), Intento→Notas (1:N).
- Define delete rules that protect the practice history (archive over delete; cascades only where the foundation allows them).
- Keep the schema CloudKit-compatible from day one (optional/defaulted attributes, optional relationships with inverses), since iCloud sync is part of the MVP.
- Store recordings as files on disk referenced by the model, not as blobs inside the database, per `define-local-first-data-strategy`.
- Update `opospeakApp` to register the new schema and remove `Item.swift` and the scaffold CRUD in `ContentView`.
- Add unit tests covering model creation, relationships, and delete behavior using an in-memory container.

**BREAKING**: removes the scaffold `Item` model and its persisted store contents (no real user data exists yet).

## Capabilities

### New Capabilities

- `domain-model`: SwiftData entities, attributes, relationships, cardinalities, and delete rules for the OpoSpeak core domain (Temario, Tema, Sesión, Intento, Grabación, Métrica, Nota), including CloudKit compatibility constraints and file-based recording storage.

### Modified Capabilities

<!-- none — this is the first capability of the project -->

## Impact

- `opospeak/opospeak/Item.swift` — deleted, replaced by model files under a `Models/` group.
- `opospeak/opospeak/opospeakApp.swift` — schema registration updated to the new models.
- `opospeak/opospeak/ContentView.swift` — scaffold CRUD removed (placeholder view until the information-architecture change lands).
- `opospeak/opospeakTests/` — new model tests.
- No external dependencies; native SwiftData only. CloudKit entitlements are NOT enabled in this change — only schema compatibility is guaranteed (sync activation is a separate change).
