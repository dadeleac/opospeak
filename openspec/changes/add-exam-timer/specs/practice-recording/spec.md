## MODIFIED Requirements

### Requirement: Practice launches from the tema
The practice experience SHALL launch only from a tema's Practicar action, presented full screen. The path SHALL be: tema → Practicar → **preparación** → Empezar → recording. The preparation phase SHALL show the topic, the timer configuration (mode, target duration, warning marks) pre-filled with the last used setup, and a single prominent Empezar action. Recording SHALL never start without the user's explicit tap; the microphone permission is requested at that tap.

#### Scenario: Habitual practice stays one tap
- **WHEN** the user opens Practicar with a previously used configuration
- **THEN** the preparation shows it pre-filled and a single tap on Empezar starts recording

#### Scenario: No recording without consent
- **WHEN** the practice screen opens
- **THEN** nothing is recorded until the user taps Empezar

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
