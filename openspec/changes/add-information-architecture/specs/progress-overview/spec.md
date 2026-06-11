## ADDED Requirements

### Requirement: Editorial progress summary
The Progreso tab SHALL present a calm, editorial (non-dashboard) summary derived from intentos, organized in the four foundation groups: Volumen (total intentos, accumulated time, temas worked, active days), Consistencia (practice days in recent weeks), Cobertura (temas practiced vs never practiced), and Distribución (most and least practiced temas). All values SHALL be derived at read time — no persisted statistics.

#### Scenario: Summary after real practice
- **WHEN** the user has 12 intentos over 3 temas totaling 2 hours
- **THEN** Progreso shows 12 intentos, 2h accumulated, 3 temas worked, and the corresponding coverage

### Requirement: No judgment, no gamification
Progreso SHALL show facts only: no scores, no rankings, no streak pressure, no auto-evaluation labels.

#### Scenario: Facts without evaluation
- **WHEN** a tema has not been practiced for a long time
- **THEN** the UI may show the elapsed time since the last intento but never a negative label or score

### Requirement: Progress empty state
When no intentos exist, Progreso SHALL show an empty state explaining that progress appears as the user practices.

#### Scenario: Fresh install
- **WHEN** the user opens Progreso with zero intentos
- **THEN** the screen explains progress will appear with practice and points the user to Temarios
