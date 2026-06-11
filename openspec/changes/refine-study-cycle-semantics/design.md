## Context

Device review with David scored the cycle's bones high (card 9, map 9, potential 10) and its semantics low (states 6, coverage 5). Three decisions confirmed explicitly: (a) three visible states named Sin practicar / Al día / Necesita repaso, (b) health as the headline with the vuelta demoted to the detail, (c) a factual Siguiente now. The internal model needs no structural change — this is a presentation-semantics revision plus one derived aggregate.

## Goals / Non-Goals

**Goals:** `SyllabusHealth` aggregate; three-state presentation (internal four preserved); card retitled to health; detail with Siguiente, rotation position as secondary, capped groups + full lists; foundation amended.

**Non-Goals:** no threshold changes (cadence math untouched); no weighted extraction (still future); no per-state configurability; no card-level Siguiente (David placed it in the detail — the card stays pure position).

## Decisions

### 1. Internal states stay four; presentation collapses to three

`TopicState` unchanged — recency feeds the suggestion ordering and the map's brighter nuance, and collapsing it in the model would lose information permanently. `TopicStateStyle` maps recent and current to the same label ("Al día") and color family (Sage; recent = filled icon + stronger tint). Rationale: presentation problems get presentation solutions; semantics stay stable for tests and future consumers.

### 2. `SyllabusHealth` as a model-level aggregate

`health(insights:)` → counts (upToDate = recent+current, needsReview = forgotten, unpracticed = pending). It lives in the model, not in views, because it IS semantics ("what does healthy coverage mean") and three surfaces will consume it (card, detail, someday Progreso). Health decays by construction — it is computed over states, which are time-relative.

### 3. "Necesita repaso" with the nuance documented

Gentler than "Olvidado" (which borders on accusation) and action-shaped without scheduling. The foundation records the tension explicitly: *necesita* speaks of elapsed time relative to your own rhythm, never of merit — and consumers must keep it that way.

### 4. Siguiente = `suggestionOrder().first` + its fact

No new computation: the head of the canonical ordering, rendered with its reason (days since last practice, or "Todavía no lo has cantado"). Placed in the detail (David's framing), not on the card — the card states position, the detail offers the hand. One tap to the Ficha.

### 5. Groups capped at five + full-list destination

Five rows per group with "Ver todos (N)" pushing a plain per-state list (`StateGroupDestination: Hashable` + `navigationDestination(for:)`, recomputing insights — consistent with everything else being derived). The map remains the at-a-glance whole.

### 6. Vuelta demoted, not deleted

The rotation position renders as one secondary line in the detail's health section. Judicatura culture finds it; nobody else trips over it. If users ask for it on the card, promoting one line is trivial.

## Risks / Trade-offs

- [Breakdown line gets long on the card] → Zero-count groups omitted; at most three short fragments.
- ["Necesita repaso" read as nagging at scale (300 topics)] → It is the honest count; Amber not red, no urgency copy, and the map gives proportion at a glance.
- [Two coverage numbers confuse] → They never share a surface headline: health on card and detail-primary; rotation as one secondary line with its own name.

## Migration Plan

Model aggregate + style mapping → card → detail (Siguiente, caps, full lists) → foundation + IA docs → tests. Suite green; existing boundary tests untouched.

## Open Questions

- None. All three decisions confirmed by David.
