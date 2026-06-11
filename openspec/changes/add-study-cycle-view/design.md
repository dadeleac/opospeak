## Context

IA decision taken with David over real screenshots: the Vuelta answers "¿qué voy a practicar?" → it lives in Temarios (entry point), not in Progreso ("¿cómo voy?", reflective). Refinement from review: **no suggestions in v1** — start factual; recommendations are earned with data (Phase 3). The Ficha shipped; the insights model owns every definition. The home screen today is mostly empty space — this change makes it alive.

## Goals / Non-Goals

**Goals:** factual Vuelta card as Temarios header; Vuelta detail (cobertura, map, state groups) in the same stack; shared state styling; IA foundation updated with the decision.

**Non-Goals:** no "tema sugerido", no weighted extraction, no priorities (Phase 3, future change); no Progreso changes (stays reflective); no per-syllabus vuelta (the cycle is opposition-scoped by the model); no new persistence.

## Decisions

### 1. One evaluation feeds card and detail

Both compute `TopicInsightsModel.evaluate` over the active opposition's active topics (via relationships, like the Ficha). The card consumes `StudyCycle` + one count; the detail consumes the full insights. No caching until profiling asks (≤ ~1000 lightweight projections).

### 2. Card: four facts, one tap, self-hiding

Vuelta number, cobertura line + thin `ProgressView`, olvidados count (hidden at zero — no alarm theater), chevron "Ver detalle". The whole card is one `NavigationLink`. Hidden without topics so empty states keep teaching. Rationale: David's rule — position, not prescription; one card that cannot grow into a dashboard.

### 3. Map: tinted grid + legend + textual redundancy

`LazyVGrid` of compact cells (topic number on state-tinted background). WCAG "color never the only signal" is satisfied three ways: a legend pairing icon+text+color, per-cell accessibility labels ("Tema 47, olvidado"), and the grouped lists below carrying the same information textually. Cells navigate to the Ficha. 325 cells in a scrolling grid is trivial for LazyVGrid.

### 4. State styling extracted to one shared helper

`TopicStateStyle` (label, icon, color, explanation per state) moves out of the Ficha into `Views/TopicStateStyle.swift`; Ficha, card, map and legend consume it. Rationale: the semantics live in the model; the *presentation* of the semantics must also have a single home, or Amber-forgotten drifts.

### 5. Groups ordered by fact, not by suggestion

Olvidados sorted by oldest last-practice (a fact), pendientes by topic number, recientes by most recent. This is deliberately NOT the canonical suggestion ordering as a single ranked list — groups are navigation, not prescription. The ordering API stays internal for Phase 3.

### 6. IA foundation records the decision

`define-information-architecture`: the Vuelta's home (Temarios header + drill-in), Progreso explicitly unchanged, and the deferred-suggestion note. This closes the open question flagged when the insights model shipped.

## Risks / Trade-offs

- [Card pushes syllabi down on small screens] → Four compact lines; syllabi remain above the fold on 4.7"-class screens; the card earns its space by being the answer to the daily question.
- [Map with hundreds of cells gets dense] → Density is the point (the at-a-glance gestalt); legend + groups provide the readable channel; cells are tap targets ≥ 36pt.
- ["Olvidados: 12" reads as nagging] → Copy is a count, Amber (attention) not red, hidden at zero; the foundation's no-judgment rule is in the spec.
- [Two surfaces computing insights drift] → Impossible by construction: one model, one styling helper.

## Migration Plan

Shared styling → card → detail → IA doc → suite. No schema, no behavior changes elsewhere.

## Open Questions

- None blocking. Phase 3 (suggestion + weighted extraction) is the next deliberate decision, with usage data.
