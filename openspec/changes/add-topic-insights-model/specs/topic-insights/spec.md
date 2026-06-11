## ADDED Requirements

### Requirement: Topic facts are derivable, never persisted
The insights model SHALL operate exclusively on facts derivable from existing entities (attempts and their dates, durations, targetDelta metrics, notes). No insight, state, or statistic SHALL be persisted — they are computed views, consistent with the domain model's rule that statistics are derived.

#### Scenario: No new storage
- **WHEN** insights are computed for a topic
- **THEN** nothing is written to the store; the same inputs always produce the same outputs

### Requirement: Temporal states with exact, user-relative semantics
Every active topic SHALL be in exactly one state: **pendiente** (never practiced), **reciente** (last practice within the recency window), **al día** (practiced, neither recent nor forgotten), or **olvidado** (last practice beyond the staleness threshold). The staleness threshold SHALL be relative to the user's own revisit cadence — the median interval between consecutive practices of the same topic — with an absolute floor, so a fast-rotation and a slow-rotation opositor each get honest thresholds. Exact formulas live in `define-topic-insights-model` and the reference implementation.

#### Scenario: Forgotten is relative to your rhythm
- **WHEN** a user revisits topics every ~10 days and one topic reaches 25 days without practice
- **THEN** that topic is olvidado — while for a user whose cadence is ~30 days, 25 days is al día

#### Scenario: Cold start
- **WHEN** there is not yet enough history to compute a cadence
- **THEN** a documented default cadence applies and states remain well-defined from day one

### Requirement: States speak of time, never of quality
No state, label, or output of the model SHALL judge mastery or performance ("dominado", "flojo", scores). *Olvidado* describes elapsed time, not merit. This boundary SHALL be stated in the foundation document and respected by every consumer.

#### Scenario: No judgment leakage
- **WHEN** any future screen renders a topic state
- **THEN** the vocabulary available from the model only describes time and activity

### Requirement: Vuelta and cobertura semantics
The model SHALL define the **vuelta** (complete pass over the active topics of the active opposition) derivably and without user management: the current vuelta number is the minimum attempt count across active topics plus one, and a vuelta completes only when every active topic has been practiced that many times. **Cobertura de la vuelta** SHALL be the proportion of active topics already practiced within the current vuelta. Adding new topics mid-vuelta lowers the bar honestly (the vuelta is not complete until they are sung).

#### Scenario: Mid-vuelta position
- **WHEN** 187 of 325 active topics have at least 3 attempts and the rest have exactly 2
- **THEN** the user is in vuelta 3 with cobertura 187/325

#### Scenario: New topic joins
- **WHEN** a never-practiced topic is added to the syllabus
- **THEN** the current vuelta becomes 1 until it is practiced, and cobertura reflects the true pending work

### Requirement: Suggestion ordering as facts, not scheduling
The model SHALL define a single suggestion ordering for "what to practice next", consumed by the Ficha, the Vuelta and the weighted extraction: pendientes first, then olvidados (oldest last-practice first), then al día, then recientes. It is an ordering over facts — the model SHALL NOT produce schedules, deadlines, or plans (the product is not a productivity tool).

#### Scenario: Consistent ordering everywhere
- **WHEN** the Ficha hints "what now" and the extraction weights the draw
- **THEN** both derive from the same ordering defined here

### Requirement: Reference implementation is pure and tested
The model SHALL ship as pure logic (`TopicFacts` in → states, cadence, cycle, ordering out) with table-driven tests covering boundaries (exact thresholds, cold start, single topic, archived topics excluded, empty syllabus). UI consumption is explicitly out of this change.

#### Scenario: Semantics are executable
- **WHEN** a future feature needs "olvidado"
- **THEN** it calls the model — it never re-implements the definition
