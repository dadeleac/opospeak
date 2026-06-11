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

# Production Readiness Review Skill

## Purpose

Evaluate whether the application is truly ready for public production release as a sustainable, trustworthy and high-quality product.

This review must go beyond:
- feature completeness;
- beta readiness;
- visual polish.

The objective is to determine whether the product is ready to:
- operate reliably at scale;
- preserve user trust long-term;
- support real users safely;
- sustain retention and monetization;
- evolve without collapsing under technical or product debt.

This review should aggressively identify:
- hidden production risks;
- operational fragility;
- scalability limitations;
- trust-damaging weaknesses;
- unfinished systems;
- emotional incoherence;
- unsustainable product decisions.

Production readiness means:
- the product can responsibly become part of someone's life.

---

# Expected Context

The review may receive:

- Full app walkthroughs
- Architecture summaries
- OpenSpec documentation
- Audit reports
- Crash analytics
- Performance measurements
- Sync architecture
- Persistence strategy
- Accessibility support
- Monetization flows
- Notification strategy
- Privacy manifests
- Terms/privacy documents
- App Store assets
- Onboarding flows
- Recovery flows
- Error handling
- Security architecture
- CI/CD setup
- Testing strategy
- Analytics implementation
- Feature roadmap
- Known limitations
- TestFlight feedback
- Widget architecture
- Background tasks
- Subscription setup
- Release notes
- Observability setup

If context is incomplete, explicitly state confidence limitations.

Do not invent operational maturity.

---

# Core Review Philosophy

Production readiness is not:
- “it works on my device”;
- feature quantity;
- visual polish alone.

Production readiness means:
- operational reliability;
- emotional trustworthiness;
- sustainable maintainability;
- resilient behavior;
- coherent user experience;
- responsible product stewardship.

A production product should feel:
- dependable;
- calm;
- intentional;
- mature.

The review must optimize for:
- long-term sustainability;
not launch excitement.

---

# Core Evaluation Areas

## 1. Product Stability & Reliability

Evaluate:
- crash resilience;
- sync robustness;
- persistence safety;
- offline behavior;
- recovery quality;
- edge-case handling.

Detect:
- crash-prone flows;
- undefined states;
- silent failures;
- data-loss risks;
- fragile synchronization;
- unstable background behavior.

Users must trust the application with real-life usage.

---

## 2. Production UX Maturity

Evaluate whether the experience feels:
- complete;
- emotionally coherent;
- polished;
- stable;
- intentionally designed.

Detect:
- unfinished flows;
- UX inconsistencies;
- emotionally fragmented experiences;
- temporary-feeling interactions;
- feature creep.

A production app should feel:
- internally coherent.

---

## 3. Long-Term Maintainability

Evaluate:
- architecture sustainability;
- technical debt;
- scalability;
- feature isolation;
- operational simplicity;
- future iteration safety.

Detect:
- architectural fragility;
- hidden complexity;
- scaling bottlenecks;
- unsustainable product growth;
- difficult-to-maintain areas.

The product should support years of evolution.

---

## 4. Performance & Resource Sustainability

Evaluate:
- startup performance;
- memory stability;
- battery impact;
- long-session stability;
- scalability over time.

Detect:
- battery-hostile behavior;
- memory growth;
- long-term degradation;
- sync-heavy architectures;
- performance instability.

Production products must remain stable over long-term usage.

---

## 5. Accessibility & Inclusiveness

Evaluate:
- accessibility maturity;
- Dynamic Type support;
- VoiceOver quality;
- motion accessibility;
- cognitive accessibility;
- accessibility consistency.

Detect:
- inaccessible core flows;
- fragile accessibility support;
- accessibility regressions;
- exclusionary patterns.

Accessibility quality impacts public trust and reputation.

---

## 6. Security & Privacy Readiness

Evaluate:
- data protection;
- local storage safety;
- CloudKit exposure;
- permission minimization;
- transparency;
- privacy consistency.

Detect:
- privacy ambiguities;
- insecure persistence;
- unnecessary permissions;
- hidden tracking risks;
- unclear data ownership.

Trust is part of production readiness.

---

## 7. Monetization Sustainability

Evaluate whether monetization:
- feels fair;
- preserves trust;
- supports sustainability;
- aligns emotionally with the product.

Detect:
- manipulative monetization;
- premature paywalls;
- retention-destructive upsells;
- emotionally incoherent pricing.

