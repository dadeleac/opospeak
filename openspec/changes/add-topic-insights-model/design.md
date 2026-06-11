## Context

Approved strategy (`research/post-mvp-opportunity-analysis.md`): V1 is el Ciclo de estudio, and its prerequisite is defining the semantics of *olvidado/reciente/pendiente/vuelta/cobertura* once. `define-progress-and-history-model` already owns the **global** projections; the topic-level layer beneath them has never been specified. All inputs exist in the domain (attempt dates, durations, targetDelta); nothing new is persisted.

## Goals / Non-Goals

**Goals:** the foundation document; exact, defensible formulas; pure tested implementation; progress-and-history realignment.

**Non-Goals:** no UI (Ficha/Vuelta/Extracción are next changes); no schema changes; no scheduling/planning semantics; no quality judgments; no per-topic configurable thresholds (one model, explainable).

## Decisions

### 1. Staleness relative to the user's own cadence, with an absolute floor

**Cadence** = median of intervals between consecutive attempts of the same topic, pooled across all practiced topics of the active opposition. Median (not mean) resists outliers like vacations. **Olvidado**: days since last practice > max(14, 2 × cadence). **Reciente**: ≤ 7 days (fixed — "this week" is universally intuitive; making recency relative adds explanation cost for no decision value). **Al día**: the remainder. **Cold start** (fewer than 5 intervals): cadence defaults to 21 days → olvidado at 42. Rationale: a fixed threshold lies to both the 10-day-rotation and the 45-day-rotation opositor; doubling one's own rhythm is explainable in one sentence ("llevas más del doble de tu ritmo sin cantarlo"); the 14-day floor prevents absurd thresholds for users practicing the same few topics daily.

### 2. Vuelta derived from attempt counts, not from explicit cycle management

`vueltaActual = min(attemptCount over active topics) + 1`; cobertura de la vuelta = share of active topics with `attemptCount ≥ vueltaActual`. Rationale: zero user management (same philosophy as sessions); always well-defined; honest — one neglected topic correctly keeps the vuelta open, and the cobertura shows exactly where the hole is. Alternative considered (vuelta as date-anchored window: "topics practiced since the vuelta started") — rejected: requires detecting/storing vuelta boundaries, drifts when practice is irregular, and invites management UI.

### 3. One calculator, value types in and out

`TopicInsightsModel.evaluate(topics: [TopicFacts], reference: Date)` → per-topic `TopicInsight` (state, daysSinceLast, suggestion rank inputs) + `StudyCycle` (vuelta, cobertura, cadence). `TopicFacts` is a plain projection (id, attemptDates, durations) so tests need no SwiftData and the Ficha/Vuelta/Extracción changes consume one API. Mirrors `ProgressSummary`'s proven shape.

### 4. Suggestion ordering defined here, weighting left to consumers

The model exposes the canonical ordering (pendientes → olvidados oldest-first → al día → recientes). The extraction change will map it to draw weights; the Ficha will render its head as "qué hacer ahora". Keeping weights out of this change avoids speccing a feature that hasn't been designed.

### 5. Progress-and-history realignment is additive

Its "Temas olvidados" section gains a pointer to this model as the owning definition; global projections are documented as derivations over topic-level facts. No requirement-level behavior changes (Progreso renders the same numbers today).

## Risks / Trade-offs

- [Pooled cadence hides per-topic rhythms] → Deliberate v1 simplification: one explainable number. Per-topic cadence is a contained evolution inside the model if real usage demands it.
- [min-based vuelta feels harsh with stragglers] → It is the honest definition; cobertura communicates progress while the vuelta stays open. Copy/UI concerns belong to the Vuelta change.
- [Thresholds (7/14/21/2×) are judgment calls] → Centralized as named constants in one place, documented in the foundation; tuning later touches one file and one doc.
- [Over-modeling] → Scope test applied: everything specced is consumed by Ficha, Vuelta or Extracción; nothing speculative (no difficulty, no priorities, no spaced repetition).

## Migration Plan

Foundation doc → pure logic + tests → progress-and-history pointer → Current Context. No app behavior changes; suite must stay green untouched except additions.

## Open Questions

- None blocking. Where the Vuelta lives in the IA (Progreso evolved vs. Temarios header) is explicitly deferred to the Vuelta change.
