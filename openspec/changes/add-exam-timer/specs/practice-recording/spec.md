## MODIFIED Requirements

### Requirement: Practice launches from the tema
The practice experience SHALL launch only from a tema's Practicar action, presented full screen (immersive, camera-like). The flow has three moments — decide, place, speak: tema → Practicar → **preparación** (Continuar) → **listo** (Grabar) → recording. The timer configuration editor SHALL present as a full-height system sheet rising from the bottom (the HIG-native modal for a scoped decision) when the user taps the one-line summary; the habitual practice never sees the form. The preparation SHALL show the timer configuration as a one-line summary pre-filled with the last used setup, expandable only when the user wants to change it, and a Continuar action that requests the microphone permission without recording anything. The listo screen SHALL invite the user to place the phone wherever they want (stand, table) and SHALL show the idle clock; **Grabar** SHALL be the only control that turns the microphone on. Cancel SHALL be free in both pre-recording moments.

#### Scenario: Habitual practice stays light
- **WHEN** the user opens Practicar with a previously used configuration
- **THEN** the preparation shows a one-line summary (no form) and two taps — Continuar, Grabar — reach recording

#### Scenario: Phone on a stand
- **WHEN** the user taps Continuar, places the phone on a stand, and settles
- **THEN** nothing has been recorded yet, the permission dialog already happened, and tapping Grabar starts a clean recording without handling noise

#### Scenario: No recording without consent
- **WHEN** the practice screen opens
- **THEN** nothing is recorded until the user taps Grabar

## ADDED Requirements

### Requirement: Countdown mode mirrors the exam
The user SHALL be able to choose between count-up and countdown timing. In countdown mode the user sets the target duration and the screen shows remaining time, mirroring the oral exam's clock. The choice and its parameters SHALL be remembered on the device for the next practice.

#### Scenario: Training against the exam clock
- **WHEN** the user configures a 15-minute countdown and starts
- **THEN** the screen counts down from 15:00, freezing during pauses (recorded time, not wall-clock)

### Requirement: Configurable silent warnings
In countdown mode the user SHALL choose at which remaining-time marks to be warned. Each warning SHALL be haptic plus a visual change plus a VoiceOver announcement — never an audible sound, because the open microphone would capture it into the recording. Each mark SHALL fire exactly once per practice. Warnings SHALL be discreet facts, not pressure.

#### Scenario: Five minutes left
- **WHEN** the remaining time crosses a configured 5-minute mark
- **THEN** the device vibrates, the timer visually signals the mark (icon + color, never color alone), VoiceOver announces "Quedan 5 minutos", and no sound is played

#### Scenario: Marks fire once
- **WHEN** the user pauses and resumes around a mark already fired
- **THEN** the warning does not repeat

### Requirement: Overtime continues, visible and unjudged
When the countdown reaches zero, the recording SHALL continue and the screen SHALL show the excess time (e.g. "+1:23") clearly distinguished (MutedRed, plus sign — never color alone), with a haptic and a VoiceOver announcement at the crossing. No metric or label SHALL penalize overrunning.

#### Scenario: Running over
- **WHEN** the user keeps speaking past zero
- **THEN** the display shows the growing excess and the practice finishes normally whenever the user decides
