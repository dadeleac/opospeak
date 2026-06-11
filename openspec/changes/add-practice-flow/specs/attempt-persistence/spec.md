## ADDED Requirements

### Requirement: Finishing persists the complete intento
When the user finishes a practice, the system SHALL persist atomically: an Intento (start/end dates, real duration, completado = true, linked to the tema and the active sesión), its Grabación (duration, file size, format), and a Métrica of type duración total. The recording file SHALL already be on disk before the models are saved.

#### Scenario: Complete persistence on finish
- **WHEN** the user finishes an 11m 48s practice of Tema 42
- **THEN** an intento with duración 708s and completado = true, a grabación with the file's real size, and a duración-total métrica with value 708 are persisted together

#### Scenario: File before models
- **WHEN** persistence runs
- **THEN** the audio file exists on disk before the intento is saved, so a crash never yields an intento whose recording is missing

### Requirement: Closing summary
After finishing, the user SHALL see a simple summary: tema, duration, date, and recording availability. From the summary the user SHALL be able to return to the tema detail, where the new intento appears in the history.

#### Scenario: Summary after practice
- **WHEN** a practice finishes
- **THEN** the summary shows the tema name, the formatted duration, today's date, and that the recording is available

#### Scenario: History reflects the attempt immediately
- **WHEN** the user closes the summary
- **THEN** the tema detail shows the new intento at the top of its history
