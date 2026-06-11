## ADDED Requirements

### Requirement: Spanish domain, English code
Product vocabulary, documentation, and UI copy SHALL use the Spanish ubiquitous language (Oposición, Temario, Tema, Intento…). Code-level identifiers (types, properties, functions, enum cases, test names, UserDefaults keys, asset names) SHALL be English, following the official mapping: Oposición→`Opposition`, Temario→`Syllabus`, Tema→`Topic`, Sesión→`PracticeSession`, Intento→`Attempt`, Grabación→`Recording`, Métrica→`Metric`, Nota→`Note`. New code SHALL NOT introduce Spanish identifiers.

#### Scenario: New entity follows the rule
- **WHEN** a future feature adds a Transcripción concept
- **THEN** docs and UI say "Transcripción" and code says `Transcript`, with the mapping recorded in the domain model document

### Requirement: User-facing strings live in the String Catalog
All user-visible strings SHALL be managed by the iOS localization system with Spanish as the development (source) language. SwiftUI view literals SHALL rely on automatic extraction; strings produced outside views SHALL use `String(localized:)`. No user-visible string SHALL bypass localization.

#### Scenario: Adding a new screen
- **WHEN** a developer adds a screen with Spanish copy
- **THEN** its strings appear in `Localizable.xcstrings` after building, with no manual registration

#### Scenario: Future language
- **WHEN** a translation is added to the catalog
- **THEN** the app renders it with zero code changes

### Requirement: Data is not localized
Machine-facing and contract strings SHALL NOT be localized: export package file names and JSON keys (Spanish by contract, per `define-export-format`), the CSV header, persisted enum raw values, and identifiers. The export package SHALL remain byte-compatible with the documented v2 contract.

#### Scenario: Export survives the refactor
- **WHEN** the same data is exported before and after this change
- **THEN** the package structure, keys and values are identical
