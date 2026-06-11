## MODIFIED Requirements

### Requirement: Vuelta card at the entry point
The Temarios screen SHALL show, above the syllabus list, a single restrained card titled by what it shows — **Estado del temario** — with the syllabus health: a calm progress indicator of topics al día over the total, and the breakdown "X al día · Y necesitan repaso · Z sin practicar" (zero-count groups omitted). No vuelta vocabulary, no suggestions, no prescription on the card. Tapping it SHALL open the detail. The card SHALL NOT appear while the active opposition has no topics.

#### Scenario: An honest home after months
- **WHEN** the user practiced everything once long ago and stopped
- **THEN** the card shows most topics under "necesitan repaso" — health decays; the card cannot be gamed by touching each topic once

#### Scenario: Facts only
- **WHEN** the card renders
- **THEN** it contains counts and states — no vuelta number, no suggested topic, no urgency copy

### Requirement: Vuelta detail
The cycle detail SHALL present, within the Temarios navigation stack: the **salud summary** (bar + breakdown) with the **rotation position as a secondary fact** ("Vuelta N · M de T practicados en esta vuelta"), the **Siguiente** row (head of the canonical ordering with its factual reason, one tap to its Ficha), the **mapa del temario** (every active topic tinted by visible state, recientes with a brighter nuance; legend with three entries pairing icon + text + color; per-cell accessibility labels), and the per-state groups **capped at five rows** with "Ver todos (N)" leading to the full list. Every topic SHALL navigate to its Ficha.

#### Scenario: Siguiente replaces the unmanageable list
- **WHEN** the opposition has 325 topics and 103 are sin practicar
- **THEN** the detail leads with one Siguiente and the group shows five rows plus "Ver todos (103)"

#### Scenario: The vuelta lives here, quietly
- **WHEN** a Judicatura opositor opens the detail
- **THEN** the rotation position reads "Vuelta 3 · 187 de 325" as a secondary line under the health summary

#### Scenario: Color is never the only signal
- **WHEN** the map renders
- **THEN** the three-entry legend pairs icon + text + color, and every cell carries an accessibility label with topic and visible state
