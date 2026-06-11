## ADDED Requirements

### Requirement: Sessions are created automatically
A Sesión SHALL be created automatically when a practice finishes and no reusable sesión exists. The user SHALL never create, see, or manage sessions.

#### Scenario: First practice of the day
- **WHEN** the user finishes a practice and no sesión is active within the reuse window
- **THEN** a new sesión of type práctica individual is created and the intento is linked to it

### Requirement: Session reuse window
Consecutive practices SHALL share a sesión while the gap since the sesión's last activity is within 30 minutes. Beyond the window, a new sesión SHALL be created. The reuse decision SHALL be pure, testable logic.

#### Scenario: Back-to-back practices share a session
- **WHEN** the user finishes a second practice 10 minutes after the first
- **THEN** both intentos belong to the same sesión

#### Scenario: A long break starts a new session
- **WHEN** the user finishes a practice 45 minutes after the previous activity
- **THEN** a new sesión is created for it

### Requirement: Session closure
A sesión's end date SHALL track the end of its latest intento, so an inactive sesión is effectively closed without any explicit user or timer action.

#### Scenario: Session end follows last intento
- **WHEN** a sesión's latest intento ends at 10:45
- **THEN** the sesión's fechaFin is 10:45
