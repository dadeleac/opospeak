## Why

The app ships every MVP feature with default system styling; the visual identity is fully specified in `define-color-system-and-visual-identity.md` (Deep Ink + Warm Sand, study-notebook aesthetic, editorial over dashboard) and deliberately deferred until the structure stabilized. This is the last MVP change: the product should *feel* like a premium training notebook, not a template.

## What Changes

- Semantic color system in the asset catalog with light and dark variants: Tinta (Deep Ink #1F3A5F), Pizarra (Slate #5F6B7A), Arena (Warm Sand #E8E1D8) plus a raised-surface variant, Salvia (Sage #6E8F7A), Ámbar (#C98A3D) and Rojo Apagado (#B55C5C).
- `Theme.swift` exposing the semantic tokens and an editorial background modifier for list screens.
- Application across all screens, with restraint (color accompanies, never dominates):
  - Deep Ink as the global tint (replacing the default blue AccentColor).
  - Warm Sand as the screen background in light mode; ink-tinted near-black in dark mode (nocturnal reading).
  - Ámbar for archive actions (replacing system orange), Salvia for positive confirmation (recording saved), Rojo Apagado for recording state and destructive accents (replacing system red).
- Dark mode variants tuned for contrast (lightened ink/sage/amber on dark surfaces); WCAG AA contrast preserved for text-bearing combinations.
- No layout, navigation, or behavior changes; typography stays system (Dynamic Type untouched).

## Capabilities

### New Capabilities

- `visual-identity`: the semantic color system, its light/dark variants, where each color may appear, and the restraint rules.

### Modified Capabilities

<!-- none — purely presentational; no requirement-level behavior changes -->

## Impact

- `Assets.xcassets`: 7 new colorsets (light + dark each); `AccentColor` updated to Deep Ink.
- New: `Views/Theme.swift`.
- Touched (styling only): ContentView, TemariosListView, TemarioDetailView, TemaDetailView, IntentoDetailView, ProgresoView, AjustesView, PracticeView, OnboardingView.
- Tests: every semantic color resolves from the catalog (guards against colorset/name drift).
