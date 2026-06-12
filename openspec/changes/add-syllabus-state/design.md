## Context

Advisor conversation reviewed with David; conclusions adopted with corrections: the syllabus is a unit of state (not a folder), but this is an *extension of the existing semantics*, not a new foundation document — and the proposed "syllabus-health" name would reintroduce the "health" vocabulary deliberately removed. The duplicate "Tema 1" is the symptom; per-syllabus structure is the cure. Part 2 (Progreso as Evolución) is a separate upcoming change; this change plants its seam (reference-date honesty).

## Goals / Non-Goals

**Goals:** aggregation-levels section in the foundation; honest `evaluate` at any reference; per-syllabus map blocks + qualified rows (conditional on >1 syllabus); Ficha subtitle; A+F from the prior decision absorbed structurally.

**Non-Goals:** no new foundation doc; no per-syllabus cadence (the rhythm is the person's); no syllabus-level Siguiente or per-block suggestion; no Progreso changes (next change); no syllabus colors or invented codes (rejected).

## Decisions

### 1. Same aggregate, different subset — no new types

`SyllabusStatus` already aggregates any `[TopicInsight]`. Per-syllabus state = `status(insights of that syllabus's topics)`. The view groups insights by syllabus via the existing topic lookup; the model gains nothing new except honesty. Rationale: the advisor's question list ("¿cómo se calcula al día?"…) is already answered with formulas and tests — extending beats duplicating.

### 2. Reference honesty inside `evaluate`

Attempts after the reference are filtered before computing states, counts, cycle AND cadence. Rationale: today a past-dated evaluation would see the future (negative day distances, inflated counts). One filter makes `evaluate(topics, reference: past)` a truthful time machine — the entire upcoming Evolución feature rides on this line.

### 3. Conditionality on `activeSyllabi.count > 1`

Blocks, qualified rows and breakdown-per-block appear only with multiple syllabi. Rationale: many oposiciones have a single temario; they must not pay context noise for an ambiguity they cannot have. (The Ficha subtitle shows always — context is harmless there.)

### 4. Per-block breakdown is a compact caption, not the vertical card

Under each block header: "18 al día · 4 necesitan repaso · 3 sin practicar" inline. Rationale: the vertical always-three layout exists to disambiguate the *home headline*; inside a named block on the Estado screen the context is established, and N syllabi × 3 lines would bloat the map section. Zero counts included (consistency with the vocabulary-teaching rule).

### 5. Qualified rows as secondary text, never codes

"Tema 1" + caption "Civil" (VStack in rows). Codes (C1) rejected: cryptic in six months, breaks the editorial tone.

## Risks / Trade-offs

- [Estado screen grows with many syllabi] → Each block is compact; the screen is a drill-in, not the home; 3-4 blocks is the realistic ceiling.
- [Reference filter changes behavior] → Only for hypothetical future-dated attempts (impossible via UI today); the new test pins it; suite guards the rest.
- [Per-block caption reintroduces inline ambiguity] → Accepted consciously: ambiguity was a headline problem; under a block title with the legend nearby it reads as state counts.

## Migration Plan

Model honesty + test → foundation section → Estado blocks + qualified rows → Ficha subtitle → suite → docs.

## Open Questions

- None. Progreso-as-Evolución is the next change, riding on the honesty seam.
