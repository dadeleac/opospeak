## Why

The recording screen has a clean clock but feels static and poor — exactly where the product lives its central moment. Three concrete gaps: (1) the countdown is a bare number with no sense of *where in the exam* you are, while the real candidate watches a clock face; (2) warnings — a differentiating feature — present as a 4-second text swap in a tiny status line, visually beneath their importance; (3) two stacked full-width buttons plus a red text link occupy the lower third with no hierarchy, and the destructive action sits permanently on screen against HIG guidance.

## What Changes

- **Countdown ring (B)**: a thin ring around the clock drains as time passes (the Apple Timer pattern). The user's warning marks are drawn as ticks **on** the ring — you see the 5-minute warning coming, like the candidate sees the tribunal's clock. Crossed ticks dim; the ring turns MutedRed in overtime. Count-up mode keeps the bare clock (no target, no ring). A thin "objetivo N min" caption sits under the clock in countdown.
- **Warning as a moment (C)**: crossing a mark presents a material capsule (bell + label) springing in under the clock, holding ~4 s, fading out; the clock pulses once subtly. Haptics differentiate: intermediate marks fire `.warning`, exhaustion fires `.error`. Still never sound — the microphone is open.
- **Control hierarchy (D)**: Pausar (prominent) and Finalizar (bordered) side by side in one row; **Descartar práctica** moves to a toolbar "···" menu with a confirmation dialog (destructive, irreversible — deletes the audio). The lower third breathes.

## Capabilities

### New Capabilities

<!-- none — this refines the recording experience -->

### Modified Capabilities

- `practice-recording`: countdown ring with mark ticks; warning presentation as a transient capsule + pulse with differentiated haptics; control hierarchy with discard behind menu + confirmation.

## Impact

- New: `Views/CountdownRing.swift` (ring + ticks, driven by pure `CountdownRingGeometry` in `Logic/PracticeTimer.swift` — fractions testable without UI).
- Modified: `Views/PracticeView.swift` (ready + recording layouts, warning capsule, pulse, haptics, controls row, toolbar menu, confirmation dialog).
- Tests: ring geometry (remaining fraction, mark fractions, clamping); existing warning-crossing tests untouched.
- Docs: `define-practice-session-flow` (Avisos, Información visible), `Current Context.md`. No schema changes, no recorder changes (audio metering deliberately deferred to its own change).
