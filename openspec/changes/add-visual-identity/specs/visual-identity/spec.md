## ADDED Requirements

### Requirement: Semantic color system
The application SHALL define its palette as semantic tokens in the asset catalog, each with light and dark variants: Tinta (Deep Ink, primary/interactive), Pizarra (Slate, secondary accents), Arena (Warm Sand, screen background) with a raised-surface variant, Salvia (Sage, positive/progress), Ámbar (attention/review actions), and Rojo Apagado (recording state, destructive). Views SHALL reference tokens, never hex values.

#### Scenario: One source of truth
- **WHEN** a designer adjusts Deep Ink's dark variant
- **THEN** every screen updates by editing one colorset, with no code changes

### Requirement: Deep Ink as global tint
Interactive elements (buttons, links, tab selection, toggles) SHALL use Tinta as the application tint, replacing the system default blue.

#### Scenario: Primary action color
- **WHEN** the user sees the Practicar button or the selected tab
- **THEN** it renders in Deep Ink (its dark-mode variant at night), not system blue

### Requirement: Notebook background
List screens SHALL use Arena as their background in light mode (clean notebook on paper) and an ink-tinted near-black in dark mode (nocturnal reading), with raised surfaces using the elevated Arena variant.

#### Scenario: Light mode feels like paper
- **WHEN** the user opens any main screen in light mode
- **THEN** the background is Warm Sand, not system white/gray

### Requirement: Color accompanies, never dominates
Accent colors SHALL appear only with meaning: Ámbar for archive/review actions, Salvia for positive confirmation, Rojo Apagado for the recording indicator and destructive actions. Large color-saturated surfaces, decorative gradients, and color as the only signal SHALL NOT be used.

#### Scenario: Archive is amber, not orange
- **WHEN** the user swipes to archive a tema or temario
- **THEN** the action renders in Ámbar with its label and icon (never color alone)

#### Scenario: Recording state is muted red
- **WHEN** a practice is recording
- **THEN** the indicator uses Rojo Apagado — serious, not alarming

### Requirement: Accessible contrast preserved
All text-bearing color combinations SHALL satisfy WCAG AA contrast (4.5:1 body, 3:1 large text) in both modes. Dark variants SHALL be lightened specifically so accents stay legible on dark surfaces.

#### Scenario: Ink on sand passes AA
- **WHEN** Deep Ink text or controls render on Warm Sand
- **THEN** the contrast ratio exceeds 4.5:1

### Requirement: No behavioral change
The identity SHALL be purely presentational: no layout, navigation, typography-size, or behavior changes. Dynamic Type and all accessibility affordances SHALL remain intact.

#### Scenario: Everything still works
- **WHEN** the full test suite runs after theming
- **THEN** all tests pass unchanged
