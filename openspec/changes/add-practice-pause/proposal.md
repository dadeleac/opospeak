## Why

Real life interrupts practice: the doorbell, a phone call. Today the only options are discarding a 20-minute recording or letting dead air pollute it. The foundation excluded pause from the MVP citing audio fragmentation, temporal inconsistencies and metric doubts — all three turned out unfounded against the actual implementation (`AVAudioRecorder.pause()` continues in the same file; the timer already reads recorded time; the gap never exists in the audio). The original objection was technical and no longer holds; the user need is real.

## What Changes

- **Pause/resume during practice**: `PracticeRecorder` gains a `paused` state with `pause()`/`resume()`; recording continues in the same m4a file, the timer freezes while paused.
- **System interruptions auto-pause** instead of killing the practice: an incoming call or Siri pauses the recording; the user resumes manually when ready. This turns today's worst failure mode (interrupted → failed → lost) into a pause.
- **Duration bug prevented**: `PracticeService.finish` stops deriving duration from wall-clock (`endedAt − startedAt`) — which pause would silently corrupt — and receives the recorded duration explicitly. `Attempt.duration` means **spoken time**; `startedAt`/`endedAt` remain wall times. Export contract unchanged (`duracionReal` keeps its name and meaning: real practice duration).
- **Paused UI state**: unmistakable "En pausa" indicator (Amber), prominent Reanudar, with Finalizar and discard still available; the screen may sleep while paused (idle timer only stays disabled while actually recording); swipe-to-dismiss stays blocked in both states.
- **Foundation amended deliberately**: the "Pausa" section of `define-practice-session-flow` documents the reversal and why the original reasons no longer apply. No judgment attached to pausing — personal training tool.

## Capabilities

### New Capabilities

<!-- none — this evolves existing practice capabilities -->

### Modified Capabilities

- `practice-recording`: the minimal recording screen gains pause/resume; the "no pause" requirement is replaced; interruptions auto-pause.
- `attempt-persistence`: duration semantics fixed to recorded time.

## Impact

- `Audio/PracticeRecorder.swift`: `paused` state, pause/resume, AVAudioSession interruption observer.
- `Storage/PracticeService.swift`: explicit `duration` parameter.
- `Views/PracticeView.swift`: paused phase UI, idle-timer and dismissal rules.
- Tests: recorded-duration-vs-wall-clock test (the key one), PracticeService call sites updated.
- Docs: `define-practice-session-flow` (Pausa section), `Current Context.md`.
- No schema changes, no export changes.
