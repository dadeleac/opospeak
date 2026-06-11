## Context

`define-onboarding-flow` is explicit: the onboarding is "casi invisible" — the user believes they simply started using the app, when they've already built their study structure. All building blocks exist (temario creation, `TemaBulkCreator`, empty states, in-context mic permission); this change composes them into a first-run path and decides when to show it. One subtlety matters since the iCloud change: a new device with restored data must not onboard.

## Goals / Non-Goals

**Goals:**

- Three-phase guided flow (bienvenida → temario → temas) over the Temarios tab.
- Pure, tested show/skip decision including the restored-data exemption.
- Landing inside the created temario (programmatic navigation).
- Every step skippable; abandoned work persists.

**Non-Goals:**

- No tutorial overlays, tooltips, or coach marks (empty states are the continuous onboarding).
- No import path in onboarding (import is a future change).
- No analytics/funnel events (no telemetry exists in the app).

## Decisions

### 1. `OnboardingDecision.debeMostrarse(completado:tieneTemarios:)` as pure logic

Returns show / skip-and-mark. The restored-data case (has temarios, never completed) returns skip-and-mark so the flag is set and the check never runs again. Rationale: the only bug-prone part of onboarding is *when* it appears; making it a pure function makes the four combinations trivially testable.

### 2. One `OnboardingView` with internal phases, presented as `fullScreenCover`

Phases: `bienvenida → nombreTemario → temas`. State lives in the view (`@State fase`, `nombre`, `cantidad`); persistence happens at phase transitions (temario inserted when leaving phase 2, temas when finishing phase 3) so abandonment keeps completed steps — matching the foundation's resumption rule. Interactive dismissal stays enabled (the welcome "no bloquea"); `onDisappear` marks the flag regardless of how the cover closes.

### 3. Completion lands inside the temario via `NavigationPath`

`ContentView` owns the Temarios tab's `NavigationPath` and passes it into the existing `NavigationStack`; onboarding's completion handler appends the created temario. Rationale: the foundation specifies landing on the tema list ("el usuario llega a la lista de temas"), and path-based navigation is the pattern the codebase already uses (`navigationDestination(for: Temario.self)` exists).

### 4. `@AppStorage("onboardingCompletado")` as the only persistence

A UserDefaults flag, not a model: onboarding state is device-local UX, not user data — it must NOT sync via CloudKit (each new device evaluates the restored-data rule itself). This is precisely why the flag is not a SwiftData entity.

### 5. Bulk step bounded by the existing validator

The count input uses a stepper plus quick-pick values, clamped to `TemaBulkCreator`'s 1...1000; creation goes through `plan(existingNumbers:desde:hasta:)` like the alta rápida sheet. No new creation code path — one validator, one behavior.

## Risks / Trade-offs

- [iCloud restore may complete *after* first launch checks] → The rule requires both "never completed" AND "no temarios": a fresh-install user who also has cloud data might see onboarding before sync finishes. Accepted: worst case they create a temario that coexists with synced ones; no data loss. Detecting in-flight sync reliably is not worth the complexity.
- [Programmatic navigation right after insert] → The temario is saved before appending to the path; SwiftData `@Query` updates synchronously on main-context inserts.
- [User dismisses mid-typing] → Phase transitions persist completed steps only; a half-typed name is intentionally discarded.

## Migration Plan

1. `OnboardingDecision` + tests → `OnboardingView` → `ContentView` wiring. Build at each step.

Rollback: revert; the flag in UserDefaults is inert without the check.

## Open Questions

- None blocking.
