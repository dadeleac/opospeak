## Why

The real oral exam draws topics by lottery — balls from a drum. Practicing by always choosing your own topic trains a comfortable version of the exam: everyone gravitates to what they already know well. The extraction is OpoSpeak's ritual moment: tap, a topic comes out, you sing it. Exam realism — with the product twist that makes it ours: **the ball is biased by the insights**. Pending and forgotten topics weigh more; recently practiced ones weigh less. The randomness of the exam, aimed where it helps. It closes the Ciclo de estudio arc: Ficha (one topic) → Vuelta (all of them) → **Bola (the decision)** — and it consumes `TopicInsightsModel` as its single source of semantics, like every other surface.

**Status: specified, not scheduled.** This change is deliberately written ahead of implementation because the idea is mature and the decisions are taken (see below). Implementation is gated on the activation criterion: **evidence from real users (TestFlight) that "Siguiente" is used recurrently** — both mechanisms answer "¿qué canto hoy?", and if nobody uses the deterministic recommendation, the ritualized version needs rethinking, not building.

## Decisions taken (founder-reviewed)

- **Per-syllabus drum**: each temario has its own rhythm (Civil ≠ Penal ≠ Procesal) and exams draw within blocks. Global extraction is deferred to simulacros (V2).
- **Re-draw allowed, without record**: "Sacar otra bola" replaces the ball, keeps no history of rejections, attaches no guilt, no metrics. The goal is helping study, not surveilling the opositor.
- **The ball is always shown before practicing**: the emotional moment is the result (number + title, like a ball from the drum). "Cantar este tema" then leads into the practice flow; never straight to recording.
- **Weights derive from insight states**: defined once, in pure logic, inheriting any future evolution of the model automatically.
- **Transparency**: one factual line explains the bias ("Salen más los temas que llevas más tiempo sin cantar"). Datos > interpretación.

## What Changes

- Pure `WeightedExtraction` logic (injectable randomness, table-tested distribution and determinism).
- An extraction surface — placement to be finalized at implementation time: alongside "Siguiente" in Estado del temario, or as part of a future "Hoy" home evolution (the rational answer and the ritual answer to the same question, side by side, fed by the same engine).

## Capabilities

### New Capabilities

- `topic-extraction`: weighted random draw of a topic from a syllabus, biased by topic insights.

### Modified Capabilities

<!-- none — consumes topic insights read-only -->

## Impact

- New: `Logic/WeightedExtraction.swift` (pure), extraction moment UI.
- Reads `TopicInsightsModel` output; touches no schema, no recorder, no persistence.
- Tests: seeded-RNG determinism, weight distribution, edge cases (single topic, all recent, empty syllabus).
- Docs: `research/post-mvp-opportunity-analysis.md` (product map, V1.5), foundation amendment for extraction semantics when implemented.
