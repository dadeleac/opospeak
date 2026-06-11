## ADDED Requirements

### Requirement: Tema detail screen
The tema detail SHALL show the tema's basic information (number, title, temario), its intento history ordered by date descending, and a prominent Practicar action. Until the practice flow ships, the Practicar button SHALL be visible but disabled, communicating that recording arrives in an upcoming version.

#### Scenario: Detail of a practiced tema
- **WHEN** the user opens a tema with three intentos
- **THEN** the screen shows the tema info, the three intentos newest first, and the Practicar button as the most prominent action

#### Scenario: Detail of a never-practiced tema
- **WHEN** the user opens a tema with no intentos
- **THEN** the history area shows an empty state inviting the user to practice

### Requirement: Intento history rows
Each intento row SHALL show at minimum: date, duration, and whether it has a recording and notes.

#### Scenario: Row summary
- **WHEN** an intento lasted 11m 48s, has a recording, and one note
- **THEN** its row shows the date, "11:48", and indicators for recording and notes

### Requirement: Intento detail screen
The intento detail SHALL show date, duration, completion state, and the intento's notes. The user SHALL be able to add a note from this screen. Audio playback controls are introduced by the practice-flow change, not this one.

#### Scenario: Adding a note
- **WHEN** the user writes "Demasiado rápido al inicio" in the intento detail
- **THEN** a nota is persisted on that intento and appears in its list immediately
