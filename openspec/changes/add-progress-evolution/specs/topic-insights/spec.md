## ADDED Requirements

### Requirement: Derived status series
The model SHALL provide the syllabus status sampled across a time window: a series of (date, status) points where each point is the full evaluation at that past reference — riding the reference-honesty requirement, never persisted. Consumers receive identical semantics at every point in time.

#### Scenario: A truthful film strip
- **WHEN** a 90-day window is sampled at twelve points
- **THEN** each point reports exactly the status the user had on that date, and the last point equals today's status

#### Scenario: Empty history
- **WHEN** the series is requested with no attempts
- **THEN** every sample reports all topics sin practicar — well-defined, no errors
