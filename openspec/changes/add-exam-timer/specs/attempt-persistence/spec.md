## ADDED Requirements

### Requirement: Target delta metric for countdown practices
When a practice was configured with a countdown target, finishing SHALL additionally persist a Métrica of type diferencia objetivo (`targetDelta`) whose value is the recorded duration minus the target (negative = finished early, positive = overran). Count-up practices SHALL NOT produce this metric. The metric is a fact for longitudinal analysis ("¿me ajusto al tiempo de examen?"), never a judgment.

#### Scenario: Finished inside the slot
- **WHEN** a 15-minute-target practice finishes at 13:40 recorded
- **THEN** a targetDelta metric with value −80 seconds is persisted alongside the duración total metric

#### Scenario: Count-up practice
- **WHEN** a practice runs in count-up mode
- **THEN** no targetDelta metric is created
