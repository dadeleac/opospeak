## MODIFIED Requirements

### Requirement: Finishing persists the complete intento
When the user finishes a practice, the system SHALL persist atomically: an Intento (wall-clock start/end dates, **duration = recorded speaking time**, completado = true, linked to the tema and the active sesión), its Grabación (duration, file size, format), and a Métrica of type duración total. The recorded duration SHALL be measured by the recorder (time actually captured), never derived from wall-clock dates — a paused practice's duration excludes the paused gaps. The recording file SHALL already be on disk before the models are saved.

#### Scenario: Complete persistence on finish
- **WHEN** the user finishes an 11m 48s practice of Tema 42
- **THEN** an intento with duración 708s and completado = true, a grabación with the file's real size, and a duración-total métrica with value 708 are persisted together

#### Scenario: Paused practice stores spoken time
- **WHEN** a practice spans 22 wall-clock minutes with 10 minutes paused
- **THEN** the persisted duration is 12 minutes — matching the audio — and Progreso's accumulated time stays truthful

#### Scenario: File before models
- **WHEN** persistence runs
- **THEN** the audio file exists on disk before the intento is saved, so a crash never yields an intento whose recording is missing
