## ADDED Requirements

### Requirement: Temario list
The Temarios tab SHALL list the user's active temarios, showing at minimum: name, number of temas, and recent activity (date of the most recent intento across its temas, if any). Archived temarios SHALL NOT appear in the main list.

#### Scenario: List shows minimum information
- **WHEN** a temario named "Judicatura" with 325 temas and a last practice on a given date exists
- **THEN** the list row shows "Judicatura", its tema count, and that date

### Requirement: Temario creation
The user SHALL be able to create a temario providing only a name; description is optional. Creation SHALL NOT require any other field.

#### Scenario: Quick creation
- **WHEN** the user creates a temario entering only "Judicatura"
- **THEN** the temario is persisted and appears in the list immediately

#### Scenario: Empty name is rejected
- **WHEN** the user tries to confirm creation with an empty name
- **THEN** the confirm action is unavailable

### Requirement: Temario empty state
When no temarios exist, the Temarios tab SHALL show an empty state inviting the user to create their first temario, with the create action directly available.

#### Scenario: First launch empty state
- **WHEN** the app has no temarios
- **THEN** the Temarios tab shows an invitation to create one and a button that opens creation

### Requirement: Temario archiving
The user SHALL be able to archive a temario. Archiving SHALL hide it from the main list while preserving all temas, intentos, grabaciones, métricas, and notas. The UI SHALL NOT offer destructive temario deletion in this change.

#### Scenario: Archive preserves history
- **WHEN** the user archives a temario that has practice history
- **THEN** it disappears from the list and all of its data remains persisted
