## Why

The app can organize temarios and temas but cannot yet do the one thing it exists for: record an oral practice. The practice flow is the core experience (`define-practice-session-flow`) and the Practicar button already sits disabled in the tema detail. This change turns OpoSpeak from a catalog into a training tool.

## What Changes

- Enable the Practicar button: full-screen practice experience launched from the tema detail.
- Audio recording with `AVAudioRecorder` (m4a/AAC) writing directly to the `RecordingStore` location; microphone permission requested in context, the first time the user starts a practice.
- Minimal practice screen per the foundation: timer + recording state + finish. No pause (explicit foundation decision). Screen stays awake while recording.
- On finish: persist the Intento (dates, real duration, completed), its Grabación (file metadata), and a duración-total Métrica — then show the closing summary (tema, duration, date, recording available).
- Automatic session management: a Sesión is created on the first intento and reused while practices fall within an inactivity window; the user never sees or manages sessions.
- Discard path: leaving without finishing deletes the partial audio file and persists nothing.
- Audio playback of recordings in the intento detail (play/pause + progress), replacing the "próximamente" placeholder.
- Microphone usage description added to the app's Info.plist configuration.

## Capabilities

### New Capabilities

- `practice-recording`: the recording experience — permission in context, minimal screen, timer, no pause, screen awake, discard semantics.
- `attempt-persistence`: what gets persisted when a practice finishes (Intento + Grabación + Métrica) and the closing summary.
- `session-auto-management`: invisible session lifecycle — creation, reuse window, closure.
- `audio-playback`: listening to a recording from the intento detail.

### Modified Capabilities

- `tema-detail-history`: the Practicar button changes from disabled placeholder to launching the practice flow; the intento detail gains playback controls.

## Impact

- New files: `Logic/SesionPolicy.swift`, `Audio/PracticeRecorder.swift`, `Audio/PlaybackController.swift`, `Services/PracticeService.swift`, `Views/PracticeView.swift`.
- Modified: `TemaDetailView` (enable button → fullScreenCover), `IntentoDetailView` (playback section).
- Project config: `INFOPLIST_KEY_NSMicrophoneUsageDescription` in build settings.
- Tests: SesionPolicy (pure), PracticeService persistence (in-memory container + fake audio file).
- Frameworks: AVFoundation (native). No schema changes; the domain model already supports everything.
