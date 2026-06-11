## ADDED Requirements

### Requirement: Complete package structure
The full export SHALL produce a zip whose root contains `manifest.json`, a `data/` directory with `temarios.json`, `temas.json`, `sesiones.json`, `intentos.json`, `metricas.json`, `notas.json` and `intentos.csv`, and a `recordings/` directory with one audio file per grabación named `<grabacionId>.<formato>`. Nothing SHALL be omitted: archived temarios and temas, all intentos, all métricas, all notas, and every recording present on disk.

#### Scenario: Package contains everything
- **WHEN** a user with 2 temarios (one archived), 30 temas, 50 intentos and 48 recordings exports
- **THEN** the package contains both temarios, the 30 temas, the 50 intentos, and 48 files in `recordings/`

### Requirement: Manifest describes and validates the package
`manifest.json` SHALL contain: `format` ("opospeak-export"), `version` (1), `exportedAt` (ISO 8601), `appVersion`, `counts` (temarios, temas, sesiones, intentos, grabaciones, notas) and `recordingFormat`. Counts SHALL reflect the actual exported data so a future import can verify integrity.

#### Scenario: Counts match content
- **WHEN** the package is generated
- **THEN** each value in `counts` equals the number of entries in the corresponding JSON file

### Requirement: Open, stable data schema
All JSON files SHALL use ISO 8601 dates, stable UUID identifiers that reconstruct every relationship (temario → tema → intento → métricas/notas), and human-readable formatting. Recording metadata (id, relative file path, duración, tamaño, formato, fechaCreación) SHALL be embedded in its intento's JSON entry, with the file path relative to the package root (`recordings/<id>.m4a`). The package SHALL be self-sufficient: no relationship depends on external information.

#### Scenario: Relationships survive outside OpoSpeak
- **WHEN** the package is read with generic JSON tooling
- **THEN** every intento resolves its tema by id, every tema its temario, and every grabación entry points to an existing file in `recordings/`

### Requirement: CSV convenience projection
`intentos.csv` SHALL be a flat projection with header `intentoId,temario,tema,numero,fecha,duracionSegundos,completado,tieneGrabacion,tieneNotas` and one row per intento. Fields containing commas or quotes SHALL be escaped per RFC 4180. The CSV SHALL contain nothing that is not already in the JSON files.

#### Scenario: Spreadsheet-ready history
- **WHEN** the user opens `intentos.csv` in a spreadsheet
- **THEN** each intento appears as one row with readable temario and tema names

### Requirement: Audio is never re-encoded
Recordings SHALL be copied into the package byte-for-byte in their original format. No transcoding, no quality loss.

#### Scenario: Original file integrity
- **WHEN** a recording is exported
- **THEN** the file in `recordings/` is identical to the file in the app's storage

### Requirement: Offline delivery through the share sheet
Export SHALL work fully offline with no account, produce `opospeak-export.zip`, and hand it to the system share sheet so the user chooses the destination (Files, AirDrop, etc.). While generating, the UI SHALL show progress and prevent duplicate generation.

#### Scenario: Export to Files without network
- **WHEN** the user exports in airplane mode and picks "Guardar en Archivos"
- **THEN** the zip is saved successfully

### Requirement: Missing recordings do not block export
If a grabación's file is missing from disk, the export SHALL continue, include the intento and grabación metadata, omit the missing file, and reflect only actually-copied files in the manifest's grabaciones count.

#### Scenario: Orphaned metadata tolerated
- **WHEN** one of 50 recordings is missing from disk
- **THEN** the export completes with 49 files and counts.grabaciones = 49
