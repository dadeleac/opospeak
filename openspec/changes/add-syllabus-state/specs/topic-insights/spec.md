## ADDED Requirements

### Requirement: Aggregation levels share one computation
The state aggregate (al día / necesitan repaso / sin practicar) SHALL be computable at three scopes — tema (its own state), temario (over its active topics), oposición (over all active topics) — using the **same definitions and the same calculation**, never a parallel one. The revisit cadence SHALL remain opposition-wide at every scope: the rhythm belongs to the person, not the block.

#### Scenario: The block the user is neglecting
- **WHEN** the per-syllabus aggregate is computed for Procesal and Civil
- **THEN** both use the identical state semantics with the user's single opposition-wide cadence, and "voy mal en Procesal" becomes visible as facts

#### Scenario: No second model
- **WHEN** any surface needs a syllabus-level state
- **THEN** it aggregates the same per-topic insights — no re-implementation, no separate thresholds

### Requirement: Evaluation is honest at any reference date
`evaluate` SHALL consider only attempts at or before the reference date. Evaluating at a past date SHALL yield exactly the state the user had then — the derivable seam that lets evolution ("estado hace 90 días") be computed retroactively without persisting snapshots.

#### Scenario: The past does not see the future
- **WHEN** a topic's only attempt happened after the reference date
- **THEN** at that reference the topic is sin practicar and the cadence calculation ignores that interval
