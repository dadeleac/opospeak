# Global Instructions

This skill must be used together with `../README.md`.
The final audit report must be written in Spanish from Spain.
Follow the global rules for:
- evidence;
- confidence;
- severity;
- recommendation quality;
- separation between observed issues and strategic recommendations.
Do not invent missing information.
If evidence is incomplete, clearly state the limitation and mark confidence accordingly.

# Architecture Review Skill

## Purpose

Evaluate the technical architecture, maintainability, scalability, resilience and long-term sustainability of the application.

This review must not focus only on code correctness.

The objective is to determine whether the product architecture:
- supports long-term evolution;
- enables safe iteration;
- minimizes accidental complexity;
- scales operationally and cognitively;
- remains understandable for future contributors;
- preserves product quality over time.

The review should aggressively identify architectural decisions that may:
- create hidden complexity;
- slow future iteration;
- damage reliability;
- increase operational burden;
- introduce technical fragility;
- compromise product evolution.

---

# Expected Context

The review may receive:

- Project structure
- SwiftUI architecture
- Folder organization
- Dependency graph
- Service boundaries
- State management approach
- Persistence layer
- CloudKit usage
- Sync engine
- Networking layer
- Domain models
- Feature modules
- Navigation architecture
- Concurrency model
- Testing strategy
- Build configuration
- CI/CD setup
- Observability strategy
- Error handling
- Offline strategy
- Security model
- Dependency list
- Performance measurements
- Feature descriptions
- ADRs
- OpenSpec documents
- Screenshots where architecture impacts UX

If context is incomplete, explicitly state confidence limitations.

Do not invent implementation details.

---

# Core Review Philosophy

Good architecture is not measured by:
- abstraction count;
- patterns used;
- framework sophistication;
- theoretical purity.

Good architecture is measured by:
- clarity;
- maintainability;
- adaptability;
- operational simplicity;
- resilience;
- product iteration speed;
- cognitive load reduction.

The review must aggressively challenge:
- unnecessary complexity;
- premature abstraction;
- architecture astronautics;
- overengineering;
- excessive indirection;
- accidental complexity.

The architecture should feel:
- intentional;
- understandable;
- evolvable;
- operationally calm.

---

# Core Evaluation Areas

## 1. Architectural Clarity

Evaluate:
- separation of responsibilities;
- feature boundaries;
- domain clarity;
- dependency direction;
- modularity;
- layering consistency;
- architectural readability.

Detect:
- unclear responsibilities;
- god objects;
- feature leakage;
- circular dependencies;
- tightly coupled modules;
- inconsistent architecture patterns;
- hidden side effects.

The architecture should be explainable simply.

---

## 2. State Management & Data Flow

Evaluate:
- predictability of state;
- ownership clarity;
- synchronization safety;
- SwiftUI rendering implications;
- reactive flow consistency;
- async handling.

Review:
- Observable usage;
- environment injection;
- async/await patterns;
- actor isolation;
- thread safety;
- data propagation.

Detect:
- duplicated state;
- hidden mutations;
- race conditions;
- UI-driven business logic;
- inconsistent update flows;
- brittle synchronization.

The state model should feel deterministic.

---

## 3. Offline-First & Sync Resilience

Evaluate:
- local-first behavior;
- synchronization robustness;
- conflict handling;
- retry strategies;
- eventual consistency;
- user trust during failures.

Review:
- CloudKit sync strategy;
- local persistence;
- sync recovery;
- conflict resolution;
- retry policies;
- background sync.

Detect:
- fragile sync assumptions;
- silent data loss risks;
- undefined conflict behavior;
- excessive sync coupling;
- online-only dependencies;
- poor offline UX.

The product should remain trustworthy during failure.

---

## 4. Maintainability & Evolvability

Evaluate:
- ease of iteration;
- onboarding complexity;
- feature isolation;
- testability;
- architectural consistency;
- long-term sustainability.

Detect:
- architecture drift;
- copy-paste patterns;
- brittle abstractions;
- excessive boilerplate;
- hidden dependencies;
- hard-to-change flows.

The codebase should support years of iteration.

---

## 5. Simplicity & Accidental Complexity

Aggressively evaluate whether the architecture is more complex than necessary.

Detect:
- unnecessary patterns;
- premature scalability;
- over-abstraction;
- unnecessary protocols;
- excessive generics;
- over-modularization;
- architecture driven by trends instead of needs.

The review should reward:
- simplicity;
- directness;
- readability;
- explicitness.

Complexity must be justified.

---

## 6. Performance Architecture

Evaluate:
- rendering efficiency;
- memory implications;
- persistence efficiency;
- startup behavior;
- background execution;
- image handling;
- list performance;
- battery implications.

Detect:
- excessive recomposition;
- memory leaks;
- unnecessary allocations;
- blocking operations;
- expensive rendering paths;
- hidden performance bottlenecks.

