## MODIFIED Requirements

### Requirement: Onboarding shows only for genuinely new users
The guided flow SHALL appear only when onboarding has never been completed AND no oposiciones exist. If data exists at first check (e.g., restored from iCloud on a new device), onboarding SHALL be marked complete silently and never shown. The decision SHALL be pure, testable logic.

#### Scenario: Fresh install
- **WHEN** the app launches for the first time with no data
- **THEN** the welcome screen appears over the Temarios tab

#### Scenario: New device with synced data
- **WHEN** the app launches on a new device and iCloud has already restored oposiciones
- **THEN** no onboarding appears, ever

### Requirement: First oposición with name only
After the welcome, the flow SHALL ask for the oposición name, offering tappable example suggestions (Judicatura, Notarías, Inspección de Hacienda) that fill the field without obligation. Confirmation SHALL be unavailable with an empty name.

#### Scenario: Example as starting point
- **WHEN** the user taps the "Judicatura" suggestion
- **THEN** the name field fills with "Judicatura" and remains editable

### Requirement: First temario with name only
After the oposición, the flow SHALL ask for the first temario's name with temario-level suggestions (Civil, Penal, Procesal). Confirmation SHALL be unavailable with an empty name. The oposición name SHALL be visible as context.

#### Scenario: Correct hierarchy from minute one
- **WHEN** the user creates "Judicatura" and then "Civil"
- **THEN** Civil is a temario inside the Judicatura oposición — never the other way around

### Requirement: Bulk temas immediately after
After creating the temario, the flow SHALL ask "¿Cuántos temas tiene tu temario?" and create temas 1..N via the existing bulk creation logic. The step SHALL offer "Prefiero añadirlos después" to finish without temas.

#### Scenario: Full syllabus in one step
- **WHEN** the user answers 100
- **THEN** temas 1 through 100 are created untitled and onboarding completes

#### Scenario: Defer temas
- **WHEN** the user chooses to add temas later
- **THEN** onboarding completes with the oposición and temario created

### Requirement: Landing invites the first practice
On completion, the user SHALL land directly in the new temario's tema list. Whatever was created during an abandoned flow SHALL persist (oposición persists after its phase; temario after its phase).

#### Scenario: Straight to practice
- **WHEN** onboarding completes with 25 temas created
- **THEN** the user is inside the temario seeing Tema 1..25, and tapping one shows the Practicar button

#### Scenario: Abandonment preserves work
- **WHEN** the user abandons after creating the oposición but before the temario step
- **THEN** the oposición persists and the app shows it normally on next launch
