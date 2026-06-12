## Why

The recording screen got structure (ring, warning moments, control hierarchy) but it is still *static while you speak*: nothing on screen reflects that the microphone is alive and hearing you. What makes Voice Memos feel premium is that the screen breathes with your voice. This was deliberately deferred out of `refine-recording-screen` because it touches the recorder and needs its own fine-tuning. That moment is now.

## What Changes

- **Live audio presence**: a soft halo behind the clock breathes with the speaker's voice — scale and opacity follow the smoothed microphone level. It replaces nothing: the status line, ring and warnings stay; the halo adds *life*, not information.
- **Metering in PracticeRecorder**: `AVAudioRecorder.isMeteringEnabled` plus a dedicated ~15 Hz meter timer (separate from the 0.5 s elapsed timer) publishing a smoothed `level` (0…1). Pause and finish stop the meter and settle the level to zero — a paused screen is visibly still.
- **Pure level math (`AudioLevelMeter`)**: dB-to-level normalization (speech-tuned floor) and asymmetric smoothing — fast attack so the halo answers the voice, slow release so it never flickers. Pure and table-tested; the recorder just feeds it samples.
- Calibration goal: the halo must read as *presence*, not as a VU meter. Subtle at conversational volume, calm in silence, never distracting. Reduce Motion respected: the halo stays at a fixed gentle state.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `practice-recording`: live audio presence on the recording screen, driven by microphone metering; still during pause; Reduce Motion respected.

## Impact

- New: `Logic/AudioLevelMeter.swift` (pure normalization + asymmetric smoothing), `Views/AudioPresenceHalo.swift`.
- Modified: `Audio/PracticeRecorder.swift` (metering enabled, meter timer, published `level`), `Views/PracticeView.swift` (halo behind the clock).
- Tests: AudioLevelMeter (clamping, floor, attack faster than release, silence settles to zero).
- Docs: `define-practice-session-flow` (Información visible), `Current Context.md`. No schema changes; recording settings untouched (metering does not alter the file).
