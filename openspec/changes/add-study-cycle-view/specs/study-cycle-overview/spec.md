## ADDED Requirements

### Requirement: Vuelta card at the entry point
The Temarios screen SHALL show, above the syllabus list, a single restrained card with the user's factual position in the cycle: the current vuelta, the cobertura ("N de M temas practicados") with a calm progress indicator, and the count of temas olvidados when greater than zero. The card SHALL contain no suggestions, recommendations, or calls to practice a specific topic. Tapping it SHALL open the Vuelta detail. The card SHALL NOT appear while the active opposition has no topics.

#### Scenario: Opening the app after months of use
- **WHEN** the user lands on Temarios with 325 active topics, 187 practiced in the current vuelta and 12 forgotten
- **THEN** the card reads vuelta number, "187 de 325 temas practicados" and "12 temas olvidados", and one tap opens the detail

#### Scenario: Facts only
- **WHEN** the card renders
- **THEN** no topic is suggested and no priority is implied — position, not prescription

#### Scenario: Fresh syllabus
- **WHEN** the active opposition has no topics yet
- **THEN** no card appears and the existing empty states guide as before

### Requirement: Vuelta detail
The Vuelta detail SHALL present, within the Temarios navigation stack: the cobertura summary, a **mapa del temario** (every active topic as a cell tinted by its state, with a legend pairing icon + text + color), and the factual groups **Temas olvidados** (oldest last-practice first), **Temas pendientes** (never practiced) and **Temas recientes**. Every topic SHALL navigate to its Ficha. All states SHALL come from `TopicInsightsModel`.

#### Scenario: Finding the holes
- **WHEN** the user opens the detail
- **THEN** the map shows the whole syllabus at a glance and the olvidados group lists the gaps, oldest first, each one tap from its Ficha

#### Scenario: Color is never the only signal
- **WHEN** the map renders
- **THEN** a legend pairs each state with icon and text, every cell carries an accessibility label with topic and state, and the grouped lists below convey the same information textually

### Requirement: Suggestions deferred by design
Neither the card nor the detail SHALL surface "tema sugerido", weighted ordering, or priorities in this change. The model's canonical suggestion ordering remains internal until a future change introduces recommendations earned by accumulated data.

#### Scenario: No premature algorithm
- **WHEN** any Vuelta surface renders
- **THEN** the vocabulary is exclusively factual (counts, states, dates) with no prescriptive copy
