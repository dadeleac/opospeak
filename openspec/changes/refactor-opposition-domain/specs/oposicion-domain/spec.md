## ADDED Requirements

### Requirement: Oposicion root entity
The system SHALL persist an `Oposicion` entity with a unique identifier, a required name, an optional description, an active flag, and creation/update dates. An oposición SHALL contain zero or more temarios (1:N, cascade on delete, with inverse). Judicatura, Notarías or Inspección de Hacienda are oposiciones; Civil, Penal or Procesal are temarios within one.

#### Scenario: Real-world hierarchy
- **WHEN** a user prepares Judicatura with Civil, Penal and Procesal
- **THEN** Judicatura is one Oposicion containing three Temarios, each containing its temas

#### Scenario: Cascade protects nothing it shouldn't
- **WHEN** an oposición is deleted at the domain level
- **THEN** its temarios, temas and their full history cascade — and therefore the UI SHALL NOT offer oposición deletion (rename only)

### Requirement: Multi-oposición domain, single-oposición UI
The domain, storage and relationships SHALL support multiple oposiciones. The UI SHALL operate on one **active** oposición: the only existing one, or the one referenced by a device-local setting, falling back to the first. No oposición picker SHALL exist in this change.

#### Scenario: Two oposiciones in data, one in UI
- **WHEN** the store contains two oposiciones
- **THEN** the Temarios tab and Progreso show only the active one's data, and the other remains intact and reachable in a future change

### Requirement: Startup backfill adopts orphan temarios
At startup, temarios without an oposición (pre-refactor data) SHALL be adopted by an auto-created oposición named "Mi oposición". The pass SHALL be idempotent and create at most one such oposición.

#### Scenario: Existing user upgrades
- **WHEN** the app launches with three orphan temarios from before the refactor
- **THEN** one "Mi oposición" is created, the three temarios belong to it, and a second launch changes nothing
