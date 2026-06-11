## Why

Real-device review of the Vuelta surfaced three confirmed decisions (David, explicit): the vuelta-based coverage misleads within a round (a topic sung four months ago still counts as "practicado" — rotation is not health); "Al día" and "Reciente" overlap for the user; and "Vuelta" as a visible word belongs to Judicatura culture, not to every oposición. Plus one addition: surfacing the head of the canonical ordering as a factual "Siguiente" — not an algorithm, just the model's existing order with its reason — which also tames the unmanageable 325-row pending list.

## What Changes

- **Salud del temario** becomes the primary metric (model + card): counts by visible state — al día / necesita repaso / sin practicar — which decay naturally with time. The vuelta-based coverage is demoted to **rotation position**, secondary, visible only in the detail.
- **Three visible states** replacing four: *Sin practicar* (was Pendiente), *Al día* (absorbs Reciente), *Necesita repaso* (was Olvidado — gentler, time-based need, never merit; the nuance is documented in the foundation). The four internal states remain in the model (reciente keeps feeding the suggestion ordering and a brighter visual nuance in the map); the **presentation** collapses to three.
- **"Vuelta" becomes an internal concept**: the card retitles to "Estado del temario"; the round number survives only as a secondary fact inside the detail.
- **"Siguiente"** in the detail: the head of the canonical suggestion ordering with its factual reason ("Hace 42 días sin práctica" / "Todavía no lo has cantado"), one tap to the Ficha. Zero new algorithm.
- **Groups capped at 5** with "Ver todos (N)" → full per-state list; the map already shows the whole syllabus.
- Foundation `define-topic-insights-model` amended with all of the above; IA doc wording updated.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `topic-insights`: salud as primary coverage; visible-state mapping; vuelta visibility rule; suggestion head surfacing.
- `study-cycle-overview`: card shows salud (no vuelta, no prescription beyond Siguiente's facts); detail gains Siguiente, capped groups, and the rotation position as secondary.

## Impact

- Modified: `Logic/TopicInsights.swift` (+`SyllabusHealth`), `Views/TopicStateStyle.swift` (3 visible labels, reciente as nuance), `Views/StudyCycleView.swift` (card + detail + group list destination), `foundation/define-topic-insights-model.md`, `foundation/define-information-architecture.md`, `Current Context.md`.
- Tests: health computation; existing boundary tests unchanged (internal states untouched).
