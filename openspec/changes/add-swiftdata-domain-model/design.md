## Context

The Xcode project contains only Apple's SwiftUI + SwiftData scaffold (`Item.swift`, CRUD `ContentView`). The domain is fully specified in `Doc OpenSpeak/foundation/define-core-domain-model.md`: seven entities around oral practice, with the Intento as the central unit of analysis. Constraints that shape this design:

- **CloudKit sync is part of the MVP** (`define-mvp-scope`), so the schema must be CloudKit-compatible from version 1 even though sync is activated in a later change.
- **Recordings are independent files**, not database rows (`define-local-first-data-strategy`): metadata in SwiftData, audio on disk.
- **History is sacred** (`define-topic-management-flow`): archiving is the norm; deletion cascades must be deliberate and complete (no orphaned audio files).
- Target: iPhone, SwiftUI, SwiftData, no external dependencies.

## Goals / Non-Goals

**Goals:**

- Seven `@Model` classes matching the ubiquitous language: `Temario`, `Tema`, `Sesion`, `Intento`, `Grabacion`, `Metrica`, `Nota`.
- All relationships with explicit inverses and delete rules.
- CloudKit-compatible schema (optionals/defaults, inverses, no incompatible unique constraints).
- File-based audio storage with identity-derived URLs.
- Unit tests over an in-memory container.

**Non-Goals:**

- No UI beyond keeping the app compiling (real navigation comes with the information-architecture change).
- No CloudKit entitlement or sync activation.
- No recording capture (AVAudioRecorder) — only the storage contract.
- No multi-topic extraction entity (deferred decision in `define-core-domain-model`).
- No data migration (the scaffold store holds no real data).

## Decisions

### 1. Spanish entity names, matching the ubiquitous language

`Temario`, `Tema`, `Sesion`, `Intento`, `Grabacion`, `Metrica`, `Nota` (without accents for identifier safety). The foundation mandates that "all documents, code and future specifications use the terminology defined here". Alternative considered: English names (`Syllabus`, `Topic`, `Attempt`) — rejected because it forces permanent mental translation against every product document.

### 2. CloudKit compatibility rules applied now

CloudKit mirroring requires: every relationship optional with an inverse, no `.deny` delete rules, no `#Unique` constraints, and defaults for non-optional attributes. We apply these from day one so enabling sync later is a flag, not a migration. Concretely:

- Relationships are declared optional at the SwiftData level (`var temario: Temario?`) even when the domain requires them; the domain requirement is enforced by initializers that take the parent as a required parameter.
- Identity uses a `UUID` attribute with a default, not `#Unique`.
- Collections default to empty arrays.

Alternative considered: strict non-optional relationships now, relax later — rejected because that is exactly the schema migration we want to avoid.

### 3. To-many relationships declared on the parent with `.cascade`; deletion of Sesion uses `.nullify`

- `Temario.temas` → cascade (deleting a temario deletes its temas).
- `Tema.intentos` → cascade.
- `Intento.grabacion` (to-one), `Intento.metricas`, `Intento.notas` → cascade.
- `Sesion.intentos` → nullify: deleting a sesión must never delete practice history. An intento whose sesión disappears keeps its tema, recording, and metrics. (SwiftData+CloudKit makes the relationship optional anyway; the UI never exposes session deletion in the MVP.)

### 4. Audio files referenced by identity, not by stored path

`Grabacion` stores `id`, `duracion`, `tamano`, `formato`, `fechaCreacion` — no absolute path. The file URL is computed: `Application Support/Recordings/<grabacion.id>.m4a`. Rationale: the app container path changes across restores and devices; absolute paths rot. A small `RecordingStore` type owns URL resolution and file deletion. Alternative considered: storing a relative path string — viable, but computing from identity is simpler and matches the export format (`recordings/<id>.m4a` in `define-export-format`).

Note: recording **files** do not sync via CloudKit in this change; only metadata does once sync is enabled. File sync strategy is decided in the future sync change.

### 5. File deletion coupled to model deletion at the store layer

SwiftData has no reliable "on delete" hook for side effects. Deleting an `Intento`/`Grabacion` goes through a small domain service (`PracticeRepository.delete(intento:)`) that removes the audio file and then deletes the model. Direct `modelContext.delete` on these types is treated as a code-review error. Alternative considered: scanning for orphaned files on launch — kept as a future safety net, not the primary mechanism.

### 6. Extensible enums stored as raw strings

`Sesion.tipo` and `Metrica.tipo` persist as `String` raw values with Swift enum wrappers (`TipoSesion`, `TipoMetrica`) exposing known cases plus tolerance for unknown values. Rationale: both lists are explicitly extensible in the foundation; raw strings survive schema evolution and CloudKit round-trips. Alternative: native enum persistence — rejected, adding a case forces migration concerns and breaks older clients reading newer data.

### 7. Tests with Swift Testing on an in-memory container

`ModelConfiguration(isStoredInMemoryOnly: true)` per test. Tests cover: creation with minimum data, relationship integrity (both directions), cascade behavior for temario/tema/intento, nullify behavior for sesión, and `RecordingStore` URL resolution + file cleanup.

## Risks / Trade-offs

- [Optional relationships weaken compile-time guarantees] → Required initializer parameters + repository methods are the enforcement point; tests assert that orphan creation paths don't exist in practice.
- [Cascade from Temario can mass-delete years of history] → The model allows it, but per `define-topic-management-flow` the UI must always favor archiving and require explicit confirmation; this is restated in the spec.
- [File/DB consistency can drift (crash between file write and model save)] → Recording files are written before the model is saved; an orphan-file sweep can be added in a later change. Orphaned files waste space but never lose data — the dangerous direction (model without file) is surfaced in UI as "grabación no disponible".
- [CloudKit compatibility is asserted but not exercised] → Mitigated by following Apple's documented constraints now and validating with a CloudKit-enabled container in the sync change; cheap to verify early with a development container.

## Migration Plan

1. Add model files; keep `Item` temporarily so the project compiles at each commit.
2. Switch `opospeakApp`'s schema to the seven models; simplify `ContentView` to a placeholder.
3. Delete `Item.swift`. The old on-device store from the scaffold is discarded (delete app from simulator); no user data exists.

Rollback: revert the commits; no persisted production data is at risk.

## Open Questions

- None blocking. The multi-topic extraction entity and the recording-metadata placement in the export format remain deliberately deferred (documented in `Current Context.md`).
