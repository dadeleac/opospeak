## Why

Two connected gaps. First, recording starts automatically the moment the practice screen opens — skipping the "Preparar práctica" step the foundation's conceptual flow always had. Second, the real oral exam runs on a **countdown** the candidate watches; training against that clock — and knowing over time whether you fit the exam slot — is the true long-term value of the recordings. The model has been waiting for this: `MetricKind.targetDelta` ("diferencia_objetivo") exists unused since the first change, and the foundation lists "objetivo de duración" as planned topic information.

## What Changes

- **No auto-start**: a new preparation (ready) phase shows the topic and timer configuration with a single prominent **Empezar** action. The microphone permission is requested on tap — even more in-context than today.
- **Two timer modes**: count-up (today's) and **countdown** with a user-chosen target duration.
- **User-configured warnings**: the user picks at which remaining-time marks to be warned (e.g. 5 min and 1 min left). Warnings are **haptic + visual + VoiceOver announcement — never sound**: the microphone is open and a speaker beep would pollute the recording forever.
- **Overtime instead of cut-off**: at zero the recording continues, showing the excess ("+1:23") in MutedRed. Facts, not judgment — knowing how far you overrun is the data.
- **`targetDelta` metric activated**: finishing a countdown practice persists duración real − objetivo, so the history can answer "¿me ajusto al tiempo de examen?".
- **Configuration remembered** (device-local): the next practice repeats the last setup, keeping the habitual flow at one tap. Warnings freeze correctly during pause for free (they run on recorded time, not wall-clock).
- Foundation amended: `define-practice-session-flow` (Preparación, Inicio de intento, Información visible).

## Capabilities

### New Capabilities

<!-- none — this evolves the practice experience -->

### Modified Capabilities

- `practice-recording`: explicit start from a preparation phase; countdown mode with configurable warnings; overtime behavior.
- `attempt-persistence`: targetDelta metric persisted for countdown practices.

## Impact

- New: `Logic/PracticeTimer.swift` (TimerMode, PracticeTimerConfig with persistence, WarningSchedule — pure, testable).
- Modified: `Views/PracticeView.swift` (ready phase, countdown display, warning triggers), `Storage/PracticeService.swift` (optional targetDuration → targetDelta metric).
- Tests: warning-crossing logic (pure), targetDelta persistence; existing call sites unaffected (optional parameter).
- Docs: `define-practice-session-flow`, `Current Context.md`. No schema changes.
