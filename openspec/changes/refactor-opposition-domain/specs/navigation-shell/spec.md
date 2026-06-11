## MODIFIED Requirements

### Requirement: Minimal Ajustes content
The Ajustes tab SHALL contain only what does not belong to the practice flow: app information (name, version), a visible privacy statement (local-first, no account, user owns the data), an editable **Oposición** row showing the active oposición's name (rename only — no oposición deletion), a functional "Exportar mis datos" action that generates the full export package defined in `export-package`, and a live iCloud synchronization status row as defined in `sync-status`. Ajustes SHALL NOT become a feature drawer.

#### Scenario: Ajustes shows privacy promise
- **WHEN** the user opens Ajustes
- **THEN** they see the app version and a clear statement that data is local and theirs

#### Scenario: Renaming the oposición
- **WHEN** the user edits the Oposición row from "Mi oposición" to "Judicatura"
- **THEN** the Temarios tab title updates and no data is touched

#### Scenario: Export from Ajustes
- **WHEN** the user taps "Exportar mis datos"
- **THEN** the package is generated with visible progress and the share sheet opens with `opospeak-export.zip`

#### Scenario: Live sync status
- **WHEN** the user opens Ajustes
- **THEN** the iCloud row reflects the real synchronization state instead of a placeholder
