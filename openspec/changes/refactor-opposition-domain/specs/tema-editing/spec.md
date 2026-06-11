## ADDED Requirements

### Requirement: Tema number and title are editable
From the tema detail, the user SHALL be able to edit the tema's number and title. The title MAY be left empty (the tema displays as "Tema N"); the number SHALL stay unique within its temario. Bulk-created temas start untitled and gain titles whenever the user wants — titles are never required to practice.

#### Scenario: Titling a bulk-created tema
- **WHEN** the user opens Tema 15, edits it and sets the title "Procedimiento Inspector"
- **THEN** the tema displays as "Procedimiento Inspector" everywhere, keeping number 15 and its full history

#### Scenario: Clearing a title
- **WHEN** the user removes a tema's title
- **THEN** it displays as "Tema N" again

#### Scenario: Duplicate number rejected
- **WHEN** the user tries to change a tema's number to one already used in the temario
- **THEN** the confirmation is unavailable with an explanation
