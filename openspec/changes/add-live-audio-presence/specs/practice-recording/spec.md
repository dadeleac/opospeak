## ADDED Requirements

### Requirement: Live audio presence
While recording, the screen SHALL visibly breathe with the speaker's voice: a soft halo behind the clock follows the smoothed microphone level in scale and opacity. The halo is presence, not measurement — subtle at conversational volume, calm in silence, never a VU meter and never distracting from the clock. Smoothing SHALL be asymmetric (fast attack, slow release) so the halo answers speech onset without flickering. The recording dot in the status line SHALL pulse gently with the same level — the "it is picking me up" confirmation lives where the eye checks that recording is on. The ring SHALL NOT react to voice: it is the time instrument (one element, one job). While paused the halo SHALL settle still, the dot SHALL rest, and the meter SHALL not run. When Reduce Motion is enabled the halo SHALL hold a fixed gentle state instead of animating. Metering SHALL NOT alter the recorded file or its settings.

#### Scenario: The screen is alive while speaking
- **WHEN** the user speaks during a recording
- **THEN** the halo behind the clock swells gently with the voice and the recording dot pulses with it, while clock and ring remain unchanged

#### Scenario: Paused means still
- **WHEN** the user pauses the practice
- **THEN** the halo settles to its resting state and nothing on screen pulses until Reanudar

#### Scenario: Reduce Motion
- **WHEN** the system Reduce Motion setting is enabled
- **THEN** the halo appears in a fixed gentle state and does not animate with the voice