Performance problems should not emerge from architectural decisions.

---

## 7. Reliability & Resilience

Evaluate:
- failure handling;
- retry behavior;
- graceful degradation;
- edge-case handling;
- recovery flows;
- defensive programming.

Detect:
- crash-prone flows;
- undefined states;
- optimistic assumptions;
- poor recovery behavior;
- inconsistent error handling;
- brittle async orchestration.

The system should fail predictably and safely.

---

## 8. Security & Privacy Architecture

Evaluate:
- local data protection;
- CloudKit exposure;
- secrets handling;
- permission minimization;
- privacy boundaries;
- attack surface.

Detect:
- insecure persistence;
- excessive permissions;
- hidden telemetry risks;
- unsafe storage;
- privacy inconsistencies.

The architecture should reinforce trust.

---

## 9. Testing & Quality Strategy

Evaluate:
- unit testing strategy;
- integration testing;
- UI testing;
- architectural testability;
- mocking strategy;
- snapshot testing;
- regression prevention.

Detect:
- untestable architecture;
- fragile tests;
- excessive mocking complexity;
- missing critical coverage;
- lack of integration confidence.

The architecture should support safe evolution.

---

## 10. Product Scalability

Evaluate whether the architecture can realistically support:
- future features;
- increased complexity;
- additional platforms;
- widgets;
- watch integration;
- premium functionality;
- analytics;
- monetization;
- larger user bases.

Detect:
- architectural dead ends;
- scaling bottlenecks;
- assumptions that will age poorly;
- hardcoded product decisions.

Scalability includes cognitive scalability.

---

# Areas to Challenge Aggressively

The review must aggressively challenge:

- Architecture created “just in case”
- Overuse of patterns
- Excessive dependency injection
- ViewModels without real value
- Generic abstractions with low payoff
- Over-engineered sync systems
- Premature micro-modularity
- Hidden mutable state
- Async complexity without necessity
- Framework-driven architecture
- Excessive protocolization
- Reactive complexity
- Business logic leaking into UI
- Poor feature boundaries
- Architecture that slows iteration
- “Enterprise architecture” patterns without product justification

The review should optimize for:
- product velocity;
- maintainability;
- clarity;
- reliability.

---

# Architectural Maturity Benchmarks

Compare the architecture against:
- high-quality indie iOS apps;
- mature Apple-platform applications;
- long-term maintainable SwiftUI projects;
- resilient local-first products.

Do not compare against:
- enterprise backend architectures;
- overengineered framework-heavy systems;
- architecture designed primarily for resumes.

---

# Scoring

Provide a score from 0-10 for:

| Category | Score |
|---|---|
| Architectural Clarity | /10 |
| Maintainability | /10 |
| Simplicity | /10 |
| State Management Quality | /10 |
| Offline & Sync Resilience | /10 |
| Reliability | /10 |
| Performance Architecture | /10 |
| Security & Privacy | /10 |
| Testability | /10 |
| Long-Term Evolvability | /10 |

Also estimate:

- Technical debt level
- Risk of architecture drift
- Probability of future scalability pain
- Ease of onboarding new contributors
- Confidence level for long-term evolution

---

# Severity Levels

## Critical
Likely to create major reliability, scalability or maintainability problems.

## High
Strongly impacts architecture quality or future evolution.

## Medium
Noticeable structural weakness or unnecessary complexity.

## Low
Minor architectural improvement opportunity.

---

# Output Format

## Executive Summary

High-level assessment of architecture quality and long-term sustainability.

---

## Evidence & Confidence Notes

Briefly describe:
- what evidence was reviewed;
- what evidence was missing;
- confidence level for the review;
- assumptions made.

---

## Overall Scores

Table with all category scores.

---

## Critical Architectural Risks

Most important structural problems.

---

## Complexity Analysis

Areas with unnecessary complexity or overengineering.

---

## Maintainability Risks

Architectural decisions likely to slow future iteration.

---

## Resilience & Reliability Findings

Failure handling and sync robustness analysis.

---

## Performance Risks

Architecture-driven performance concerns.

---

## Security & Privacy Findings

Trust and data protection analysis.

---

## Most Successful Architectural Decisions

Areas where the architecture feels especially strong.

---

## Recommended Simplifications

Patterns, abstractions or systems that should be simplified.

---

## Observed Issues

Findings directly supported by evidence.

---

## Strategic Recommendations

Recommendations or inferences based on the observed evidence.

---

## Recommended Next Iteration

Top improvements with highest impact on long-term product quality.

---

# Review Philosophy

The goal is not architectural sophistication.

The goal is:
- clarity;
- resilience;
- maintainability;
- simplicity;
- trustworthy behavior;
- sustainable product evolution.

A strong architecture should:
- disappear into the background;
- reduce cognitive load;
- enable confident iteration;
- support the product vision for years.