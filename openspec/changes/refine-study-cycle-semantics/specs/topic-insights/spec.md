## ADDED Requirements

### Requirement: Salud del temario is the primary coverage
The model SHALL expose the syllabus health: counts of active topics per visible state (al día, necesita repaso, sin practicar). Health SHALL decay naturally with time — a topic practiced long ago stops counting as healthy when it crosses the staleness threshold. The vuelta-based coverage SHALL be reframed as **rotation position**: a secondary fact about cycle progress, never the headline metric.

#### Scenario: Health decays, rotation does not lie either
- **WHEN** a user practiced 187 topics in the current round but 50 of them have since crossed their staleness threshold
- **THEN** health reports those 50 under "necesita repaso" while the rotation position still reports 187 covered in the round — two different facts, two different names

### Requirement: Three visible states over four internal ones
The model SHALL keep its four internal states (pending, recent, current, forgotten) — recency keeps feeding the suggestion ordering and visual nuance — but the user-facing vocabulary SHALL be three: **Sin practicar**, **Al día** (absorbing reciente), **Necesita repaso**. "Necesita repaso" speaks of time-based need, never of merit; the foundation documents this nuance explicitly.

#### Scenario: One legend, three entries
- **WHEN** any surface lists the states
- **THEN** exactly three appear: Sin practicar, Al día, Necesita repaso

#### Scenario: Recency survives as nuance
- **WHEN** a topic was practiced this week
- **THEN** it reads "Al día" with a brighter visual treatment, and the internal ordering still distinguishes it

## MODIFIED Requirements

### Requirement: Vuelta and cobertura semantics
The model SHALL define the **vuelta** (complete pass over the active topics of the active opposition) derivably and without user management: the current vuelta number is the minimum attempt count across active topics plus one, and a vuelta completes only when every active topic has been practiced that many times. The vuelta-based coverage is the **rotation position**, a secondary fact. **"Vuelta" is an internal concept**: it SHALL surface only inside the cycle detail (for the oposiciones whose culture thinks in vueltas), never as the headline of the entry-point card. Adding new topics mid-vuelta lowers the bar honestly.

#### Scenario: Mid-vuelta position
- **WHEN** 187 of 325 active topics have at least 3 attempts and the rest have exactly 2
- **THEN** the rotation position reads vuelta 3 with 187/325 — visible in the detail, not on the card

#### Scenario: Hacienda never trips over jargon
- **WHEN** a user who has never heard "vuelta" reads the entry-point card
- **THEN** no vuelta vocabulary appears; the card speaks of estado del temario

### Requirement: Suggestion ordering as facts, not scheduling
The model SHALL define a single suggestion ordering for "what to practice next": pendientes first, then olvidados (oldest last-practice first), then al día, then recientes. Its **head MAY surface as "Siguiente"** accompanied by its factual reason (days without practice, or never practiced) — one topic, one fact, one tap to its Ficha. The model SHALL NOT produce schedules, deadlines, plans, or ranked lists beyond this single head.

#### Scenario: Siguiente is a fact with a reason
- **WHEN** the detail shows "Siguiente: Tema 4 · Hace 42 días sin práctica"
- **THEN** that is the head of the canonical ordering with its explanatory fact — no score, no urgency theater

#### Scenario: Consistent ordering everywhere
- **WHEN** any surface needs "what now"
- **THEN** it derives from this single ordering
