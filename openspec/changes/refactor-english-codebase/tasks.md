## 1. Modelos

- [x] 1.1 Renombrar los 8 modelos y sus propiedades: Opposition, Syllabus, Topic, PracticeSession, Attempt, Recording, Metric, Note (createdAt/updatedAt, isActive, name, number, title, duration, isCompleted, fileSize, content, value, date)
- [x] 1.2 Enums persistidos: `SessionKind`/`MetricKind` con raw values del contrato intactos

## 2. Lógica y almacenamiento

- [x] 2.1 TopicBulkCreator, TopicSortOrder (casos ingleses, títulos localizados), ProgressSummary (AttemptData), SessionPolicy, OnboardingDecision (show/skip/skipAndMark), helpers (displayName, formatDuration)
- [x] 2.2 RecordingStore (forRecordingID, Availability available/downloading/missing), RecordingLocation/RecordingMigrator (MigrationResult), PracticeRepository, PracticeService, OppositionBackfill + ActiveOpposition (clave `activeOppositionID`), SyncStatus (Mode/AccountState, descripción localizada)
- [x] 2.3 PracticeRecorder (State idle/recording/finished/permissionDenied/failed; start/finish/discard; elapsed) y PlaybackController (load/toggle/stop; isPlaying/progress/duration/isAvailable)
- [x] 2.4 Export: DTOs con propiedades inglesas y CodingKeys españolas; nombres de archivo, cabecera CSV y manifest intactos (contrato v2 byte-compatible)

## 3. Vistas y recursos

- [x] 3.1 SyllabusListView, SyllabusDetailView (+NewSyllabusSheet, BulkTopicsSheet), TopicDetailView (+EditTopicSheet), AttemptDetailView, PracticeView, ProgressOverviewView, SettingsView, OnboardingView, ContentView, ShareSheet, Theme — identificadores ingleses, copys españoles intactos
- [x] 3.2 Colorsets renombrados: Ink, Slate, Paper, Sand, ElevatedSand, Sage, Amber, MutedRed; Theme.swift y referencias actualizadas
- [x] 3.3 Clave UserDefaults `onboardingCompletado→onboardingCompleted`

## 4. Internacionalización

- [x] 4.1 `developmentRegion = es` y `knownRegions` en el pbxproj
- [x] 4.2 Crear `Localizable.xcstrings` (idioma fuente: es)
- [x] 4.3 `String(localized:)` en strings de usuario fuera de vistas (sort titles, sync status, errores del recorder)

## 5. Tests

- [x] 5.1 Renombrar suites y funciones de test a inglés manteniendo los asserts
- [x] 5.2 Suite completa en verde (74 tests)
- [x] 5.3 Barrido final: grep de identificadores españoles en código (excluyendo literales y CodingKeys)

## 6. Documentación

- [x] 6.1 `define-core-domain-model`: sección Lenguaje ubicuo con la regla ES-dominio/EN-código y la tabla de correspondencia
- [x] 6.2 README (collaboration rules) y `Current Context.md`
- [x] 6.3 Nota de checklist: resetear schema del contenedor CloudKit de desarrollo
