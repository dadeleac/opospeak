## ADDED Requirements

### Requirement: Temario entity
The system SHALL persist a `Temario` entity with a unique identifier, a required name, an optional description, a creation date, and a last-update date. A `Temario` SHALL contain zero or more `Tema` entities and SHALL NOT store recordings, metrics, or results directly.

#### Scenario: Create a temario with minimum information
- **WHEN** a temario is created with only a name
- **THEN** it is persisted with a generated identifier, the given name, a nil description, and creation/update dates set to the current moment

#### Scenario: Temario groups temas
- **WHEN** three temas are added to a temario
- **THEN** the temario's `temas` relationship contains exactly those three temas and each tema's `temario` back-reference points to it

### Requirement: Tema entity
The system SHALL persist a `Tema` entity with a unique identifier, a required number/identifier, an optional title, an active/archived flag, creation and update dates, and a required relationship to its `Temario`. The title SHALL be allowed to be empty because many users work only with numbered topics.

#### Scenario: Create a tema without title
- **WHEN** a tema is created with number 42 and no title
- **THEN** it is persisted successfully and can be displayed as "Tema 42"

#### Scenario: Archive a tema preserves history
- **WHEN** a tema with existing intentos is archived
- **THEN** the tema's active flag is false and all of its intentos, grabaciones, métricas, and notas remain persisted

### Requirement: Sesion entity
The system SHALL persist a `Sesion` entity with a unique identifier, a start date, an optional end date, a type, and optional observations. A sesión SHALL contain zero or more intentos. Sessions are managed automatically by the application; the model SHALL NOT require any user-facing session management.

#### Scenario: Session groups multiple intentos
- **WHEN** two intentos are created within the same sesión
- **THEN** the sesión's `intentos` relationship contains both and each intento references the same sesión

#### Scenario: Session types are extensible
- **WHEN** a sesión is created
- **THEN** its type is one of the initial values (práctica individual, preparador, simulacro) stored in an extensible representation

### Requirement: Intento entity
The system SHALL persist an `Intento` entity — the central unit of analysis — with a unique identifier, start and end dates, a real duration, a completion flag, a required relationship to one `Tema`, and a required relationship to one `Sesion`. An intento SHALL support at most one `Grabacion`, and zero or more `Metrica` and `Nota` entities.

#### Scenario: Intento records a complete practice
- **WHEN** a practice for Tema 42 finishes after 11 minutes 48 seconds
- **THEN** an intento is persisted with the tema, the session, the duration of 708 seconds, and completed = true

#### Scenario: Intento can exist without recording
- **WHEN** an intento is saved without an associated grabación
- **THEN** the intento persists normally and its `grabacion` relationship is nil

### Requirement: Grabacion entity
The system SHALL persist a `Grabacion` entity with a unique identifier, duration, file size, audio format, creation date, and a required relationship to exactly one `Intento`. The audio data SHALL be stored as a file on disk referenced by the model — never as a binary blob inside the database. The model SHALL derive the file location from the grabación's identity rather than storing an absolute path, so that container paths can change between devices and OS updates.

#### Scenario: Recording is stored as a file
- **WHEN** a grabación is created for an intento
- **THEN** the audio exists as an `.m4a` file in the application's storage and the model resolves its URL from the grabación's identifier

#### Scenario: One recording per intento
- **WHEN** a grabación is assigned to an intento that it belongs to
- **THEN** the intento's `grabacion` relationship returns exactly that grabación and the grabación's `intento` points back to it

### Requirement: Metrica entity
The system SHALL persist a `Metrica` entity with a unique identifier, a type, a numeric value, a date, and a required relationship to one `Intento`. The metric type SHALL be extensible so future metrics (speech speed, pauses, muletillas) can be added without schema redesign.

#### Scenario: Duration metric on a completed intento
- **WHEN** an intento completes with a duration of 708 seconds
- **THEN** a métrica of type "duración total" with value 708 can be attached to that intento

### Requirement: Nota entity
The system SHALL persist a `Nota` entity with a unique identifier, text content, a creation date, and a required relationship to one `Intento`. An intento SHALL support multiple notas.

#### Scenario: Add a note after reviewing
- **WHEN** the user writes "Demasiado rápido al inicio" on an intento
- **THEN** a nota with that content and the current date is persisted and appears in the intento's `notas` collection

### Requirement: Delete rules protect practice history
The system SHALL configure delete rules so that deleting a `Temario` cascades to its temas, deleting a `Tema` cascades to its intentos, and deleting an `Intento` cascades to its grabación, métricas, and notas — including removal of the recording file from disk. Deleting a `Sesion` SHALL NOT delete its intentos. The application layer SHALL favor archiving over deletion, and destructive deletes SHALL only happen after explicit confirmation flows defined elsewhere.

#### Scenario: Deleting an intento removes its satellites
- **WHEN** an intento with a grabación, two métricas, and one nota is deleted
- **THEN** the grabación record, its audio file, the métricas, and the nota are all removed

#### Scenario: Deleting a sesión preserves intentos
- **WHEN** a sesión is deleted
- **THEN** its intentos remain persisted with their tema relationship intact

### Requirement: CloudKit-compatible schema
The schema SHALL be compatible with SwiftData + CloudKit mirroring from its first version: all relationships SHALL declare inverses, attributes SHALL be optional or have default values where CloudKit requires it, and no unique constraints incompatible with CloudKit SHALL be used. This change SHALL NOT enable CloudKit sync — only guarantee that enabling it later requires no schema migration.

#### Scenario: Schema validates against CloudKit constraints
- **WHEN** the model container is created with the full schema
- **THEN** every relationship has a declared inverse and the container initializes without errors

### Requirement: Scaffold model removal
The system SHALL remove the scaffold `Item` model and register the seven domain models in the application's `ModelContainer`.

#### Scenario: App launches with the new schema
- **WHEN** the application starts
- **THEN** the ModelContainer is created with Temario, Tema, Sesion, Intento, Grabacion, Metrica, and Nota, and `Item` no longer exists in the codebase
