## Context

The IA change shipped every screen around the practice flow; the Practicar button is a disabled placeholder. `define-practice-session-flow` fixes the experience: minimal friction (tema → Practicar → grabando), interface that disappears, no pause, automatic sessions, summary on finish. The domain model and `RecordingStore`/`PracticeRepository` already exist. Recording and playback are the first AVFoundation surface in the codebase.

## Goals / Non-Goals

**Goals:**

- Recording with `AVAudioRecorder` (AAC/m4a) straight into the `RecordingStore` location.
- Permission in context; denied state handled with dignity.
- Minimal full-screen practice UI; screen awake; discard support.
- Atomic persistence on finish (Intento + Grabación + Métrica) through a `PracticeService`.
- Invisible session lifecycle with a pure, testable reuse policy.
- Playback in the intento detail.

**Non-Goals:**

- No pause (foundation decision), no waveforms, no audio editing, no input level meters.
- No background-audio entitlement: recording with the app in foreground only (screen stays awake; backgrounding interruptions are surfaced, not recovered, in this change).
- No transcription/analysis of any kind.
- No export/share of recordings (export change).

## Decisions

### 1. Record directly to the final RecordingStore URL

A grabación UUID is generated when recording starts; `AVAudioRecorder` writes to `RecordingStore.url(forGrabacionId:)` from the first byte. On finish, only models are persisted; on discard, the file is deleted. Rationale: no copy step, no temp-file orphan class of bugs, and the file-before-models ordering required by the spec falls out naturally. Alternative — temp file + move on save — adds a failure mode (move fails after recording succeeded) for no benefit.

### 2. `PracticeRecorder` as an `@Observable` MainActor class

Wraps `AVAudioSession` configuration (`.playAndRecord`, `.spokenAudio` mode), permission request (`AVAudioApplication.requestRecordPermission`), `AVAudioRecorder` lifecycle, and a 1-second timer publishing `elapsed`. States: `idle → requestingPermission → recording → finished(URL, duration) / denied / failed`. The view renders states; it never touches AVFoundation. Rationale: testable view, single owner of the audio session, matches the ios-swiftui skill's observable pattern without ceremony.

### 3. Session reuse as a pure policy

`SesionPolicy.sesionParaIntento(sesionesRecientes:ahora:ventana:)` returns "reuse this one" or "create new" given (lastActivity, now, 30-min window). `PracticeService` applies the decision against fetched sessions. Rationale: the only interesting session logic is the window comparison — making it pure makes the 30-minute boundary trivially testable (inside, outside, exactly-at-boundary).

### 4. `PracticeService` is the single write path for finishing a practice

`finish(tema:grabacionId:inicio:fin:fileURL:)` computes duration, finds/creates the sesión, creates Intento + Grabación + Métrica, sets sesión.fechaFin, and saves once. Rationale: persistence of a practice is one transaction with ordering rules; spreading it across the view invites partial saves. Mirrors the existing `PracticeRepository` precedent (single delete path).

### 5. Practice UI as `fullScreenCover` with two phases

One `PracticeView` with an internal phase: `grabando` (timer + indicator + Finalizar + discreet discard) → `resumen` (tema, duration, date, recording available, Hecho). Rationale: the summary is part of the same emotional unit; navigating to a separate screen would re-render the tema detail mid-flow. `interactiveDismissDisabled` prevents accidental swipe-away while recording; `isIdleTimerDisabled` only while recording.

### 6. Playback via a small `PlaybackController`

`@Observable` wrapper over `AVAudioPlayer`: load-by-URL, play/pause, published progress via timer, stop on deinit/disappear. The intento detail checks file existence through `RecordingStore` before offering the player ("grabación no disponible" otherwise). Rationale: AVAudioPlayer is enough for m4a local playback; AVPlayer adds nothing here.

### 7. Recording settings

AAC, 44.1 kHz, mono, ~64 kbps. Rationale: voice content; ~30 MB/hour keeps years of practice storable on device; mono halves size with zero loss for a single speaker. Constants live in `PracticeRecorder` for future revision.

## Risks / Trade-offs

- [Interruptions (calls, Siri) kill the recording] → AVAudioRecorder finalizes the file on interruption; the recorder surfaces `failed`/partial state and the user can finish with what was captured or discard. Full interruption-resume is future work.
- [Simulator vs device audio differences] → Recording works in the simulator; device verification before TestFlight is already mandated by the foundation's audit gates.
- [Timer-driven UI updates every second] → Trivial cost; no per-frame work.
- [User force-quits mid-recording] → File exists, models don't: an orphaned file wastes space but never corrupts history (accepted in the domain-model change; orphan sweep remains future work).

## Migration Plan

1. Logic first (`SesionPolicy`), then audio (`PracticeRecorder`, `PlaybackController`), then service, then UI wiring. Project builds at each step.
2. Add `INFOPLIST_KEY_NSMicrophoneUsageDescription` to both Debug and Release build settings.

Rollback: revert commits; no schema changes involved.

## Open Questions

- None blocking. The 30-minute window is a first definition; tuning it later only touches `SesionPolicy`.
