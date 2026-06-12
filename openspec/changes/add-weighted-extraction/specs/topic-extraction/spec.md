## ADDED Requirements

### Requirement: Weighted draw from a syllabus
The user SHALL be able to draw a random topic from a syllabus ("sacar bola"). The draw SHALL be weighted by the topic's insight state — pending and forgotten topics more likely, recently practiced less likely — using weights defined once in pure logic over `TopicInsightsModel` output. Archived topics SHALL be excluded. The drum is per syllabus; drawing across the whole opposition is out of scope (deferred to simulacros). With every topic recently practiced the draw approaches uniform — the honest drum. The weighting SHALL be explained to the user in one factual line; the mechanism is never a black box.

#### Scenario: The drum is loaded toward what needs work
- **WHEN** a syllabus has pending, forgotten and recently practiced topics and the user draws many times
- **THEN** pending and forgotten topics come out more often than recent ones, and any active topic can come out — like the exam

#### Scenario: All caught up
- **WHEN** every topic in the syllabus is recently practiced
- **THEN** the draw is approximately uniform

### Requirement: The ball is a moment, not a redirect
The drawn topic SHALL be presented before any practice starts — number and title, the ball from the drum. From the result the user can start a practice of that topic ("Cantar este tema") or draw again. Drawing SHALL never start a recording by itself.

#### Scenario: Drawing then singing
- **WHEN** the user draws a ball and taps Cantar este tema
- **THEN** the standard practice flow opens for that topic (preparation → listo → Grabar), nothing recorded yet

### Requirement: Re-draw without judgment
The user SHALL be able to draw again without limit. The new ball replaces the previous one. No history of rejected balls SHALL be kept, surfaced, or persisted; no metric, streak, or label SHALL ever reference re-draws. The product helps the opositor study; it does not watch them.

#### Scenario: Sacar otra
- **WHEN** the user draws again three times and then closes the screen
- **THEN** nothing anywhere records that any ball was passed over
