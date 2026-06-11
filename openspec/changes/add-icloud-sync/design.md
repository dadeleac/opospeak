## Context

The schema has been CloudKit-compatible since `add-swiftdata-domain-model` (inverses everywhere, optionals/defaults, no unique constraints) precisely so activation would be a flag, not a migration. The entitlements file already has the CloudKit service enabled (empty container list); a real development team is configured. Two distinct sync problems exist: structured data (SwiftData+CloudKit handles it) and audio files (SwiftData+CloudKit does NOT sync external files — the domain-model design explicitly deferred this decision to now).

## Goals / Non-Goals

**Goals:**

- CloudKit private-database mirroring for all entities, with bulletproof local fallback.
- Recordings synced via the iCloud Drive ubiquity container, with one-time migration and download-on-demand.
- Honest status in Ajustes; zero nagging.
- Pure file-system logic (location, migration, placeholder detection) unit-tested.

**Non-Goals:**

- No conflict-resolution UI (CloudKit last-writer-wins is acceptable for single-user data).
- No selective sync, no sync toggles (follows the system account, period).
- No sharing/collaboration (CloudKit shared database) — preparador workflows are post-MVP.
- No storage-quota management UI.

## Decisions

### 1. Recordings via ubiquity container, not CKAsset

SwiftData+CloudKit cannot attach external files; the alternatives are (a) manual CKAsset records — a parallel sync engine to build and maintain, (b) `@Attribute(.externalStorage)` blobs inside the model — recordings become database payload, breaking the foundation's "recordings are independent files" and bloating the store, or (c) the iCloud Drive ubiquity container — the system syncs files in `Documents/Recordings/` with zero sync code. (c) wins: native, file-based, matches `define-local-first-data-strategy` ("metadata as structured data; recordings as independent files"). Cost: download-on-demand handling for evicted files, accepted and specced.

### 2. `RecordingLocation` resolves the directory once at startup

`RecordingLocation.resolve()` returns the ubiquity `Documents/Recordings` URL when `FileManager.url(forUbiquityContainerIdentifier:)` yields one (called off the main thread, as documented), else local Application Support. The result is injected into every `RecordingStore` construction site through a small environment-like holder (`AppEnvironment.recordingStore`). Rationale: today each view builds `RecordingStore()` ad hoc with the local default; sync makes the directory dynamic, so construction must centralize. This also removes a latent inconsistency (multiple hardcoded constructions).

### 3. Migration: move, verify, idempotent

`RecordingMigrator.migrate(from:to:)` moves every `*.m4a` not already present at the destination; per-file failures leave the local copy untouched (copy-then-delete, not move, so a crash mid-file never loses audio). Runs at startup only when source has files and destination is ubiquity. Pure function over two URLs → fully unit-testable with temp directories.

### 4. Evicted files: placeholder detection + `startDownloadingUbiquitousItem`

In the ubiquity container, an evicted file appears as `.<name>.icloud`. `RecordingStore.availability(forGrabacionId:)` returns `.disponible(URL)` / `.descargando` / `.ausente`: if the real file is missing but the placeholder exists, it calls `startDownloadingUbiquitousItem` and reports `.descargando`. The intento detail polls availability with a short timer while in `.descargando`. Rationale: NSMetadataQuery is the "proper" observer but is heavyweight for one file; polling a file's existence for the seconds a 5 MB download takes is simpler and contained.

### 5. CloudKit container with explicit fallback chain in `opospeakApp`

Try `ModelConfiguration(cloudKitDatabase: .private("iCloud.com.daviddeleonacosta.opospeak"))`; on throw, retry with `.none`; only then `fatalError`. The chosen mode lands in `SyncStatus` (@Observable), which also queries `CKContainer.accountStatus()` for the Ajustes row. Rationale: the current code fatalErrors on any container failure — unacceptable once a network-dependent backend enters the equation.

### 6. Entitlements completed in-place

Add `iCloud.com.daviddeleonacosta.opospeak` to `icloud-container-identifiers`, add `com.apple.developer.ubiquity-container-identifiers` with the same id, and add iCloud Documents to `icloud-services`. `aps-environment` already present; add `INFOPLIST_KEY_UIBackgroundModes = remote-notification` for silent sync pushes. Real CloudKit traffic requires the container to exist in the developer account — first build with automatic signing provisions it; the fallback covers any interim state.

## Risks / Trade-offs

- [CloudKit container not yet provisioned in the developer account] → Automatic signing creates it on first device build; until then the fallback keeps the app fully local. Verified status surfaces in Ajustes, not as errors.
- [Ubiquity container availability check needs a background thread at startup] → Resolved async during launch; until resolution completes, the store uses the local directory (recordings made in that window are picked up by the next migration pass, which runs every launch and is idempotent).
- [User disables iCloud later] → Ubiquity URL returns nil → store resolves local; previously synced files remain in iCloud Drive (system behavior, user-visible in Files). Accepted; documented behavior.
- [Polling for download completion] → Bounded (only while detail visible, 0.5s interval), trivially replaceable by NSMetadataQuery if it ever matters.
- [Simulator sync testing requires signed-in account] → Unit tests cover the pure logic; end-to-end sync is a manual device check, consistent with the foundation's audit gates.

## Migration Plan

1. Entitlements + background mode (build settings).
2. `RecordingLocation` + `RecordingMigrator` + availability API (testable, no behavior change while ubiquity is nil).
3. Container fallback chain + `SyncStatus` + Ajustes row.
4. Wire injected store through construction sites; downloading state in intento detail.

Rollback: revert; with entitlements removed the app builds and runs local-only as before.

## Open Questions

- None blocking. CloudKit schema deploy to production (Console step) is part of the TestFlight checklist, not this change.
