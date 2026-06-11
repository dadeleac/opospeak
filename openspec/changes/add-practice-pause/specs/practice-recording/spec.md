## MODIFIED Requirements

### Requirement: Minimal recording screen
During recording, the screen SHALL show only: the elapsed time, a recording state indicator, the pause control, and the finish action. There SHALL be no live metrics and no other distractions. The screen SHALL remain awake while actively recording; while paused it MAY sleep.

#### Scenario: Interface disappears
- **WHEN** a recording is in progress
- **THEN** the user sees the timer, a recording indicator, pause, and the finish button — nothing else

#### Scenario: Pausing freezes time
- **WHEN** the user pauses
- **THEN** the timer freezes at the recorded time and the state reads unmistakably as "En pausa", never confusable with recording

## ADDED Requirements

### Requirement: Pause and resume
The user SHALL be able to pause an in-progress recording and resume it later. Audio SHALL continue in the same file with no gap, fragment, or quality change; the elapsed time SHALL count only recorded time. While paused, Finalizar and discard SHALL remain available, and accidental dismissal SHALL stay blocked. Pausing carries no judgment — no metric SHALL penalize it.

#### Scenario: Doorbell mid-practice
- **WHEN** the user pauses at minute 12, answers the door, and resumes three minutes later
- **THEN** the recording continues in the same file and the final audio contains 12 minutes plus the continuation, with no silence gap

#### Scenario: Finishing from pause
- **WHEN** the user finishes while paused
- **THEN** the attempt persists normally with the recorded duration

### Requirement: System interruptions auto-pause
When the system interrupts the audio session (incoming call, Siri), the recording SHALL pause automatically instead of failing. The practice SHALL NOT resume by itself: the user resumes manually when ready. What was recorded before the interruption SHALL never be lost.

#### Scenario: Incoming call
- **WHEN** a call arrives during minute 8 of a recording
- **THEN** the practice pauses automatically, and after the call the user can resume or finish with the 8 minutes intact
