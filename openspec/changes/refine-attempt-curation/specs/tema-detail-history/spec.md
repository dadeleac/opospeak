## ADDED Requirements

### Requirement: Recent notes read as content
The Ficha's Notas recientes section SHALL present each note as readable content: the note text leads, with date *and time* as a discreet caption (two same-day notes must be distinguishable). Tapping a note SHALL navigate to its attempt, but the section's primary job is to be read in place — Historial below remains the chronological archive; Notas recientes is salience ("what did I tell myself last time?"), not a second history list.

#### Scenario: Two notes the same day
- **WHEN** a topic has two notes written the same day
- **THEN** each shows its time and they are distinguishable at a glance

### Requirement: Highlight visible in history
Attempts marked as highlighted SHALL show their star in the topic's Historial rows, alongside the existing recording and notes indicators.

#### Scenario: Spotting the reference version
- **WHEN** the user scans the Historial of a topic with one highlighted attempt
- **THEN** that row shows a star and the others do not
