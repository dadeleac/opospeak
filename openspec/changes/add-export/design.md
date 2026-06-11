## Context

`define-export-format.md` specifies the package down to file names and JSON shapes. The app has real data (practice flow shipped) and `RecordingStore` already resolves audio by identity, matching the package's `recordings/<id>.m4a` convention. The Ajustes export row is a placeholder. Constraint stack: open formats, no re-encoding, no account, no network, no proprietary lock (`define-privacy-and-export-strategy`); native solutions over dependencies (`define-product-foundation`).

## Goals / Non-Goals

**Goals:**

- Full package: manifest + data JSONs + CSV + recordings, zipped, via share sheet.
- Single-intento reduced package from the intento detail.
- Testable assembly: package built on disk by a service that takes models and a RecordingStore.
- Zero dependencies.

**Non-Goals:**

- No import/restore (own change; manifest fields exist for it).
- No selective export (date ranges, single temario) — completeness first.
- No encryption of the package (explicit foundation restriction: the user must be able to open it).
- No background/scheduled exports.

## Decisions

### 1. DTOs decoupled from SwiftData models

`ExportModels.swift` defines plain Codable structs mirroring `define-export-format` (TemarioExport, TemaExport, SesionExport, IntentoExport with embedded GrabacionExport, MetricaExport, NotaExport, ManifestExport), each with an `init(from:)` mapping. Rationale: the export schema is a public contract that must stay stable while SwiftData models evolve; coupling them would leak schema changes into users' backups. Encoder: `.iso8601` dates, `.prettyPrinted + .sortedKeys` for human readability and deterministic output (testable).

### 2. Grabación metadata embedded in the intento entry

Per the explicit lean in `define-export-format`: 1:0..1 relationship, shared identity, simpler package. The `archivo` field is a relative path (`recordings/<id>.m4a`). A future multi-recording need would bump `version` and split into `grabaciones.json` — the document already anticipates this.

### 3. Native zip via file coordination

`ExportArchiver` zips the package directory using `NSFileCoordinator.coordinate(readingItemAt:options:.forUploading:)`, which yields a system-produced zip of a directory — the documented no-dependency mechanism. The coordinator's zip lives in a temporary location, so it is copied out to a stable temp URL named `opospeak-export.zip` before sharing. Alternative — ZIPFoundation — rejected: a dependency for something the system already does.

### 4. `ExportService` assembles; views only trigger

`buildFullPackage()` fetches all entities, writes `manifest.json`, `data/*.json`, `intentos.csv`, copies recordings (only files that exist; manifest counts reflect copied files), and returns the package directory URL. `buildIntentoPackage(intento:)` produces the reduced layout. Both are pure file-system work over injected `ModelContext` + `RecordingStore` → fully testable with in-memory containers and temp directories, no UI.

### 5. CSV with RFC 4180 escaping

A small `escapeCSV` helper quotes fields containing commas, quotes, or newlines (temario/tema names are user text). Kept in `ExportModels` next to the row builder so the projection and its escaping are tested together.

### 6. Share via a minimal `ShareSheet` representable

Generation is async (Button → Task → service → zip) with a `ProgressView` state and the button disabled while running; the resulting zip URL is presented with a `UIActivityViewController` wrapper. Rationale: `ShareLink` wants its item up front; generating multi-hundred-MB packages eagerly on view load is wrong. The wrapper is ~15 lines and used by both entry points.

### 7. Temporary artifacts cleaned up

Each export builds under a unique temp directory, removed after the share sheet dismisses (best-effort; temp is system-purgeable anyway). Rationale: packages with recordings can be large; leaving them around doubles storage.

## Risks / Trade-offs

- [Large libraries → slow export, big zips] → Progress UI + disabled button; copying is I/O-bound and linear; acceptable for MVP. Streaming/incremental export is future work if profiling demands it.
- [forUploading zip behavior is indirectly documented] → It is long-standing, widely used system behavior; the archiver is isolated behind one type, swappable without touching the service. A unit test asserts a real zip is produced.
- [Temp disk usage spikes (package + zip ≈ 2× recordings size)] → Accepted for MVP; documented here. Hard-linking instead of copying recordings is a contained optimization inside the service if needed.
- [Schema drift between foundation doc and DTOs] → DTOs cite the doc; the export tests assert the exact file names and field names from `define-export-format`.

## Migration Plan

1. DTOs + CSV (pure) → service → archiver → UI wiring. Build at each step.

Rollback: revert commits; export writes only to temp directories.

## Open Questions

- None blocking. Import/restore is the natural next change consuming this format.
