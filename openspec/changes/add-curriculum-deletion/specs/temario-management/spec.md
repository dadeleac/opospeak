## ADDED Requirements

### Requirement: Syllabus rename
The user SHALL be able to edit a syllabus's name from the syllabus detail, via an edit sheet mirroring the topic's. The trimmed name must be non-empty.

#### Scenario: Fixing the name
- **WHEN** the user renames "Civl" to "Civil" and saves
- **THEN** the syllabus shows the new name everywhere (lists, map blocks, qualified rows)

### Requirement: Syllabus deletion
The user SHALL be able to delete a syllabus from the syllabi list (swipe) and from its edit sheet (destructive row). Both SHALL present a confirmation alert stating the scale: its topics, attempts and recordings will be removed irreversibly. Deletion SHALL go through the repository so every audio file underneath is removed with the models. Archiving remains the non-destructive alternative.

#### Scenario: Deleting a whole syllabus
- **WHEN** the user deletes a syllabus with topics and practice history and confirms
- **THEN** the syllabus and everything underneath disappear, including every audio file, and Estado/Progreso recalculate
