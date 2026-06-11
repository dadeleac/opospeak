## MODIFIED Requirements

### Requirement: Complete package structure
The full export SHALL produce a zip whose root contains `manifest.json`, a `data/` directory with `oposiciones.json`, `temarios.json`, `temas.json`, `sesiones.json`, `intentos.json`, `metricas.json`, `notas.json` and `intentos.csv`, and a `recordings/` directory with one audio file per grabación named `<grabacionId>.<formato>`. Nothing SHALL be omitted: all oposiciones (not only the active one), archived temarios and temas, all intentos, all métricas, all notas, and every recording present on disk.

#### Scenario: Package contains everything
- **WHEN** a user with 2 oposiciones, 5 temarios (one archived), 30 temas, 50 intentos and 48 recordings exports
- **THEN** the package contains both oposiciones, the 5 temarios, the 30 temas, the 50 intentos, and 48 files in `recordings/`

### Requirement: Manifest describes and validates the package
`manifest.json` SHALL contain: `format` ("opospeak-export"), `version` (**2**), `exportedAt` (ISO 8601), `appVersion`, `counts` (oposiciones, temarios, temas, sesiones, intentos, grabaciones, notas) and `recordingFormat`. Counts SHALL reflect the actual exported data so a future import can verify integrity.

#### Scenario: Counts match content
- **WHEN** the package is generated
- **THEN** each value in `counts` equals the number of entries in the corresponding JSON file

### Requirement: Open, stable data schema
All JSON files SHALL use ISO 8601 dates, stable UUID identifiers that reconstruct every relationship (oposición → temario → tema → intento → métricas/notas), and human-readable formatting. Each temario entry SHALL carry its `oposicionId`. Recording metadata SHALL remain embedded in its intento's JSON entry with a package-relative file path. The package SHALL be self-sufficient.

#### Scenario: Relationships survive outside OpoSpeak
- **WHEN** the package is read with generic JSON tooling
- **THEN** every temario resolves its oposición by id, every intento its tema, every tema its temario, and every grabación entry points to an existing file in `recordings/`

### Requirement: CSV convenience projection
`intentos.csv` SHALL be a flat projection with header `intentoId,oposicion,temario,tema,numero,fecha,duracionSegundos,completado,tieneGrabacion,tieneNotas` and one row per intento. Fields containing commas or quotes SHALL be escaped per RFC 4180. The CSV SHALL contain nothing that is not already in the JSON files.

#### Scenario: Spreadsheet-ready history
- **WHEN** the user opens `intentos.csv` in a spreadsheet
- **THEN** each intento appears as one row with readable oposición, temario and tema names
