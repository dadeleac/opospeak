## Why

Two "Tema 1" cells in the map exposed the real issue: the Estado screen renders topics while hiding the level the opositor actually thinks in — *"voy mal en Procesal, Civil lo tengo controlado"*. The syllabus is not a folder; it is a unit of state. Decision taken with David: extend the existing semantics (one model, one aggregate at different scopes) rather than opening a new foundation document — fragmenting the semantics we just unified would recreate the drift the insights model exists to prevent.

## What Changes

- **Aggregation levels in the foundation** (`define-topic-insights-model` extended, not duplicated): tema → temario → oposición, the same state computation over different subsets. The **cadence stays opposition-wide** (the rhythm belongs to the person, not the block).
- **Reference-date honesty fix in the model**: `evaluate` ignores attempts after the reference date, so evaluating at a past date is truthful — the seam that later lets Progreso derive evolution ("estado hace 90 días") retroactively, with zero snapshots.
- **Estado screen with per-syllabus blocks** (only when the opposition has more than one syllabus — with one, nothing changes): the map sections by temario (name + compact per-block breakdown + its grid), eliminating the duplicate-number ambiguity structurally instead of cosmetically. Global summary and Siguiente stay opposition-level.
- **Qualified rows everywhere it matters** (again only multi-syllabus): Siguiente, the state groups and the "Ver todos" lists show the temario as secondary text ("Tema 1 — Civil").
- **Ficha context**: the topic detail shows its temario as the navigation subtitle.
- Rejected explicitly: invented codes (C1/O1 — cryptic in six months), syllabus-by-color (color already encodes state), per-syllabus-only state (kills the "estoy viendo mi oposición" screen rated 9/10).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `topic-insights`: aggregation levels; reference-date honesty.
- `study-cycle-overview`: per-syllabus map blocks and qualified rows under multi-syllabus oppositions.
- `tema-detail-history`: the Ficha gains its temario as context.

## Impact

- Modified: `Logic/TopicInsights.swift` (reference filter), `Views/StudyCycleView.swift` (blocks + qualified rows), `Views/TopicDetailView.swift` (subtitle), `foundation/define-topic-insights-model.md`, `Current Context.md`.
- Tests: future-attempt honesty; existing suite untouched otherwise.
