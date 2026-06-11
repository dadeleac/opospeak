## MODIFIED Requirements

### Requirement: Temario list
The Temarios tab SHALL list the **active oposición's** active temarios, showing at minimum: name, number of temas, and recent activity. The navigation title SHALL be the active oposición's name. Above the list, the screen SHALL show the **Vuelta card** defined in `study-cycle-overview` whenever the opposition has topics — the entry point answers "¿qué voy a practicar?" with the factual state of the preparation before listing where to go. Archived temarios SHALL NOT appear in the main list.

#### Scenario: List shows minimum information
- **WHEN** the active oposición "Judicatura" has a temario "Civil" with 100 temas and a last practice on a given date
- **THEN** the screen titled "Judicatura" shows the Vuelta card and lists "Civil" with its tema count and that date

#### Scenario: A living home screen
- **WHEN** the user returns after months of use
- **THEN** the first screen communicates the real state of the preparation (vuelta, cobertura, olvidados) instead of empty space
