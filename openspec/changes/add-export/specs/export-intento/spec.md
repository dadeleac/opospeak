## ADDED Requirements

### Requirement: Single-intento package
From the intento detail, the user SHALL be able to export one intento as a reduced package: a zip containing `intento.json` (intento data with embedded grabación metadata, plus tema and temario context), `notas.json`, and the audio file when it exists on disk. The schema SHALL match the full package's conventions (ISO 8601, UUIDs, relative file path).

#### Scenario: Share one practice with a preparador
- **WHEN** the user exports an intento with a recording and two notes
- **THEN** the zip contains intento.json, notas.json with both notes, and the m4a file

#### Scenario: Intento without recording
- **WHEN** the user exports an intento that has no grabación
- **THEN** the zip contains intento.json and notas.json only

### Requirement: Entry point in the intento detail
The intento detail SHALL offer the export action through the standard share affordance in its toolbar, delivered via the system share sheet.

#### Scenario: Export from the detail
- **WHEN** the user taps the share action in an intento detail
- **THEN** the reduced package is generated and the share sheet opens
