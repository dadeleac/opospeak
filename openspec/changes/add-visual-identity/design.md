## Context

`define-color-system-and-visual-identity.md` fixes the palette and its emotional intent: study notebook, quality writing, deep reading — not legal apps or dashboards. All screens exist and are accessibility-clean (text styles only, labels everywhere), so theming is a leaf change. The asset catalog has only the default AccentColor.

## Goals / Non-Goals

**Goals:**

- Seven semantic colorsets with tuned dark variants; AccentColor → Deep Ink.
- `Theme.swift` tokens + one editorial background modifier.
- Restrained application across every screen; AA contrast in both modes.
- A resolution test guarding against colorset/name drift.

**Non-Goals:**

- No custom typography (serif/display exploration is a future, deliberate decision — Dynamic Type stays untouched).
- No app icon work (separate asset/design task).
- No custom components; native controls, recolored.
- No per-screen bespoke styling beyond the token rules.

## Decisions

### 1. Asset catalog colorsets, not code-defined colors

Colorsets give free light/dark resolution, high-contrast variants later, and one editable source of truth. `Theme.swift` exposes them as `Color.tinta`, `.arena`, etc. — views never see hex. Spanish token names continue the ubiquitous-language rule.

### 2. Dark variants are lightened, not inverted

Deep Ink #1F3A5F is illegible as an accent on dark surfaces; its dark variant is a lightened ink (#9CB4D6 family). Same treatment for Salvia, Ámbar, Rojo Apagado, Pizarra. The background inverts to an ink-tinted near-black (#171B22) with a raised variant (#222834) — "nocturnal reading", not pure black. Rationale: the foundation defines dark mode by feeling (concentration, professional tools), which means tinted darks, and WCAG requires the lightening.

**Amendment (validated visually):** the screen background in light mode is **Papel #F8F7F4**, not Arena. Warm Sand read too warm as a full-screen base; Papel keeps the clean-page feel and Arena returns to its foundation role — warm highlighted surfaces (blocks, cards) over the background. Both tokens ship; dark mode is identical for both.

### 3. Editorial background via a single modifier

`.fondoEditorial()` = `scrollContentBackground(.hidden)` + `background(Color.arena)`, applied to each List screen. Rationale: SwiftUI has no global list-background API worth using (UIAppearance hacks leak); an explicit one-line modifier per screen is honest and greppable.

### 4. Replace semantic uses, not sprinkle color

Three substitutions carry the identity: global tint (Tinta via AccentColor + explicit `.tint` where needed), archive swipes (.orange → .ambar), recording/destructive (.red → .rojoApagado), plus Salvia for the saved-recording confirmation. Everything else inherits. Rationale: the foundation's strongest rule is restraint — "color accompanies, doesn't dominate".

### 5. AccentColor asset updated in place

Updating the existing AccentColor asset themes every control that follows the app tint with zero code. Explicit `.tint(.tinta)` only where a view overrode color before.

### 6. Resolution test

A unit test resolves each named color via `UIColor(named:)` from the app bundle. Cheap, and catches the classic failure (renamed colorset, typo in token) at test time instead of silently rendering system defaults.

Contrast verification (computed, documented here): Deep Ink on Arena ≈ 8.9:1 (AA/AAA ✓); lightened ink on near-black ≈ 8.1:1 ✓; Pizarra on Arena ≈ 4.6:1 (AA ✓); Rojo Apagado/Ámbar appear only on icons+labels pairs, never as sole text color below large size.

## Risks / Trade-offs

- [Sand background can clash with sheets/forms that keep system grouping] → Sheets (creation forms) intentionally keep system backgrounds — they are transient tools, not notebook pages; only persistent screens get Arena. Documented rule.
- [Hardcoded hex in colorsets vs foundation doc drift] → Values copied verbatim from the foundation; the doc is the source of truth and cites the same hex.
- [Dark variants are my derivation, not in the foundation] → The foundation defines dark mode by intent only; derivations documented here for review, trivially adjustable in the colorsets.

## Migration Plan

1. Colorsets + Theme + test → apply per screen → suite. Pure styling; rollback is reverting commits.

## Open Questions

- None blocking. Typography exploration (editorial serif accents) deliberately left as a future decision.
