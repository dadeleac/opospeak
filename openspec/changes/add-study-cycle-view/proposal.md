## Why

Today the home screen shows the opposition's name and two syllabus rows over mostly empty space — after three months of real use it would still answer nothing. The user knows how Tema 1 is going (the Ficha) but not how their oposición is going. The Vuelta closes that gap and, decided with David over the actual screens: it lives in **Temarios** (it answers "¿qué voy a practicar?"), not in Progreso (which answers "¿cómo voy?"). It also sharpens the product's answer to "why not Voice Memos": *because it shows you the real state of your preparation.*

## What Changes

- **Phase 1 — Vuelta card** as the header of the Temarios screen, strictly factual (no suggestions, no algorithms — David's explicit call: recommendations must be earned with data, not shipped day 1):
  - Vuelta actual (number), cobertura ("187 de 325 temas practicados", with a restrained progress bar), count of temas olvidados (only when > 0), and "Ver detalle". The whole card navigates to the detail. Hidden while the opposition has no topics (empty states keep their job).
- **Phase 2 — Vuelta detail** (`StudyCycleView`, pushed within the Temarios stack): cobertura summary, **mapa del temario** (grid of topics tinted by state, with legend and per-cell accessibility labels; the grouped lists below provide the non-color channel), and factual groups — **Temas olvidados** (oldest first), **Temas pendientes** (never practiced), **Temas recientes**. Every topic navigates to its Ficha.
- All semantics from `TopicInsightsModel` (states, vuelta, cobertura) — nothing re-implemented; nothing persisted.
- State styling (label/icon/color) extracted from the Ficha into a shared helper so card, map and Ficha stay literally consistent.
- **Phase 3 explicitly deferred** (suggestion, weighted extraction, priorities): the model's canonical ordering exists and waits; surfacing it is a future change once real data justifies recommendations.
- `define-information-architecture` updated: the Vuelta's home is decided (Temarios header + drill-in; Progreso stays reflective).

## Capabilities

### New Capabilities

- `study-cycle-overview`: the Vuelta card and detail — factual position in the cycle, the map, and the state groups.

### Modified Capabilities

- `temario-management`: the Temarios screen gains the Vuelta card above the syllabus list.

## Impact

- New: `Views/StudyCycleView.swift`, `Views/TopicStateStyle.swift` (shared state styling).
- Modified: `Views/SyllabusListView.swift` (card), `Views/TopicDetailView.swift` (uses shared styling), `Doc OpenSpeak/foundation/define-information-architecture.md`, `Current Context.md`.
- No schema changes; no new logic beyond filters over existing insights; suite stays green.
