## MODIFIED Requirements

### Requirement: Tema detail screen
The tema detail SHALL be the **Ficha de tema** — the opositor's workbench for one topic. It SHALL show, in this order of prominence: the prominent Practicar action (unchanged), the topic's **estado** from the insights model with its one-sentence explanation and key facts (attempt count, total practice time, days since last practice), an **evolución** section with a calm chart of recent attempt durations (only when at least two timed attempts exist), the most recent **notas** across attempts (each linking to its intento), and the intento history ordered by date descending. All temporal semantics SHALL come from `TopicInsightsModel` — the view SHALL NOT re-implement any definition.

#### Scenario: Ficha of a forgotten topic
- **WHEN** the user opens a topic whose last practice exceeds their forgetting threshold
- **THEN** the ficha shows "Olvidado" with icon and Amber accent (never color alone), the explanation "Llevas más del doble de tu ritmo sin cantarlo", the facts, and the rest of the ficha

#### Scenario: Ficha of a pending topic
- **WHEN** the user opens a never-practiced topic
- **THEN** the estado reads "Pendiente — Todavía no lo has cantado", no evolución chart appears, and the empty history invites practicing

#### Scenario: Evolution at a glance
- **WHEN** a topic has five timed attempts
- **THEN** the evolución section charts their durations so the trend is visible without reading numbers

#### Scenario: Notes surface on the ficha
- **WHEN** attempts of the topic carry notes
- **THEN** the most recent ones appear on the ficha and tapping one opens its intento

#### Scenario: No judgment, no scheduling
- **WHEN** any estado is rendered
- **THEN** the copy speaks of time and activity only — no quality labels, no deadlines, no plans

#### Scenario: Adding a note
- **WHEN** the user writes "Demasiado rápido al inicio" in the intento detail
- **THEN** a nota is persisted on that intento and appears in its list immediately

#### Scenario: Recording is playable
- **WHEN** the user opens an intento that has a recording on disk
- **THEN** play/pause controls and a progress indicator are available
