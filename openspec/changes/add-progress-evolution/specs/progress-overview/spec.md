## MODIFIED Requirements

### Requirement: Editorial progress summary
The Progreso tab SHALL answer **"¿qué ha cambiado?"** — never "¿qué hago ahora?", which belongs to Temarios. It SHALL present, scoped to the active opposition and a user-selected time window (últimos 30 días, 90 días, todo el histórico):

- **En este periodo**: the window's activity facts — prácticas realizadas, tiempo total, días con práctica.
- **Evolución del temario**: two stacked composition bars — the whole syllabus colored by visible state, **speaking the same visual language as the Estado map** — explicitly anchored in time ("Hace 30 días" / "Hoy"), derived by evaluating the same insights model at the past reference (no snapshots, retroactive). A narrative sentence captions the change in plain words ("Hace 30 días tenías 0 temas al día; hoy tienes 2") and doubles as the accessibility summary. No arrow notation, no unlabeled charts, no single-state lines.

The evolution section SHALL render only with sufficient history (at least 14 days since the first attempt); before that, a quiet explanation takes its place — the film is never projected from a single frame. All values SHALL be derived at read time. Current-state distribution (most/least practiced) SHALL NOT appear here — the Estado del temario map owns the photo.

#### Scenario: The film after three months
- **WHEN** the user opens Progreso with the 90-day window after months of practice
- **THEN** two bars show the syllabus's composition then and now — the temario visibly changing color — with the narrative sentence stating the change

#### Scenario: A single day of history is not a film
- **WHEN** the user has practiced only within the last few days
- **THEN** the evolution section shows a calm explanation that evolution appears with more days of practice — no flat noise, no broken-looking charts

#### Scenario: Retroactive from day one
- **WHEN** a user who never opened Progreso selects "Todo"
- **THEN** the evolution renders from their first attempt onward — no prior visits or snapshots were needed

### Requirement: No judgment, no gamification
Progreso SHALL show facts only: no scores, no rankings, no streak pressure, no auto-evaluation labels. Deltas are numbers with direction, never praised or scolded.

#### Scenario: Facts without evaluation
- **WHEN** a delta worsened (more topics need review than before)
- **THEN** the numbers state it plainly with no alarm copy or red theater

### Requirement: Progress empty state
When no intentos exist, Progreso SHALL show an empty state explaining that evolution appears as the user practices.

#### Scenario: Fresh install
- **WHEN** the user opens Progreso with zero intentos
- **THEN** the screen explains evolution will appear with practice and points the user to Temarios
