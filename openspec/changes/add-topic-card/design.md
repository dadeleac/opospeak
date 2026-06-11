## Context

`add-topic-insights-model` shipped the semantics and the pure calculator. The IA foundation already calls the tema detail "el centro de gravedad" and promised "evolución temporal sencilla". This change makes the screen earn those words. Construction order from the approved strategy: Ficha before Vuelta (the map's cells must be worth tapping into).

## Goals / Non-Goals

**Goals:** estado + explanation + facts header; evolución chart; recent notes surfaced; everything derived from `TopicInsightsModel`; Practicar prominence untouched.

**Non-Goals:** no Vuelta (next change, including its IA decision); no extraction; no targetDelta chart overlay yet (durations only — restraint first, target context arrives with per-opposition objectives); no persistence of insights; no redesign of the historial list.

## Decisions

### 1. Insights computed at opposition scope, via relationships, in the view

The pooled cadence needs every active topic of the active opposition; the ficha reaches them through `topic.syllabus?.opposition?.syllabi` — no extra queries, no stored state. One `evaluate` call per render over ≤ ~1000 lightweight projections is negligible; if profiling ever disagrees, memoization is contained. A `TopicFacts(topic:)` projection initializer lives next to the model so every future consumer (Vuelta, extraction) builds inputs identically.

### 2. State copy and color live in one view-layer mapping

Label, symbol, accent and explanation per state in a single helper: Pendiente (Slate, neutral), Reciente (Sage — recent activity), Al día (secondary — calm default), **Olvidado (Amber — attention/review, deliberately never red: red would smell of judgment and the foundation forbids it)**. Always icon + text + color. The explanation sentences are exactly the foundation's one-liners, doubling as the "qué hacer ahora" cue — no separate recommendation engine, no scheduling vocabulary.

### 3. Swift Charts, restrained

Native framework (Apple-first), one `LineMark`+`PointMark` of the last 10 timed durations in Ink, y-axis in minutes, no grid clutter, fixed compact height. Editorial-over-dashboard is a constraint, not a vibe: one line, one color, no legends. Chart renders only with ≥ 2 timed attempts (a single point is noise). Accessibility: the chart gets a summary label ("de 17 a 14 minutos en los últimos N intentos" style is overkill v1 — label with first/last values).

### 4. Notes: surface the three most recent, link to their intento

Flattened from all attempts, sorted by date, capped at 3. Rationale: the ficha answers "¿qué notas tengo?" without becoming the notes archive — the intento detail remains the source. Rows reuse the existing navigation (NavigationLink to Attempt).

### 5. Section order

Practicar (foundation: la acción principal) → Estado → Evolución → Notas recientes → Historial. The estado could argue for the top, but demoting Practicar breaks an explicit foundation rule; the estado sits immediately under it, first thing read after the action.

## Risks / Trade-offs

- [Opposition-wide computation on every render] → Trivial at real volumes; contained memoization if ever needed.
- [Chart drifts toward dashboard] → One mark type, one color, no axis labels beyond minutes, fixed height; the spec's no-judgment scenario guards copy.
- [State colors collide with archive Amber] → Same semantic family (attention/review) — coherent, not colliding.
- [Empty/sparse data] → Every section self-hides: no chart < 2 timed attempts, no notes section without notes; pendiente shows estado + invitation only.

## Migration Plan

Projection initializer + tests → view sections → suite. No schema, no behavior changes elsewhere.

## Open Questions

- None blocking. Where the Vuelta lives (IA) is the next change's decision, as planned.
