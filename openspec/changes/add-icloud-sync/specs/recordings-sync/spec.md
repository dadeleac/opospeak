## ADDED Requirements

### Requirement: Recordings live in the ubiquity container when available
When the user has an active iCloud session, recordings SHALL be stored in the app's iCloud Drive ubiquity container so they sync across devices. Without iCloud, recordings SHALL be stored locally as today. The resolution SHALL happen at startup and be transparent to the rest of the app (RecordingStore keeps its identity-based API).

#### Scenario: Recording on one device, listening on another
- **WHEN** the user records a practice on their iPhone and later opens the intento on a new device with the same iCloud account
- **THEN** the recording is available for playback (after download)

#### Scenario: No iCloud, fully local
- **WHEN** there is no iCloud session
- **THEN** recordings are stored in local Application Support exactly as before this change

### Requirement: One-time migration of existing recordings
When the ubiquity container becomes available and local recordings exist, they SHALL be moved into the ubiquity container once, preserving their identity-based file names. Migration SHALL be idempotent and SHALL never lose a file: on any per-file error the local copy stays in place and remains playable.

#### Scenario: Existing user enables iCloud
- **WHEN** a user with 50 local recordings signs into iCloud and relaunches
- **THEN** the 50 files move to the ubiquity container and every intento keeps its playable recording

### Requirement: Evicted recordings download on demand
A recording present in iCloud but not on the local device (placeholder `.icloud` file) SHALL trigger a download when its intento detail is opened. The UI SHALL distinguish "descargando de iCloud" (download in progress) from "grabación no disponible" (file truly missing).

#### Scenario: Listening to an evicted recording
- **WHEN** the user opens an intento whose audio is in iCloud but not downloaded
- **THEN** the download starts automatically and the detail shows a downloading state until the player becomes available
