## Why

With the Estado del temario absorbing coverage, states and per-syllabus breakdowns, Progreso was on track to become "4 gráficas, 2 contadores, 1 pantalla que nadie abre". The boundary decided with David: **Temarios is the photo ("¿qué hago ahora?"); Progreso is the film ("¿qué ha cambiado?")**. And the film costs nothing: the reference-honesty seam shipped in `add-syllabus-state` makes past states exactly derivable — evolution with zero snapshots, retroactive from day one of data.

## What Changes

- **The Estado/Evolución boundary codified** in `define-progress-and-history-model` (revision of the existing doc — not a new one): Progreso answers "¿qué ha cambiado?" over time windows; anything answering "¿qué hago ahora?" belongs to Temarios. Current-state distribution (más/menos practicado) leaves Progreso — the Estado map shows distribution better.
- **`statusSeries` in the insights model**: the syllabus status sampled across a window (each sample = `evaluate` at a past reference). Pure, tested.
- **Progreso redesigned as evolution**, scoped to the active opposition:
  - Window selector: Últimos 30 días / 90 días / Todo.
  - **En este periodo** (the window's facts): prácticas, tiempo total, días con práctica — `ProgressSummary` over the window's attempts.
  - **Evolución del temario** (the gem): state deltas "entonces → ahora" per visible state ("Al día 18 → 43", "Necesitan repaso 35 → 12", "Sin practicar 103 → 50") plus one restrained chart — temas al día across the window.
  - Empty state unchanged; no judgment, no streak pressure, facts only.
- IA doc updated: Progreso's question becomes "¿qué ha cambiado?".

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `progress-overview`: from current-state editorial counters to windowed evolution.
- `topic-insights`: derived status series over a window (riding the reference-honesty requirement).

## Impact

- Modified: `Logic/TopicInsights.swift` (+`statusSeries`), `Views/ProgressOverviewView.swift` (redesign), `foundation/define-progress-and-history-model.md` (boundary + evolution framing), `foundation/define-information-architecture.md` (Progreso section), `Current Context.md`.
- Tests: series sampling (endpoints, count, empty); suite green.
- No schema changes; everything derived.
