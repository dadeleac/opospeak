## Why

A new user today lands on an empty list with no narrative. `define-onboarding-flow` defines the first-run experience: not a tutorial, but the shortest path to the first practice — create a temario, generate temas, practice. The success metric is explicit: first practice in under two minutes without reading documentation.

## What Changes

- First-launch guided flow presented over the app: one brief welcome screen (what OpoSpeak is, data is private and local) → create first temario (name only, tappable examples) → bulk tema creation ("¿Cuántos temas tiene tu temario?") → land directly in the new temario's tema list, where Practicar is one tap away.
- Skippable at every step: the welcome can be dismissed and the tema step offers "Prefiero añadirlos después"; abandoning persists whatever was created and the existing empty states take over (onboarding continues through them, per the foundation).
- Never shown when data already exists — including data restored via iCloud on a new device (a returning user is not a new user).
- No permission requests (microphone stays in-context at first practice), no account, no sample data, no carousel.

## Capabilities

### New Capabilities

- `onboarding-flow`: first-launch conditions, the three-step guided flow, resumption semantics, and the restored-data exemption.

### Modified Capabilities

<!-- none — tabs, temario/tema management and practice are unchanged; onboarding composes them -->

## Impact

- New: `Views/OnboardingView.swift`, `Logic/OnboardingDecision.swift` (pure show/skip rule).
- Modified: `ContentView.swift` (fullScreenCover wiring + programmatic navigation into the created temario via NavigationPath).
- Tests: OnboardingDecision rule; bulk creation already covered by `TemaBulkCreator` tests.
- No schema changes; one `@AppStorage` flag (`onboardingCompletado`).
