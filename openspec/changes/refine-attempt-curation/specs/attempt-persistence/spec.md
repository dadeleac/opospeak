## ADDED Requirements

### Requirement: User-highlighted attempts
The user SHALL be able to mark an attempt as highlighted (destacado) and unmark it at any time. The highlight is user curation — a fact the user states about their own history — never an app judgment; no logic SHALL derive recommendations, scores or pressure from it. The flag SHALL persist with the attempt, sync like any attempt field, and be included in the export contract (Spanish key `destacado`, additive to contract v2). Scope is deliberately minimal: no filtering, no aggregation, no surfacing beyond the attempt itself and its history row.

#### Scenario: Marking the reference version
- **WHEN** the user toggles the star on an attempt
- **THEN** the attempt persists as highlighted and shows its star wherever that attempt is listed

#### Scenario: Export carries curation
- **WHEN** the user exports their data
- **THEN** each attempt includes `destacado` with its highlight state

### Requirement: Notes are editable and deletable
The user SHALL be able to edit a note's content and delete a note after creation. Deleting requires no confirmation alert — the loss is one note, proportionate to a swipe — and editing preserves the note's original creation timestamp (the note records when the observation was made, not when the typo was fixed).

#### Scenario: Fixing a typo
- **WHEN** the user edits an existing note and saves
- **THEN** the content updates and the note keeps its original date and time

#### Scenario: Removing a note
- **WHEN** the user swipes to delete a note
- **THEN** the note disappears immediately, with no confirmation dialog
