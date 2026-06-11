
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

The visual identity is implemented (OpenSpec change `add-visual-identity`, completed):

- Semantic color system as asset-catalog colorsets with tuned dark variants: Tinta (Deep Ink, global tint via AccentColor), Pizarra, Papel (#F8F7F4) as the screen background, Arena (+ ArenaElevada) reserved for warm highlighted surfaces, Salvia, Ámbar, Rojo Apagado. Xcode-generated symbols; views never see hex. (Background amended to Papel after visual validation; Arena keeps its foundation role.)
- Dark variants lightened for contrast (ink-tinted near-black background — "nocturnal reading", not pure black); AA contrast verified for text-bearing pairs.
- Restrained application: editorial sand background on persistent screens (creation sheets keep system backgrounds), Ámbar for archive swipes, Rojo Apagado for recording/destructive, Salvia for positive confirmation. No layout/behavior/typography changes.
- Resolution test guards every colorset (existence + distinct dark variant). Full suite green (66 tests).

**The MVP feature set is complete**: domain model, three-tab IA, practice recording, export, iCloud sync, onboarding, and visual identity — all spec'd through OpenSpec and tested.

---

## Domain Refactor: Oposición → Temarios → Temas

MVP validation caught Temario acting as the system root ("Judicatura" created as a temario). Implemented in OpenSpec change `refactor-opposition-domain` (completed):

- New root entity `Oposicion` (Spanish ubiquitous language confirmed): Judicatura/Notarías/Inspección de Hacienda are oposiciones; Civil/Penal/Procesal are temarios. The rest of the chain is unchanged.
- Domain, storage and relationships fully support multiple oposiciones; the UI operates on one **active** oposición (device-local pointer, deliberately unsynced). No oposición picker yet — and no oposición deletion in UI (root cascade erases everything; rename only, from Ajustes).
- Idempotent startup backfill adopts pre-refactor orphan temarios under "Mi oposición" (or the first existing oposición).
- Onboarding gained the oposición phase (bienvenida → oposición → temario → temas) with level-correct examples; the Temarios tab is titled with the active oposición's name; creation sheet shows oposición context.
- Tema editing UX added (number + title from the tema detail) — titles never required to practice; closes the gap with `define-topic-management-flow`.
- Export format **v2**: `oposiciones.json`, `oposicionId` in temarios, `oposicion` CSV column, manifest counts. Safe bump (no importers exist).
- Six foundation documents corrected; all suites updated; full suite green (74 tests).

---

## Code Language & Localization Refactor

Implemented in OpenSpec change `refactor-english-codebase` (completed):

- **Language policy** (annotated in `define-core-domain-model`): Spanish for product/docs/UI; English for all code identifiers, with the official mapping Oposición→`Opposition`, Temario→`Syllabus`, Tema→`Topic`, Sesión→`PracticeSession`, Intento→`Attempt`, Grabación→`Recording`, Métrica→`Metric`, Nota→`Note`.
- Every Swift identifier renamed (models, logic, storage, audio, views, tests, UserDefaults keys); color tokens renamed to English (Ink, Slate, Paper, Sand, ElevatedSand, Sage, Amber, MutedRed).
- **Localization**: development language is Spanish (`developmentRegion = es`); `Localizable.xcstrings` added; SwiftUI literals auto-extract; non-View user strings use `String(localized:)`. Future languages are catalog entries.
- **Export contract preserved (Option A)**: Spanish JSON keys/file names/CSV header/raw values via explicit `CodingKeys`; a dedicated test asserts the Spanish contract keys survive.
- Local stores reset (no users). **Release-checklist note: reset the dev CloudKit container schema in the Console before the next device build** (entity names changed).
- Full suite green (75 tests).

---

## Practice Pause

Implemented in OpenSpec change `add-practice-pause` (completed):

- Pause/resume during practice: same m4a file, no gap, timer counts recorded time only. Foundation's original no-pause decision deliberately reversed in `define-practice-session-flow` (its technical fears were disproved by the implementation).
- System interruptions (calls, Siri) auto-pause instead of failing; resume is always manual; pre-interruption audio is never lost.
- Duration semantics fixed: `Attempt.duration` = recorded speaking time, passed explicitly to `PracticeService.finish` (never derived from wall-clock dates — the silent-corruption bug pause would have caused). `startedAt`/`endedAt` remain wall times; export contract unchanged.
- Paused UI: Amber icon + "En pausa" (never color alone), Reanudar prominent, Finalizar/discard available; screen may sleep while paused; swipe-dismiss blocked in both states. No metric judges pausing.
- Key test: 22 wall-clock minutes with 10 paused → persisted duration is 12 (suite green, 76 tests). Manual device check pending: real pause/resume audio continuity and incoming-call auto-pause.

---

## Exam Timer

Implemented in OpenSpec change `add-exam-timer` (completed):

- **No auto-start**: a preparation phase (restoring the foundation's "Preparar práctica" step) shows the topic and timer configuration with a single Empezar action; the mic permission is requested at that tap. Cancel is free before starting.
- **Two timer modes**: count-up and countdown with user-chosen target (stepper + quick picks), mirroring the oral exam clock. Configuration is remembered device-locally (`PracticeTimerConfig` in UserDefaults).
- **Configurable warnings** at user-chosen remaining marks (10/5/2/1 min, filtered below target): haptic + visual (Amber bell + text, never color alone) + VoiceOver announcement. **Never sound** — the open microphone would capture it. Marks run on recorded time, so pause freezes them for free; each fires exactly once (`WarningSchedule`, pure and table-tested).
- **Overtime continues**: at zero the display shows "+excess" in MutedRed with "Tiempo agotado"; no cut-off, no judgment.
- **`targetDelta` metric activated** (unused since the domain change): countdown practices persist duración − objetivo, enabling the longitudinal question "¿me ajusto al tiempo de examen?". Count-up practices don't produce it.
- Foundation amended (`define-practice-session-flow`: Preparación, Inicio de intento, Avisos). Suite green (87 tests). Manual device check pending: real haptics and warning timing.
- **Flow refined after review (decide → place → speak)**: preparation compresses the config into a one-line tappable summary (form expands on demand); **Continuar** requests the mic permission without recording; a **Listo** screen invites placing the phone on a stand and shows the idle clock; **Grabar** is the only control that turns the microphone on — recordings no longer start with handling noise. Vocabulary audited: Continuar / Grabar / Pausar / Reanudar / Finalizar / Hecho ("Empezar" remains only in onboarding). Cancel free in both pre-recording moments.

Next steps toward release (not feature changes): manual device pass (real recording, device-to-device iCloud sync), the foundation's mandatory accessibility audits (VoiceOver + Dynamic Type full pass before TestFlight), CloudKit schema deploy to production, app icon, and the one-time purchase setup. Import/restore of export packages is a natural post-MVP change.

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