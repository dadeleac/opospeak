## MODIFIED Requirements

### Requirement: Tema detail screen
The tema detail SHALL show the tema's basic information (number, title, temario), its intento history ordered by date descending, and a prominent Practicar action. The Practicar button SHALL be enabled and SHALL launch the full-screen practice flow defined in `practice-recording`.

#### Scenario: Detail of a practiced tema
- **WHEN** the user opens a tema with three intentos
- **THEN** the screen shows the tema info, the three intentos newest first, and the Practicar button as the most prominent action

#### Scenario: Detail of a never-practiced tema
- **WHEN** the user opens a tema with no intentos
- **THEN** the history area shows an empty state inviting the user to practice

#### Scenario: Practicar starts a practice
- **WHEN** the user taps Practicar
- **THEN** the practice screen is presented full screen and recording can begin

### Requirement: Intento detail screen
The intento detail SHALL show date, duration, completion state, and the intento's notes, and SHALL allow adding a note. When the intento has a recording, the detail SHALL include the playback controls defined in `audio-playback`.

#### Scenario: Adding a note
- **WHEN** the user writes "Demasiado rápido al inicio" in the intento detail
- **THEN** a nota is persisted on that intento and appears in its list immediately

#### Scenario: Recording is playable
- **WHEN** the user opens an intento that has a recording on disk
- **THEN** play/pause controls and a progress indicator are available
