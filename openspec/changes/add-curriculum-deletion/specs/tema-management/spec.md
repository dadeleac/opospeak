## ADDED Requirements

### Requirement: Topic deletion
The user SHALL be able to delete a topic from the syllabus's topic list (swipe) and from the topic's edit sheet (destructive row at the bottom). Both SHALL present a confirmation alert stating that the topic's attempts, recordings and notes will be removed irreversibly. Deletion SHALL go through the repository so every audio file underneath is removed with the models. Archiving remains available as the non-destructive alternative. After deleting from the edit sheet, the Ficha SHALL close — its subject no longer exists.

#### Scenario: Deleting a topic with history
- **WHEN** the user deletes a topic with attempts and confirms
- **THEN** the topic, its attempts, notes, metrics and every audio file disappear, and the syllabus state recalculates

#### Scenario: Cancelling keeps everything
- **WHEN** the user triggers topic deletion but cancels
- **THEN** nothing is deleted
