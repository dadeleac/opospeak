## Context

Auto-start skipped the foundation's "Preparar práctica" step; the oral exam runs on a countdown the candidate watches. `MetricKind.targetDelta` has existed unused since the domain change, and the recorder's `elapsed` already measures recorded time only — so countdown and warnings freeze correctly during pauses with zero extra code. The open microphone makes audible warnings self-polluting.

## Goals / Non-Goals

**Goals:** explicit start from a ready phase (permission on tap); count-up/countdown modes; user-chosen warning marks (haptic+visual+VoiceOver); overtime display; targetDelta metric; remembered configuration; pure, tested warning logic.

**Non-Goals:** no sound warnings (mic pollution — revisit only with explicit user opt-in and warning); no auto-finish at zero; no per-topic targetDuration field yet (global remembered config covers the common case; the foundation's per-topic field remains future work); no schema changes.

## Decisions

### 1. Warning logic as a pure crossing function

`WarningSchedule.crossedMarks(target:marks:previousElapsed:elapsed:)` returns the remaining-time marks crossed in `(previousElapsed, elapsed]`, where mark m is crossed when `previousElapsed < target − m ≤ elapsed`. Zero (overtime) is just another crossing. Firing-once falls out of the math: a crossed boundary cannot be re-crossed because `elapsed` is monotonic (pause freezes it, never rewinds). Rationale: the only bug-prone part (boundaries, multiple marks in one tick, pause interactions) becomes table-driven unit tests with no audio involved.

### 2. `PracticeTimerConfig` as Codable value persisted in UserDefaults

`{ mode, targetDuration, warningMarks }`, JSON under `practiceTimerConfig`. Device-local UX state (like the active opposition pointer): not synced, not user data. Loaded into the ready phase, saved on Empezar. Rationale: keeps the habitual flow at one tap and avoids schema work; a per-topic override can layer on later without migration.

### 3. Ready phase inside `PracticeView`, recorder created on Empezar

The view's phase logic keys off `recorder == nil` → ready UI (mode picker, minute stepper with quick picks, warning-mark toggles filtered below the target, Empezar). The recorder is constructed and started only on tap, which also moves the permission request to the explicit action. Cancel/dismiss is free in ready (nothing recorded). Rationale: one fullScreenCover, no navigation churn; the foundation's "empezar a cantar cuanto antes" survives because config is pre-filled.

### 4. Warnings triggered from the elapsed change, not a second timer

`onChange(of: recorder.elapsed)` computes crossings against the previously seen elapsed. Effects: `UINotificationFeedbackGenerator` (warning), a brief Amber visual state on the timer (icon + label, never color alone), `AccessibilityNotification.Announcement`. Overtime crossing uses the same path with MutedRed and "Tiempo agotado". Rationale: the recorder's 0.5 s tick is the single clock; a parallel timer would drift from recorded time during pauses.

### 5. `targetDuration` as optional parameter on `PracticeService.finish`

`finish(..., targetDuration: TimeInterval? = nil)`: when present, inserts `Metric(kind: .targetDelta, value: duration − target)` in the same save. Existing call sites and tests compile unchanged. Rationale: persistence rules live in the single write path, testable with divergent values.

### 6. Display semantics

Countdown shows `target − elapsed` while ≥ 0, then `+(elapsed − target)` in MutedRed with a plus sign. Count-up unchanged. Paused state keeps the existing Amber treatment and freezes whatever mode is active.

## Risks / Trade-offs

- [Ready phase adds a tap to every practice] → Pre-filled config; Empezar is the only required action. Accepted consciously; it restores the foundation's Preparar step.
- [Haptics unavailable (silent switch doesn't affect haptics, but older devices/settings might)] → Visual change always accompanies; VoiceOver announcement for non-visual users. Color is never the only signal.
- [User configures marks ≥ target] → UI filters marks below the target; the pure function ignores out-of-range marks anyway.
- [Pressure creep] → Discreet haptic, no flashing reds before zero, no judgment metrics. The foundation's anti-urgency rule is restated in the spec.

## Migration Plan

Pure logic + tests → service parameter → view (ready phase, countdown, warnings) → docs. Suite green at the end.

## Open Questions

- None. Sound warnings and per-topic targets deliberately deferred.
