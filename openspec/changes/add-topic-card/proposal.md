## Why

The tema detail today is a Practicar button plus an attempt list — an index, not a workbench. The topic is the opositor's unit of work ("el 47 lo tengo abandonado"), the insights model now defines its semantics, and the IA foundation already promised "evolución temporal sencilla" in this screen. The Ficha de tema is construction step 1 of V1 (el Ciclo de estudio): the screen that answers *¿cuándo lo canté, cuántas veces, cómo evoluciona, qué notas tengo, qué me conviene ahora?*

## What Changes

- The tema detail becomes the **Ficha de tema**, consuming `TopicInsightsModel` (never re-implementing semantics):
  - **Estado** with its one-sentence explanation from the foundation (Pendiente / Reciente / Al día / Olvidado — icon + text + restrained color, never color alone; Amber for olvidado as *attention*, never red/judgment) plus the key facts: attempt count, total practice time, days since last practice.
  - **Evolución**: a calm Swift Charts line of recent attempt durations (native, editorial — no gridded dashboard), shown only when there are at least two timed attempts.
  - **Notas recientes**: the latest notes across attempts surfaced on the ficha, each linking to its intento.
  - The state explanation doubles as the "qué hacer ahora" cue — facts phrased gently, never scheduling.
- Practicar stays the most prominent action (foundation rule unchanged); the historial list remains.
- Insights are computed at opposition scope inside the view (the pooled cadence needs all topics) — derived on read, nothing persisted.

## Capabilities

### New Capabilities

<!-- none — this evolves the existing tema detail -->

### Modified Capabilities

- `tema-detail-history`: the tema detail screen requirement gains the ficha sections (estado + hechos, evolución, notas recientes) on top of its existing content.

## Impact

- Modified: `Views/TopicDetailView.swift` (ficha sections), `Logic/TopicInsights.swift` (+`TopicFacts(topic:)` projection initializer).
- New framework usage: Swift Charts (native, no dependency).
- Tests: `TopicFacts` projection from models; suite stays green.
- Docs: `Current Context.md`. The IA foundation needs no change — the ficha delivers what it already promised.
