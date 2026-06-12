## Context

Boundary decided with David after the syllabus-state work: Temarios = photo, Progreso = film. The advisor's instinct ("define-progress-vs-state-model") lands as a *revision* of the existing `define-progress-and-history-model` — which, notably, already lists time windows (7/30/90/all) in its "Evolución temporal" section; the doc anticipated this. The reference-honesty fix makes past states exactly derivable: the film needs no recording.

## Goals / Non-Goals

**Goals:** boundary codified in the progress doc; `statusSeries` in the model; Progreso redesigned (window selector, period facts, state deltas, one chart); distribution removed from Progreso; IA doc question updated.

**Non-Goals:** no snapshots or caching; no 7-day window in v1 (too noisy for state deltas; the doc keeps it listed for activity facts later); no per-syllabus evolution yet (opposition-level first; the aggregation seam exists); no custom date ranges; no judgment vocabulary.

## Decisions

### 1. `statusSeries` lives in the insights model

`statusSeries(topics:from:to:samples:)` → `[(date, SyllabusStatus)]`, each point a full `evaluate` at that reference. It is semantics (what was my status then), so it lives with the semantics. Cost: samples × evaluate over ≤1000 light projections — trivial. Deltas are just `series.first/last`; no separate delta API to drift.

### 2. Three windows: 30 / 90 / Todo

"Todo" starts at the earliest attempt (before it, everything is sin practicar — honest and visible). The 7-day window from the doc's list is omitted in v1: state transitions need weeks to be meaningful; a 7-day delta would mostly read "0 → 0". Activity facts could justify it later.

### 3. The window's activity facts reuse `ProgressSummary`

Attempts filtered to the window feed the existing summary (prácticas, tiempo, días con práctica). Consistency metrics (days practiced in last 7/30) become redundant with the window concept and drop from display; volumen-in-window replaces them. One less parallel computation.

### 4. Deltas rendered as "entonces → ahora" rows with state styling

Per visible state: icon (TopicStateStyle) + label + "18 → 43". Direction shown by the numbers themselves — no arrows-of-judgment, no green/red deltas (facts, not grades). One chart only: temas al día across the window (LineMark, Ink, 12 samples, minimal axes) — the single most meaningful line; charting all three states would turn the film into a dashboard.

### 5. Distribution leaves Progreso

Más/menos practicado is a photo — the Estado map shows distribution better and with navigation. The progress doc records the handoff explicitly so the question "where did distribución go?" has a written answer.

## Risks / Trade-offs

- [12 evaluations per render] → Microseconds at real volume; memoize only if profiling ever asks.
- [Decay-driven deltas can look discouraging ("al día 43 → 18" after a break)] → They are the truth; copy stays neutral, no alarm styling. The empty/quiet states never nag.
- [Removing consistency rows changes a shipped screen] → The window facts carry the same information with clearer framing; the foundation revision documents the replacement.

## Migration Plan

Model series + tests → progress doc revision → IA doc → view redesign → suite.

## Open Questions

- None. Per-syllabus evolution and custom windows are deliberate later steps.
