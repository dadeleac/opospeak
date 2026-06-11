## ADDED Requirements

### Requirement: Onboarding shows only for genuinely new users
The guided flow SHALL appear only when onboarding has never been completed AND no temarios exist. If data exists at first check (e.g., restored from iCloud on a new device), onboarding SHALL be marked complete silently and never shown. The decision SHALL be pure, testable logic.

#### Scenario: Fresh install
- **WHEN** the app launches for the first time with no data
- **THEN** the welcome screen appears over the Temarios tab

#### Scenario: New device with synced data
- **WHEN** the app launches on a new device and iCloud has already restored temarios
- **THEN** no onboarding appears, ever

### Requirement: Single welcome screen
The welcome SHALL be one brief screen communicating what OpoSpeak is and that data is private and local, with a single primary action ("Empezar"). It SHALL be dismissible without completing; dismissal ends onboarding permanently and the empty states take over. No carousel, no permission requests, no account.

#### Scenario: Eager user skips reading
- **WHEN** the user dismisses the welcome without tapping Empezar
- **THEN** the app is fully usable and onboarding never reappears

### Requirement: First temario with name only
The flow SHALL ask only for the temario name, offering tappable example suggestions (Judicatura, Notarías, Inspección de Hacienda) that fill the field without obligation. Confirmation SHALL be unavailable with an empty name.

#### Scenario: Example as starting point
- **WHEN** the user taps the "Judicatura" suggestion
- **THEN** the name field fills with "Judicatura" and remains editable

### Requirement: Bulk temas immediately after
After creating the temario, the flow SHALL ask "¿Cuántos temas tiene tu temario?" and create temas 1..N via the existing bulk creation logic. The step SHALL offer "Prefiero añadirlos después" to finish without temas.

#### Scenario: Full syllabus in one step
- **WHEN** the user answers 325
- **THEN** temas 1 through 325 are created untitled and onboarding completes

#### Scenario: Defer temas
- **WHEN** the user chooses to add temas later
- **THEN** onboarding completes with the temario created and the temario detail's empty state offers both creation paths

### Requirement: Landing invites the first practice
On completion, the user SHALL land directly in the new temario's tema list (not the temario list), so the first practice is one tap away. Whatever was created during an abandoned flow SHALL persist.

#### Scenario: Straight to practice
- **WHEN** onboarding completes with 25 temas created
- **THEN** the user is inside the temario seeing Tema 1..25, and tapping one shows the Practicar button

#### Scenario: Abandonment preserves work
- **WHEN** the user abandons after creating the temario but before the temas step
- **THEN** the temario persists and the app shows it normally on next launch
