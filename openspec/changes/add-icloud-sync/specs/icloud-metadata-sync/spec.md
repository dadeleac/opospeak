## ADDED Requirements

### Requirement: CloudKit mirroring of all entities
The application SHALL mirror all seven domain entities to the user's private CloudKit database through SwiftData. Sync SHALL follow the system's iCloud account exclusively: no app-level account, login, or registration SHALL exist.

#### Scenario: New device continuity
- **WHEN** the user signs into the same iCloud account on a new device and installs OpoSpeak
- **THEN** temarios, temas, sesiones, intentos, métricas and notas appear without any in-app action

### Requirement: Local fallback never blocks the app
If the CloudKit-backed store cannot initialize (no iCloud session, restricted device, container error), the application SHALL fall back to a local-only store and function completely. Local-first operation SHALL never be compromised by sync availability.

#### Scenario: No iCloud session
- **WHEN** the app launches on a device with no iCloud account signed in
- **THEN** the app works fully (create, practice, record, review) with local storage and Ajustes shows sync as unavailable

### Requirement: Sync is silent
Synchronization SHALL happen in the background without progress dialogs, blocking spinners, or sync-triggered interruptions to the practice flow.

#### Scenario: Practice is never interrupted
- **WHEN** a sync occurs while the user is recording a practice
- **THEN** the recording continues unaffected
