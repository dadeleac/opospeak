## ADDED Requirements

### Requirement: Playback from the intento detail
The intento detail SHALL play the intento's recording with play/pause and a progress indicator showing elapsed and total time. Playback SHALL stop automatically when the view disappears.

#### Scenario: Listening to a past practice
- **WHEN** the user taps play on an intento with a recording
- **THEN** the audio plays from the start, the progress advances, and pause halts it

#### Scenario: Leaving stops playback
- **WHEN** the user navigates away during playback
- **THEN** the audio stops

### Requirement: Missing file is handled gracefully
If the recording file cannot be found or loaded, the intento detail SHALL state that the recording is unavailable instead of failing.

#### Scenario: Orphaned metadata
- **WHEN** an intento's grabación exists but its audio file is missing from disk
- **THEN** the detail shows "grabación no disponible" and offers no broken player
