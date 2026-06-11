## Why

iCloud continuity is part of the MVP by explicit foundation decision (`define-mvp-scope`): "hablamos de años de grabaciones; si un usuario cambia de móvil y pierde todo, el daño percibido es enorme". The schema has been CloudKit-compatible since the first change; the Ajustes row says "Próximamente". This change makes device continuity real — metadata and recordings.

## What Changes

- Activate SwiftData + CloudKit mirroring (private database) so all entities sync through the user's iCloud account — no OpoSpeak account, ever.
- Graceful degradation: if the CloudKit container cannot initialize (no iCloud session, restricted device), the app falls back to local-only storage and keeps working fully offline — local-first is never compromised.
- Recordings sync through the iCloud Drive ubiquity container: the recordings directory moves to the ubiquity container when iCloud is available (local Application Support otherwise), with a one-time migration of existing files.
- Evicted/not-yet-downloaded recordings are detected and downloaded on demand; the intento detail shows a "descargando de iCloud" state instead of "no disponible" when a download is in progress.
- Ajustes shows real sync status (activa / sin cuenta iCloud / desactivada) replacing the placeholder row.
- Entitlements completed: CloudKit container identifier and ubiquity container identifier (CloudKit service + aps-environment already present).
- Remote-notification background mode so CloudKit pushes can trigger sync.

## Capabilities

### New Capabilities

- `icloud-metadata-sync`: SwiftData+CloudKit activation, fallback behavior, and the constraint that sync follows the system account with no app-level login.
- `recordings-sync`: recordings in the ubiquity container — location resolution, one-time migration, on-demand download of evicted files.
- `sync-status`: the user-visible sync state in Ajustes.

### Modified Capabilities

- `navigation-shell`: the Ajustes iCloud row changes from placeholder to live status.

## Impact

- `opospeak.entitlements`: container identifiers added.
- `opospeakApp.swift`: CloudKit-first container creation with local fallback; recordings directory resolution at startup.
- New: `Storage/RecordingLocation.swift` (ubiquity/local resolution + migration), `Storage/SyncStatus.swift` (observable account/mode state).
- Modified: `RecordingStore` (download-on-demand awareness), `AjustesView` (status row), `IntentoDetailView` (downloading state), `PracticeView`/`IntentoDetailView`/`ExportService` construction sites (injected store location).
- Tests: migration between directories, location resolution, evicted-placeholder detection (pure file-system logic; CloudKit itself is not unit-testable).
- Requires a signed-in iCloud account on device/simulator for real sync; everything else works without it.
