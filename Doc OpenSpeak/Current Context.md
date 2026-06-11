
This document is the living handoff for OpoSpeak.

It should allow a new conversation to understand the current state of the product without reading previous discussions.

## Product State

OpoSpeak is an Apple-first application for long-term oral exam preparation.

The product is designed for competitive examinations that require oral exposition or topic recitation.

Examples include:

- Judiciary
- Public Prosecutors
- Court Clerks
- Notaries
- Property Registrars
- Tax Inspectors
- Diplomats

OpoSpeak is not an academy, a legal platform, a test application, or an AI tutor.

It is a practice and progress tracking tool for oral preparation.

---

## Core Thesis

The problem is not recording a topic.

The problem is managing years of oral practice.

OpoSpeak exists to organize, preserve, and visualize that practice history.

---

## Current Product Direction

The current strategy is based on:

- Apple-first
- Local-first
- Privacy-first
- No proprietary backend
- iCloud continuity
- Offline operation
- Open export
- Long-term progress tracking

The application should feel closer to a premium training notebook than to an educational platform.

---

## Foundation Documents

The following documents define the stable foundations of the product:

- product-foundation
- core-domain-model
- local-first-data-strategy
- privacy-and-export-strategy
- mvp-scope
- color-system-and-visual-identity
- apple-human-interface-guidelines-compliance
- wcag-accessibility-compliance

These documents should evolve rarely and only through deliberate decisions.

---

## Current MVP Scope

The MVP focuses on:

- Temarios
- Temas
- Oral practice
- Audio recording
- Attempts
- History
- Notes
- Basic progress indicators
- Export
- iCloud continuity

The MVP explicitly excludes:

- AI
- Transcription
- Voice analysis
- Trainer collaboration
- Community features
- Gamification

---

## Current Design Direction

The product should communicate:

- concentration
- discipline
- progress
- calm confidence

The visual identity is based on:

- Deep Ink
- Warm Sand
- Editorial aesthetics
- Native Apple patterns

The product should not resemble:

- a legal application
- a dashboard
- a SaaS platform
- a productivity tool

---

## Current Technical Direction

Preferred stack:

- SwiftUI
- SwiftData
- CloudKit
- Native Apple frameworks

Architecture principles:

- Simplicity over abstraction
- Native solutions over custom frameworks
- Local-first data ownership
- Open export formats

---

## Recently Resolved

- Information architecture defined in `define-information-architecture` (three tabs: Temarios, Progreso, Ajustes; Practicar always launches from a Tema; Sesión stays invisible; one Tema per Intento in the MVP).
- Onboarding flow defined in `define-onboarding-flow` (no tutorial carousel, no mandatory account, permissions requested in context; goal is first practice in under two minutes).
- Export and backup package structure defined in `define-export-format` (open JSON as source of truth, CSV convenience view, untouched m4a recordings, importable manifest-versioned package).

---

## Known Open Questions

The following decisions remain open:

- Import strategy (beyond reimporting an OpoSpeak package)
- Premium model details
- Future trainer workflows
- Future AI boundaries
- Multi-topic extraction (intermediate entity), deferred until after MVP validation
- Whether recording metadata ships inside `intentos.json` or a separate `grabaciones.json`

---

## Collaboration Rules

Use OpenSpec for significant product, domain, architecture, navigation, data, privacy, or monetization changes.

Prefer small and deliberate decisions.

Challenge scope creep.

Protect the product thesis.

Do not introduce features that move OpoSpeak toward becoming:

- an academy
- a legal platform
- a social network
- an AI tutor

without an explicit strategic decision.

---

## Update Policy

Update this document whenever any of the following changes:

- product vision
- MVP scope
- privacy model
- storage strategy
- synchronization strategy
- monetization strategy
- design direction
- foundation documents
- technical direction

Keep this document concise.

Link to foundation and OpenSpec documents instead of duplicating them.