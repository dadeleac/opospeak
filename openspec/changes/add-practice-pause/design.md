## Context

The foundation's no-pause decision rested on three technical fears — audio fragmentation, temporal inconsistency, metric pollution — that the shipped implementation disproves: `AVAudioRecorder.pause()/record()` continues in one file; the timer reads `recorder.currentTime` (recorded time only); a paused gap never exists in the audio. The one real hazard is ours: `PracticeService` derives duration from wall-clock dates, which pause would silently corrupt. David approved reversing the decision.

## Goals / Non-Goals

**Goals:** pause/resume in the same file; auto-pause on system interruptions; duration = recorded time (the bug fix); unmistakable paused UI; foundation amended deliberately.

**Non-Goals:** no auto-resume after interruptions (user decides when ready); no pause metrics or counters (no judgment); no background recording entitlement (foreground rules unchanged); no export/schema changes.

## Decisions

### 1. `paused` as a first-class recorder state

`State` gains `.paused`. `pause()` (valid from `.recording`): `recorder.pause()`, stop timer. `resume()` (valid from `.paused`): re-assert the audio session, `recorder.record()`, restart timer. `finish()` accepts both `.recording` and `.paused`. Rationale: AVAudioRecorder natively supports this; the state machine stays linear and exhaustive in the view's `switch`.

### 2. Duration passed explicitly to `finish`, measured by the recorder

`PracticeService.finish(topic:recordingID:startedAt:endedAt:duration:)` — the recorder's `elapsed` (from `currentTime`) is the truth. Wall-clock dates remain as the attempt's temporal context. Rationale: deriving duration from dates is exactly the silent-corruption bug; making duration a required parameter makes the call site state its source. `duracionReal` in the export keeps name and meaning (real practice duration).

### 3. Interruptions observe `AVAudioSession.interruptionNotification`

On `.began` while recording → `pause()`. On `.ended` → nothing (stay paused; the user resumes). Rationale: auto-resume after a call is hostile — the user may not be ready, mid-sentence context is lost anyway; manual resume matches the doorbell flow exactly. The observer lives in `PracticeRecorder` (single owner of the audio session) and is removed on stop.

### 4. Paused UI: same screen, different temperature

The recording phase view renders both states: MutedRed dot + "Grabando" vs Amber pause icon + "En pausa"; the primary control toggles (Pausar ⇄ Reanudar); Finalizar and discard stay put. Idle timer disabled only while `.recording` — a paused phone may sleep (battery, pocket). `interactiveDismissDisabled` covers both states. Rationale: one screen avoids re-orientation; color + icon + label change satisfies "color is never the only signal".

### 5. Testing strategy

AVAudioRecorder needs real audio hardware paths — the recorder's pause itself is a manual device check. What unit tests nail is the contract that matters: `PracticeService` persists the passed duration, not `endedAt − startedAt` (test with deliberately divergent values). Existing call sites updated to pass explicit durations.

## Risks / Trade-offs

- [User forgets a paused practice for hours] → Allowed deliberately (screen sleeps); the recording is intact and finishable. A future gentle reminder is possible; not now.
- [Audio session reactivation fails on resume (e.g. another app took it)] → `resume()` re-asserts the session and falls back to `.failed(message)` if it cannot; the file up to the pause remains finishable… actually on failure the user can still finish (file is closed correctly by AVAudioRecorder).
- [Realism dilution] → Product decision made consciously; documented in the foundation amendment; no metric judges pausing.

## Migration Plan

Recorder → service signature + call site → UI → tests → docs. Single change, suite green at the end.

## Open Questions

- None. Auto-resume explicitly rejected; pause metrics explicitly rejected.
