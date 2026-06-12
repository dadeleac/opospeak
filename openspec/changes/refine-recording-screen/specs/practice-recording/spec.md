## MODIFIED Requirements

### Requirement: Configurable silent warnings
In countdown mode the user SHALL choose at which remaining-time marks to be warned. Marks are curated presets plus one relative mark, "A mitad de tiempo", that scales with the target duration. Each warning SHALL be haptic plus a visual change plus a VoiceOver announcement — never an audible sound, because the open microphone would capture it into the recording. The visual change SHALL present as a moment: a transient material capsule (bell icon + label) appears under the clock with a spring animation, holds briefly, and fades; the clock pulses once subtly. Haptics SHALL be differentiated: intermediate marks use the warning notification, time exhaustion uses the heavier error notification. Each mark SHALL fire exactly once per practice; when the half-time mark coincides with an absolute preset, the warning fires once. Warnings SHALL be discreet facts, not pressure.

#### Scenario: Five minutes left
- **WHEN** the remaining time crosses a configured 5-minute mark
- **THEN** the device vibrates with the warning haptic, a capsule with bell + "Quedan 5 min" springs in under the clock and fades after a few seconds, the clock pulses once, VoiceOver announces "Quedan 5 minutos", and no sound is played

#### Scenario: Half time on a long exercise
- **WHEN** the user enables "A mitad de tiempo" with a 75-minute target and the remaining time crosses 37.5 minutes
- **THEN** the warning fires labelled as the landmark ("Mitad de tiempo", not a rounded figure), with the same capsule + pulse + VoiceOver treatment

#### Scenario: Marks fire once
- **WHEN** the user pauses and resumes around a mark already fired
- **THEN** the warning does not repeat

## ADDED Requirements

### Requirement: Countdown ring with visible marks
In countdown mode the clock SHALL be surrounded by a thin ring that drains as recorded time passes (full at start, empty at zero — the system Timer pattern). The user's effective warning marks SHALL be drawn as ticks on the ring at their remaining-time positions, so upcoming warnings are visible before they fire — as the candidate sees the tribunal's clock. Ticks already crossed SHALL dim. In overtime the ring SHALL read as exhausted using MutedRed (never color alone — the "+excess" clock and "Tiempo agotado" status carry the meaning too). A thin caption under the clock SHALL state the target ("objetivo N min"). Count-up mode SHALL keep the bare clock: no ring, no caption. The ready (listo) screen SHALL show the full ring with its ticks around the idle clock in countdown mode, previewing the practice ahead. Pause SHALL freeze the ring (it runs on recorded time).

#### Scenario: Seeing the warning come
- **WHEN** the user records a 12-minute countdown with marks at 5 and 1 minutes remaining
- **THEN** the ring shows two ticks ahead of the draining edge, and each tick dims once its warning has fired

#### Scenario: Count-up stays bare
- **WHEN** the user records in count-up mode
- **THEN** no ring and no target caption appear — the clean clock alone

### Requirement: Recording controls with hierarchy
While recording, Pausar SHALL be the single prominent control and Finalizar a secondary (bordered) control, presented side by side in one row. Descartar práctica SHALL NOT occupy permanent screen space: it lives in a toolbar menu and SHALL require confirmation via a centered alert before deleting, because it destroys the recording irreversibly (an anchored action sheet launched from a toolbar menu floats over the title — the alert is the HIG pattern for confirming irreversible loss, with an explicit Cancel). Tapping Descartar práctica SHALL pause the recording before the alert appears — the minutes do not run while the user decides — and cancelling the alert SHALL leave the practice paused: recording resumes only with an explicit Reanudar, consistent with interruption handling (manual resume only). Cancel remains free (no confirmation) in both pre-recording moments, where nothing has been recorded.

#### Scenario: Discarding asks first
- **WHEN** the user opens the toolbar menu during a recording and taps Descartar práctica
- **THEN** a centered alert warns that the recording will be deleted, with explicit Descartar (destructive) and Cancelar actions, and only confirming discards it

#### Scenario: Deciding does not cost minutes
- **WHEN** the user taps Descartar práctica while recording and then cancels the alert
- **THEN** the recording paused when the alert appeared and stays paused after cancelling, until the user taps Reanudar

#### Scenario: Pre-recording cancel stays free
- **WHEN** the user cancels from preparation or the listo screen
- **THEN** the practice closes immediately — nothing was recorded, nothing to confirm
