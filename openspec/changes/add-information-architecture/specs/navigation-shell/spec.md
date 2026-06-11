## ADDED Requirements

### Requirement: Three-tab structure
The application SHALL present exactly three tabs — Temarios, Progreso, and Ajustes — each hosting its own navigation stack. Temarios SHALL be the initially selected tab. No additional tabs SHALL exist in the MVP; in particular there SHALL be no "Practicar" tab and no standalone "Historial" tab.

#### Scenario: App launch lands on Temarios
- **WHEN** the application starts
- **THEN** the tab bar shows Temarios, Progreso, and Ajustes, with Temarios selected

#### Scenario: Practice is reached through a tema
- **WHEN** the user wants to practice
- **THEN** the only path is Temarios → temario → tema → Practicar, never a dedicated tab

### Requirement: Drill-down hierarchy in Temarios
The Temarios tab SHALL follow the hierarchy: temario list → temario detail (tema list) → tema detail → intento detail. Navigation SHALL use the platform-native stack so the system back behavior always works.

#### Scenario: Navigating down and back
- **WHEN** the user opens a temario, then a tema, then an intento, and taps back three times
- **THEN** each step returns to the previous screen, ending at the temario list

### Requirement: Minimal Ajustes content
The Ajustes tab SHALL contain only what does not belong to the practice flow: app information (name, version), a visible privacy statement (local-first, no account, user owns the data), and placeholder rows for export and iCloud status that communicate these features arrive in upcoming versions. Ajustes SHALL NOT become a feature drawer.

#### Scenario: Ajustes shows privacy promise
- **WHEN** the user opens Ajustes
- **THEN** they see the app version and a clear statement that data is local and theirs

### Requirement: Sessions are invisible
The UI SHALL NOT expose any screen, list, or control for managing sesiones. The Sesion entity remains an automatic domain concept.

#### Scenario: No session management surface
- **WHEN** the user explores every screen of the app
- **THEN** no screen offers creating, listing, editing, or deleting sesiones
