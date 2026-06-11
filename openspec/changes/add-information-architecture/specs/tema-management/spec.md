## ADDED Requirements

### Requirement: Tema list inside temario detail
The temario detail SHALL list the temario's active temas showing at minimum: number or identifier, title if present, date of last intento, and intento count. A tema without title SHALL display as "Tema <número>".

#### Scenario: Untitled tema display
- **WHEN** a tema has number 42 and no title
- **THEN** its row shows "Tema 42"

### Requirement: Single tema creation
The user SHALL be able to create a tema providing only a number; the title is optional. The suggested number SHALL default to the next free number in the temario.

#### Scenario: Create tema with number only
- **WHEN** the user creates a tema with number 5 and no title
- **THEN** the tema is persisted and appears in the list as "Tema 5"

### Requirement: Bulk tema creation
The user SHALL be able to create a consecutive range of temas in one action ("crear temas del 1 al N"). The action SHALL create one untitled tema per number in the range, skipping numbers that already exist in the temario. The range SHALL be validated (start ≥ 1, end ≥ start, total ≤ 1000).

#### Scenario: Bulk create a full syllabus
- **WHEN** the user requests temas 1 to 325 in an empty temario
- **THEN** 325 untitled temas numbered 1..325 are created

#### Scenario: Bulk create skips existing numbers
- **WHEN** temas 1 and 2 already exist and the user requests temas 1 to 5
- **THEN** only temas 3, 4, and 5 are created

### Requirement: Tema search
The temario detail SHALL allow searching temas by number and by title text.

#### Scenario: Search by number
- **WHEN** the user types "42" in search
- **THEN** the list shows tema 42 (and any tema whose title contains "42")

### Requirement: Tema sorting
The temario detail SHALL offer the sort orders defined by the foundation: natural order (by number), most practiced, least practiced, last practiced, and pending (never practiced first).

#### Scenario: Least practiced ordering
- **WHEN** the user selects "menos practicados"
- **THEN** temas are ordered by ascending intento count

### Requirement: Tema archiving
The user SHALL be able to archive a tema. Archived temas SHALL be hidden from the main list and keep their full history. Destructive tema deletion SHALL NOT be offered in this change.

#### Scenario: Archived tema keeps intentos
- **WHEN** a tema with 12 intentos is archived
- **THEN** it leaves the list and the 12 intentos remain persisted

### Requirement: Tema empty state
When a temario has no temas, the detail SHALL show an empty state offering both single creation and bulk creation.

#### Scenario: Empty temario invites bulk creation
- **WHEN** the user opens a temario with zero temas
- **THEN** the screen offers "añadir tema" and "crear temas del 1 al N"
