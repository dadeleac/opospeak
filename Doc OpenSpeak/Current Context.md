
This document is the living handoff for OpoSpeak.

It should allow a new conversation to understand the current state of the product without reading previous discussions.

## Product State

OpoSpeak is an Apple-first application for long-term oral exam preparation.

The product is designed for competitive examinations that require oral exposition or topic recitation.

Examples include:

- Judiciary
- Public Prosecutors
- Court Clerks
- Notaries
- Property Registrars
- Tax Inspectors
- Diplomats

OpoSpeak is not an academy, a legal platform, a test application, or an AI tutor.

It is a practice and progress tracking tool for oral preparation.

---

## Core Thesis

The problem is not recording a topic.

The problem is managing years of oral practice.

OpoSpeak exists to organize, preserve, and visualize that practice history.

---

## Current Product Direction

The current strategy is based on:

- Apple-first
- Local-first
- Privacy-first
- No proprietary backend
- iCloud continuity
- Offline operation
- Open export
- Long-term progress tracking

The application should feel closer to a premium training notebook than to an educational platform.

---

## Foundation Documents

The following documents define the stable foundations of the product:

- product-foundation
- core-domain-model
- local-first-data-strategy
- privacy-and-export-strategy
- mvp-scope
- color-system-and-visual-identity
- apple-human-interface-guidelines-compliance
- wcag-accessibility-compliance

These documents should evolve rarely and only through deliberate decisions.

---

## Current MVP Scope

The MVP focuses on:

- Temarios
- Temas
- Oral practice
- Audio recording
- Attempts
- History
- Notes
- Basic progress indicators
- Export
- iCloud continuity

The MVP explicitly excludes:

- AI
- Transcription
- Voice analysis
- Trainer collaboration
- Community features
- Gamification

---

## Current Design Direction

The product should communicate:

- concentration
- discipline
- progress
- calm confidence

The visual identity is based on:

- Deep Ink
- Warm Sand
- Editorial aesthetics
- Native Apple patterns

The product should not resemble:

- a legal application
- a dashboard
- a SaaS platform
- a productivity tool

---

## Current Technical Direction

Preferred stack:

- SwiftUI
- SwiftData
- CloudKit
- Native Apple frameworks

Architecture principles:

- Simplicity over abstraction
- Native solutions over custom frameworks
- Local-first data ownership
- Open export formats

---

## Implementation State

The SwiftData domain model is implemented (OpenSpec change `add-swiftdata-domain-model`, completed):

- Seven `@Model` classes: Temario, Tema, Sesion, Intento, Grabacion, Metrica, Nota.
- Relationships and delete rules per `define-core-domain-model` (cascade protects nothing it shouldn't; deleting a Sesion never deletes Intentos).
- CloudKit-compatible schema from day one (inverses everywhere, optionals/defaults, no unique constraints); sync itself is not enabled yet.
- Recordings stored as files resolved by identity (`RecordingStore`); intento deletion goes through `PracticeRepository` so audio files are never orphaned.
- Unit tests (Swift Testing, in-memory containers) cover creation, relationships, cascade/nullify, archiving, and file cleanup. Suite is green.

The information architecture is implemented (OpenSpec change `add-information-architecture`, completed):

- Three-tab shell (Temarios, Progreso, Ajustes), each with its own NavigationStack; sessions invisible; no Practicar tab.
- Temario management: list with activity, create (name only), archive via swipe, empty state. `Temario.activo` added to the schema (additive).
- Tema management: list (number/title/last attempt/count), single creation with suggested number, bulk creation 1..N (`TemaBulkCreator`), search, five sort orders (`TemaSortOrder`), archive, empty states.
- Tema detail with prominent (disabled) Practicar button and intento history; intento detail with notes (add note works).
- Progreso derives volumen/consistencia/cobertura/distribución at read time (`ProgressSummary`); Ajustes shows privacy statement and placeholders for export/iCloud.
- Pure logic unit-tested (bulk creation, sorting, progress, duration formatting); full suite green.

The practice flow is implemented (OpenSpec change `add-practice-flow`, completed):

- Practicar launches a full-screen recording experience: timer + recording indicator + finish, no pause, screen stays awake, discard deletes the partial file.
- `PracticeRecorder` (AVAudioRecorder, AAC/m4a mono 64 kbps) records straight to the RecordingStore location; microphone permission requested in context, denied state links to system settings.
- `PracticeService` is the single write path on finish: Intento + Grabación + Métrica (duración total) + session `fechaFin` in one save; file exists on disk before models.
- Sessions are invisible: `SesionPolicy` reuses a sesión within a 30-minute inactivity window, otherwise creates one.
- Closing summary (tema, duración, fecha, grabación guardada); intento appears in the tema history immediately.
- Playback in the intento detail (`PlaybackController` over AVAudioPlayer): play/pause + progress, stops on leaving, "grabación no disponible" for orphaned metadata.
- Fixed a latent RecordingStore bug: `URL.path()` percent-encodes "Application Support", breaking FileManager checks.
- Full suite green (35 tests).

The app is now end-to-end usable: create temario → temas → practice → record → review → listen.

Export is implemented (OpenSpec change `add-export`, completed):

- Full package from Ajustes: `opospeak-export.zip` with manifest.json (format/version/counts for future import validation), data/ (6 JSON files + intentos.csv with RFC 4180 escaping) and recordings/ (byte-identical m4a copies), per `define-export-format`.
- Grabación metadata embedded in each intento's JSON entry (v1 decision per the foundation's lean); relative file paths; ISO 8601; stable UUIDs; archived data included; missing files tolerated and reflected in counts.
- Single-intento package (intento.json + notas.json + audio) shared from the intento detail toolbar.
- Export DTOs (`ExportModels`) decoupled from SwiftData models — the package schema is a public contract.
- Native zip via NSFileCoordinator `.forUploading` (no dependencies); system share sheet; works offline; temp artifacts cleaned up.
- Full suite green (45 tests).

