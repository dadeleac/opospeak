## ADDED Requirements

### Requirement: Practice launches from the tema
The practice experience SHALL launch only from a tema's Practicar action, presented full screen. The path SHALL be: tema → Practicar → recording, with no intermediate configuration screens.

#### Scenario: Three-step start
- **WHEN** the user taps Practicar on a tema
- **THEN** recording starts (after permission, if not yet granted) and the practice screen is shown full screen

### Requirement: Microphone permission in context
The microphone permission SHALL be requested the first time the user starts a practice, never at app launch. If permission is denied, the practice screen SHALL explain why recording is unavailable and offer a path to system settings; it SHALL NOT persist an intento.

#### Scenario: First practice asks permission
- **WHEN** the user starts their first practice and has never been asked
- **THEN** the system permission dialog appears in that moment, with the usage description explaining recording is for oral practice

#### Scenario: Denied permission explains itself
- **WHEN** the user starts a practice with microphone permission denied
- **THEN** the screen explains recording is unavailable, links to Ajustes del sistema, and nothing is persisted

### Requirement: Minimal recording screen
During recording, the screen SHALL show only: the elapsed time, a recording state indicator, and the finish action. There SHALL be no pause control (continuous practice is a foundation decision), no live metrics, and no other distractions. The screen SHALL remain awake while recording.

#### Scenario: Interface disappears
- **WHEN** a recording is in progress
- **THEN** the user sees the timer, a recording indicator, and the finish button — nothing else

#### Scenario: No pause available
- **WHEN** the user looks for a pause control during recording
- **THEN** none exists; the only exits are finishing or discarding

### Requirement: Recording format and destination
Audio SHALL be recorded as AAC in an `.m4a` container, written directly to the location resolved by `RecordingStore` for a pre-assigned grabación identity. No re-encoding SHALL happen after recording.

#### Scenario: File lands in its final home
- **WHEN** a practice finishes
- **THEN** the audio file already exists at `Recordings/<grabacionId>.m4a` with no copy or conversion step

### Requirement: Discard semantics
The user SHALL be able to abandon a practice without saving. Discarding SHALL stop the recording, delete the partial audio file, and persist no intento, grabación, métrica, or sesión activity.

#### Scenario: Abandon a practice
- **WHEN** the user discards an in-progress practice
- **THEN** no data is persisted and the partial audio file is removed