Revenue should reinforce:
- trust;
not extraction.

---

## 8. Operational Readiness

Evaluate:
- crash monitoring;
- analytics maturity;
- logging strategy;
- release process;
- rollback capability;
- feature flagging;
- observability.

Detect:
- lack of production visibility;
- inability to diagnose failures;
- missing operational safeguards;
- release fragility.

A production product requires operational awareness.

---

## 9. App Store Readiness

Evaluate:
- screenshots;
- metadata quality;
- onboarding consistency;
- subscription transparency;
- review readiness;
- perceived quality.

Detect:
- weak App Store positioning;
- misleading screenshots;
- incomplete product framing;
- premium mismatch.

The App Store experience shapes trust before installation.

---

## 10. Long-Term Product Sustainability

Evaluate whether the product can realistically support:
- long-term retention;
- healthy monetization;
- maintainable iteration;
- emotional consistency;
- product identity preservation.

Detect:
- roadmap unsustainability;
- feature accumulation risk;
- emotional dilution;
- operational burnout risk.

A sustainable product must remain:
- coherent;
- maintainable;
- emotionally stable.

---

# Areas to Challenge Aggressively

The review must aggressively challenge:

- Launching too early
- Feature creep before stability
- Fragile sync systems
- Missing observability
- Weak recovery UX
- Emotional incoherence
- Battery-hostile behavior
- Poor scalability assumptions
- Accessibility gaps
- Privacy ambiguity
- Monetization harming trust
- Operational blind spots
- “Looks polished but structurally fragile” products
- Excessive dependence on manual fixes
- Unsustainable product scope

The review should optimize for:
- trust;
- sustainability;
- operational calmness;
- long-term quality.

---

# Production Philosophy

The goal is not:
- shipping fast;
- maximizing launch hype;
- releasing every feature.

The goal is:
- sustainable trust;
- reliable experience;
- emotionally coherent product quality;
- long-term product health.

Production release means:
- users may integrate this product into their daily lives.

That responsibility matters.

---

# Benchmarks

Compare against:
- mature premium indie apps;
- trustworthy long-term iOS products;
- operationally reliable applications;
- emotionally coherent digital products.

Do not compare against:
- growth-hacked launch products;
- unstable trend-driven apps;
- MVP-only products;
- feature-first applications.

---

# Scoring

Provide a score from 0-10 for:

| Category | Score |
|---|---|
| Stability & Reliability | /10 |
| UX Maturity | /10 |
| Maintainability | /10 |
| Performance Sustainability | /10 |
| Accessibility Readiness | /10 |
| Security & Privacy | /10 |
| Monetization Sustainability | /10 |
| Operational Readiness | /10 |
| App Store Readiness | /10 |
| Long-Term Product Sustainability | /10 |

Also estimate:

- Readiness for public App Store release
- Risk of trust erosion
- Risk of operational instability
- Risk of retention degradation
- Risk of product burnout
- Confidence level for long-term sustainability

---

# Severity Levels

## Critical
Strongly risks trust, stability, operational sustainability or public reputation.

## High
Noticeably harms production quality or long-term sustainability.

## Medium
Moderate production weakness or maturity gap.

## Low
Minor production refinement opportunity.

---

# Output Format

## Executive Summary

High-level assessment of production readiness and sustainability.

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

## Critical Production Risks

Major blockers before public release.

---

## Reliability & Stability Findings

Crash resilience, sync robustness and recovery analysis.

---

## Product & UX Maturity Findings

Assessment of product coherence and polish.

---

## Operational Readiness Findings

Monitoring, release management and observability analysis.

---

## Security & Privacy Findings

Trust and data-protection assessment.

---

## Long-Term Sustainability Risks

Areas likely to create future operational or product instability.

---

## Most Production-Ready Areas

Strongest and most mature parts of the product.

---

## Recommended Stabilization Priorities

Highest-impact improvements before public launch.

---

## Observed Issues

Findings directly supported by evidence.

---

## Strategic Recommendations

Recommendations or inferences based on the observed evidence.

---

## Recommended Next Iteration

Top improvements required before production release.

---

# Review Philosophy

The goal is not simply to launch.

The goal is to create a product that feels:
- trustworthy;
- resilient;
- sustainable;
- calm;
- emotionally coherent;
- worthy of long-term adoption.

A production-ready product should feel:
- intentionally reliable;
not merely functional.