iCloud sync is implemented (OpenSpec change `add-icloud-sync`, completed):

- SwiftData + CloudKit private-database mirroring for all entities; sync follows the system iCloud account — no app-level login, ever.
- Bulletproof fallback: if the CloudKit store cannot initialize, the app falls back to local-only storage and works completely (local-first never compromised).
- Recordings sync via the iCloud Drive ubiquity container: `RecordingLocation` resolves the directory at startup (off-main), `RecordingMigrator` moves local files once (idempotent, copy-verify-delete, never destructive).
- Evicted files (`.icloud` placeholders) download on demand; the intento detail shows "Descargando de iCloud…" distinct from "no disponible".
- `AppEnvironment` centralizes the resolved RecordingStore (replacing ad-hoc constructions) and `SyncStatus` powers the honest Ajustes row (Activa / Sin cuenta de iCloud / No disponible) with zero nagging.
- Entitlements completed (CloudKit + CloudDocuments + ubiquity container `iCloud.com.daviddeleonacosta.opospeak`); remote-notification background mode added.
- Full suite green (54 tests). Real device-to-device sync requires a manual check with a signed-in iCloud account (consistent with the foundation's audit gates); CloudKit schema deploy to production is a TestFlight-checklist step.

Onboarding is implemented (OpenSpec change `add-onboarding`, completed):

- Three-phase first-run flow over the Temarios tab: brief welcome (privacy visible, single "Empezar" action) → first temario (name only, tappable examples) → bulk temas ("¿Cuántos temas tiene tu temario?" with quick-pick shortcuts), landing directly inside the created temario.
- Every step skippable; work persists at phase transitions (abandoning after the temario keeps it); dismissal ends onboarding permanently and empty states take over.
- `OnboardingDecision` (pure, tested): shows only for genuinely new users — data restored via iCloud on a new device silently marks onboarding complete.
- `onboardingCompletado` lives in UserDefaults (device-local UX, deliberately NOT synced).
- No permissions upfront, no account, no sample data, no carousel. Full suite green (57 tests).

Remaining MVP change: visual identity (Deep Ink / Warm Sand theming). Import/restore of export packages is a natural post-MVP change (manifest fields already support validation).

---

## Recently Resolved

- Information architecture defined in `define-information-architecture` (three tabs: Temarios, Progreso, Ajustes; Practicar always launches from a Tema; Sesión stays invisible; one Tema per Intento in the MVP).
- Onboarding flow defined in `define-onboarding-flow` (no tutorial carousel, no mandatory account, permissions requested in context; goal is first practice in under two minutes).
- Export and backup package structure defined in `define-export-format` (open JSON as source of truth, CSV convenience view, untouched m4a recordings, importable manifest-versioned package).

---

## Known Open Questions

The following decisions remain open:

- Import strategy (beyond reimporting an OpoSpeak package)
- Premium model details
- Future trainer workflows
- Future AI boundaries
- Multi-topic extraction (intermediate entity), deferred until after MVP validation
- Whether recording metadata ships inside `intentos.json` or a separate `grabaciones.json`

---

## Collaboration Rules

Use OpenSpec for significant product, domain, architecture, navigation, data, privacy, or monetization changes.

Prefer small and deliberate decisions.

Challenge scope creep.

Protect the product thesis.

Do not introduce features that move OpoSpeak toward becoming:

- an academy
- a legal platform
- a social network
- an AI tutor

without an explicit strategic decision.

---

## Update Policy

Update this document whenever any of the following changes:

- product vision
- MVP scope
- privacy model
- storage strategy
- synchronization strategy
- monetization strategy
- design direction
- foundation documents
- technical direction

Keep this document concise.

Link to foundation and OpenSpec documents instead of duplicating them.