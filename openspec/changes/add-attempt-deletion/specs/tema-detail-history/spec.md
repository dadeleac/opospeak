## ADDED Requirements

### Requirement: Deletion lives where attempts live
The Ficha's Historial rows SHALL support swipe-to-delete, and the attempt detail SHALL offer "Eliminar intento" from its toolbar menu. Both paths present the same confirmation alert. Deleting from the detail SHALL navigate back, since the screen's subject no longer exists.

#### Scenario: Swipe in the Historial
- **WHEN** the user swipes an attempt row and confirms
- **THEN** the row disappears from the Historial

#### Scenario: Delete from the detail
- **WHEN** the user deletes from the attempt detail and confirms
- **THEN** the app navigates back to the Ficha, where the attempt is gone
