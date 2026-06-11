## MODIFIED Requirements

### Requirement: Temario list
The Temarios tab SHALL list the **active oposición's** active temarios, showing at minimum: name, number of temas, and recent activity. The navigation title SHALL be the active oposición's name, so the hierarchy reads correctly (oposición above, its temarios below). Archived temarios SHALL NOT appear in the main list.

#### Scenario: List shows minimum information
- **WHEN** the active oposición "Judicatura" has a temario "Civil" with 100 temas and a last practice on a given date
- **THEN** the screen titled "Judicatura" lists "Civil" with its tema count and that date

### Requirement: Temario creation
The user SHALL be able to create a temario providing only a name; description is optional. The temario SHALL belong to the active oposición, the sheet SHALL make that context visible, and examples SHALL be temario-level (Civil, Penal, Bloque I) — never oposición names.

#### Scenario: Quick creation
- **WHEN** the user creates a temario entering only "Civil" while Judicatura is active
- **THEN** the temario is persisted under Judicatura and appears in the list immediately

#### Scenario: Empty name is rejected
- **WHEN** the user tries to confirm creation with an empty name
- **THEN** the confirm action is unavailable

### Requirement: Temario empty state
When the active oposición has no temarios, the Temarios tab SHALL show an empty state inviting the user to create their first temario (e.g. Civil, Penal, Bloque I), with the create action directly available.

#### Scenario: First launch empty state
- **WHEN** the active oposición has no temarios
- **THEN** the Temarios tab shows an invitation to create one and a button that opens creation

### Requirement: Temario archiving
The user SHALL be able to archive a temario. Archiving SHALL hide it from the main list while preserving all temas, intentos, grabaciones, métricas, and notas. The UI SHALL NOT offer destructive temario deletion in this change.

#### Scenario: Archive preserves history
- **WHEN** the user archives a temario that has practice history
- **THEN** it disappears from the list and all of its data remains persisted
