## Why

The V1 arc (el Ciclo de estudio: Ficha de tema → Vuelta al temario → Extracción ponderada, per `research/post-mvp-opportunity-analysis.md`) rests on concepts the product has never defined: *olvidado*, *reciente*, *pendiente*, *vuelta*, *cobertura*. If each feature improvises its own definition, "olvidado" will mean three different things in three screens within months. This change defines the semantics once — as a foundation document and as pure, tested logic — before any screen consumes them. Same pattern that already paid off twice: CloudKit-compat before CloudKit, targetDelta before the exam timer.

## What Changes

- **New foundation document `define-topic-insights-model.md`**: what OpoSpeak knows about a topic (facts), the derived temporal states (pendiente / reciente / al día / olvidado) with exact definitions, the revisit-cadence concept that makes "olvidado" relative to the user's own rhythm, the vuelta and cobertura semantics, the suggestion ordering, and the ethical boundary (states speak of time, never of quality — no "dominado", no judgment).
- **Pure logic implementation** (`Logic/TopicInsights.swift`): `TopicFacts` (input projection), `TopicState`, `StudyRhythm` (cadence), `StudyCycle` (vuelta + cobertura), and `TopicInsightsModel` as the single calculator — table-tested, no UI, no schema changes.
- **`define-progress-and-history-model` realigned**: references the new model as the topic-level layer its global projections derive from; its embryonic "temas olvidados" definition migrates here.
- No screens in this change: Ficha, Vuelta and Extracción are subsequent changes consuming this model.

## Capabilities

### New Capabilities

- `topic-insights`: the semantic model — facts, states, cadence, cycle, suggestion ordering, and the no-judgment boundary — plus its computation contract.

### Modified Capabilities

<!-- none at requirement level — Progreso keeps its current behavior; realignment is documentation-level. UI consumption arrives with Ficha/Vuelta changes -->

## Impact

- New: `Doc OpenSpeak/foundation/define-topic-insights-model.md`, `Logic/TopicInsights.swift`, `opospeakTests/TopicInsightsTests.swift`.
- Modified: `Doc OpenSpeak/foundation/define-progress-and-history-model.md` (reference + olvidados migration), `Current Context.md`.
- No schema changes, no UI changes, no behavior changes.
