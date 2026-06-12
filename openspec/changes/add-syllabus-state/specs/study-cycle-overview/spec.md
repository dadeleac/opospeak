## ADDED Requirements

### Requirement: Per-syllabus blocks under multi-syllabus oppositions
When the active opposition has more than one active syllabus, the Estado screen's map SHALL section by temario: each block shows the syllabus name, a compact per-block state breakdown, and its own grid — topic numbers are unique within their block, eliminating duplicate-number ambiguity structurally. The global summary and Siguiente SHALL remain opposition-level. With a single syllabus, the screen SHALL stay exactly as today (no headers, no noise for a problem that does not exist).

#### Scenario: Civil and Otra coexist
- **WHEN** the opposition has Civil (25 topics) and Otra (1 topic)
- **THEN** the map shows a "Civil" block and an "Otra" block, each with its breakdown and grid, and the two "Tema 1" live unambiguously in their blocks

#### Scenario: Single-syllabus oppositions pay nothing
- **WHEN** the opposition has one syllabus
- **THEN** the map renders as a single grid with no block headers

### Requirement: Qualified rows under multi-syllabus oppositions
When the opposition has more than one active syllabus, every topic row outside its syllabus context — Siguiente, the state groups, and the "Ver todos" lists — SHALL show the temario as secondary text. The Ficha SHALL show its temario as navigation context. No invented codes (C1/O1) SHALL be used anywhere.

#### Scenario: Two unpracticed Tema 1
- **WHEN** both Civil and Otra have an unpracticed Tema 1 listed under "Sin practicar"
- **THEN** the rows read "Tema 1 — Civil" and "Tema 1 — Otra"

#### Scenario: Ficha in context
- **WHEN** the user opens a Ficha from any surface in a multi-syllabus opposition
- **THEN** the temario name is visible as the screen's subtitle
