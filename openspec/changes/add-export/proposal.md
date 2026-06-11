## Why

Export is a right, not a feature (`define-privacy-and-export-strategy`): the user must be able to leave with years of practice intact. The package format is fully specified in `define-export-format.md`, the app now produces real data worth exporting, and the Ajustes row is a "Próximamente" placeholder. This change makes the privacy promise real.

## What Changes

- Full export package from Ajustes: `opospeak-export.zip` containing `manifest.json`, `data/` (temarios, temas, sesiones, intentos, métricas, notas as JSON + `intentos.csv`) and `recordings/` with the original m4a files, delivered through the system share sheet.
- Single-intento export from the intento detail: a reduced package (intento.json, notas.json, audio file) for sharing one practice, e.g. with a preparador.
- Recording metadata embedded inside each intento's JSON entry (resolves the open question in `define-export-format` for v1, as the document itself leans).
- ISO 8601 dates, stable UUID identifiers, JSON as source of truth, CSV as convenience projection, audio never re-encoded.
- Zipping with the native file-coordination mechanism — no third-party dependencies.
- Export works fully offline, requires no account, and includes everything (archived temarios and temas too).
- No import in this change: reimport is its own future change (the manifest's `format`/`version`/`counts` fields exist so that change can validate packages).

## Capabilities

### New Capabilities

- `export-package`: the full backup package — structure, schemas, manifest, CSV projection, zip delivery, completeness guarantees.
- `export-intento`: the single-intento reduced package and its entry point.

### Modified Capabilities

- `navigation-shell`: the Ajustes "Exportar mis datos" row changes from placeholder to functional.

## Impact

- New files: `Logic/ExportModels.swift` (Codable DTOs + CSV builder), `Services/ExportService.swift` (package assembly), `Services/ExportArchiver.swift` (native zip).
- Modified: `AjustesView` (functional export with progress + share sheet), `IntentoDetailView` (share action).
- Tests: package content (manifest counts, decodable JSONs, CSV lines, recordings copied), CSV escaping, archiver produces a zip.
- No schema changes, no new dependencies.
