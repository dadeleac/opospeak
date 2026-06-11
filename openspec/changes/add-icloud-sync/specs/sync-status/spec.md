## ADDED Requirements

### Requirement: Honest sync status in Ajustes
Ajustes SHALL show the real synchronization state: "Activa" when the CloudKit store is in use and the iCloud account is available, "Sin cuenta de iCloud" when no account is signed in, and "No disponible" when the store fell back to local for any other reason. The status SHALL be informative facts, not warnings or nags — the app never pressures the user into signing in.

#### Scenario: Synced state
- **WHEN** the user opens Ajustes with iCloud working
- **THEN** the iCloud row shows "Activa"

#### Scenario: No account, no nagging
- **WHEN** there is no iCloud session
- **THEN** the row states the fact and the app never shows sign-in prompts elsewhere
