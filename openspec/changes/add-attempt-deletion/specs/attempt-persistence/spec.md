## ADDED Requirements

### Requirement: User-initiated attempt deletion
The user SHALL be able to delete an attempt. Deletion SHALL require a confirmation alert stating that the recording, notes and metrics will be removed irreversibly. Deletion SHALL go through the single repository path so the audio file is removed with the models and never orphans. After deletion the attempt no longer exists anywhere: history, insights, evolution and exports reflect its absence — deleting the fact is the point, not a bug.

#### Scenario: Deleting a mic test
- **WHEN** the user deletes an attempt and confirms the alert
- **THEN** the attempt, its recording file, notes and metrics are gone, and the topic's state recalculates without it

#### Scenario: Cancelling keeps everything
- **WHEN** the user triggers deletion but cancels the alert
- **THEN** nothing is deleted
