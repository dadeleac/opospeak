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

# TestFlight Readiness Review Skill

## Purpose

Evaluate whether the application is ready for:
- internal testing;
- closed beta;
- public TestFlight distribution;

without damaging:
- product perception;
- user trust;
- retention potential;
- App Store reputation.

This review must analyze not only technical stability, but also:
- polish level;
- onboarding completeness;
- emotional readiness;
- perceived maturity;
- beta-user experience quality.

The objective is to determine whether the product feels:
- intentionally unfinished;
not accidentally broken.

The review should aggressively identify:
- placeholder experiences;
- incomplete flows;
- trust-damaging issues;
- beta-breaking inconsistencies;
- low-polish areas;
- fragile product areas.

A TestFlight build represents the product publicly.
Even beta experiences shape long-term perception.

---

# Expected Context

The review may receive:

- Screenshots
- Screen recordings
- Full app walkthroughs
- Feature descriptions
- Known limitations
- Build notes
- Crash reports
- Architecture summaries
- Analytics setup
- Onboarding flows
- Permission flows
- Subscription flows
- Notifications
- Widgets
- Error states
- Empty states
- App Store assets
- Privacy manifests
- Feature flags
- Beta feedback
- Performance observations
- Accessibility support details
- Product roadmap

If context is incomplete, explicitly state confidence limitations.

Do not invent implementation status.

---

# Core Review Philosophy

A good beta build:
- builds trust;
- communicates direction;
- feels coherent;
- preserves emotional quality;
- avoids embarrassing instability.

The goal is not:
- feature completeness.

The goal is:
- confidence;
- clarity;
- polish in critical flows;
- meaningful feedback collection;
- trustworthy early experience.

A TestFlight build should feel:
- carefully selected;
not prematurely exposed.

---

# Core Evaluation Areas

## 1. Core Product Stability

Evaluate:
- crash risk;
- incomplete flows;
- broken states;
- navigation reliability;
- sync robustness;
- persistence safety.

Detect:
- unstable features;
- crash-prone flows;
- undefined states;
- navigation dead ends;
- data-loss risks;
- inconsistent persistence behavior.

Users should feel:
- safe exploring the product.

---

## 2. Product Completeness Perception

Evaluate whether the application feels:
- intentionally minimal;
or
- unfinished.

Detect:
- placeholder content;
- missing states;
- broken hierarchy;
- “coming soon” overload;
- empty areas without explanation;
- inconsistent polish.

Minimalism must not feel like incompleteness.

---

## 3. Onboarding Readiness

Evaluate:
- onboarding clarity;
- setup smoothness;
- permission timing;
- emotional confidence;
- first-session quality.

Detect:
- onboarding confusion;
- unfinished onboarding flows;
- unexplained permissions;
- weak first impression;
- tutorial fatigue.

Beta users still form permanent impressions.

---

## 4. UX & Visual Polish

Evaluate:
- spacing consistency;
- typography quality;
- animation quality;
- responsiveness;
- visual coherence;
- premium feel.

Detect:
- layout glitches;
- inconsistent spacing;
- unfinished animations;
- visual roughness;
- obvious temporary UI.

The product should still feel crafted.

---

## 5. Error States & Recovery

Evaluate:
- network failure handling;
- sync recovery;
- offline behavior;
- empty states;
- retry flows.

Detect:
- silent failures;
- cryptic errors;
- dead-end flows;
- missing recovery guidance;
- emotionally harsh failure states.

Users should never feel:
- abandoned by the app.

---

## 6. Accessibility & Inclusiveness

Evaluate:
- Dynamic Type support;
- VoiceOver support;
- touch targets;
- readability;
- accessibility consistency.

Detect:
- inaccessible critical flows;
- broken accessibility support;
- accessibility regressions;
- inaccessible onboarding.

Accessibility problems damage trust early.

---

## 7. Performance & Fluidity

Evaluate:
- responsiveness;
- startup speed;
- animation smoothness;
- memory stability;
- scrolling quality.

Detect:
- laggy transitions;
- visible stutter;
- heavy startup;
- battery-draining behavior;
- obvious instability.

Performance strongly affects perceived maturity.

---

## 8. Beta Feedback Readiness

Evaluate whether the build is prepared to:
- collect useful feedback;
- support iteration;
- avoid noisy low-value reports.

Review:
- feedback channels;
- feature clarity;
- known limitations communication;
- release notes quality.

Detect:
- unclear beta expectations;
- feedback confusion;
- hidden limitations;
- poor beta framing.

A beta should guide feedback intentionally.

---

## 9. Trust & Product Reputation Risk

Evaluate whether releasing the current build could:
- damage trust;
- reduce future conversion;
- create poor first impressions;
- generate avoidable negative perception.

Detect:
- low-quality flows;
- emotionally incoherent experiences;
- unstable core interactions;
- unfinished premium positioning.

First impressions are difficult to reverse.

---

## 10. TestFlight Scope Appropriateness

Evaluate whether the current build is suitable for:
- internal-only testing;
- trusted testers;
- public beta.

Detect:
- features not ready for public exposure;
- emotionally fragile areas;
- stability concerns;
- premature audience expansion.

Not every build should become public.

---

# Areas to Challenge Aggressively

The review must aggressively challenge:

- “Coming soon” placeholders
- Fake polish hiding instability
- Broken empty states
- Weak onboarding
- Unstable sync behavior
- Incomplete monetization flows
- Poor recovery UX
- Visual inconsistencies
- Temporary UI exposed publicly
- Debug remnants
- Emotionally unfinished experiences
- Overly ambitious beta scope
- Feature creep before stability
- Premature public exposure

The review should optimize for:
- trust;
- polish;
- coherence;
- confidence.

---

# TestFlight Philosophy

The goal is not:
- maximum feature exposure;
- rushing public access.

The goal is:
- meaningful validation;
- emotionally coherent testing;
- high-quality feedback;
- trust preservation.

A beta should feel:
- intentionally curated;
not accidentally released.

---

# Benchmarks

Compare against:
- polished indie TestFlight programs;
- mature iOS beta experiences;
- carefully staged product launches.

Do not compare against:
- chaotic early prototypes;
- internal engineering builds;
- feature-dump betas.

---

# Scoring

Provide a score from 0-10 for:

| Category | Score |
|---|---|
| Stability | /10 |
| Product Completeness Perception | /10 |
| Onboarding Readiness | /10 |
| UX & Visual Polish | /10 |
| Error Recovery Quality | /10 |
| Accessibility Readiness | /10 |
| Performance & Fluidity | /10 |
| Feedback Readiness | /10 |
| Trust & Reputation Safety | /10 |
| Public Beta Readiness | /10 |

Also estimate:

- Readiness for internal testing
- Readiness for trusted external testers
- Readiness for public TestFlight
- Risk of negative first impression
- Risk of trust erosion
- Confidence level for beta exposure

---

# Severity Levels

## Critical
Strongly risks crashes, trust damage or major negative perception.

## High
Noticeably harms beta quality or product confidence.

## Medium
Moderate polish or readiness weakness.

## Low
Minor TestFlight improvement opportunity.

---

# Output Format

## Executive Summary

High-level assessment of TestFlight readiness and beta quality.

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

## Critical Release Risks

Major blockers before broader beta exposure.

---

## Stability Findings

Crash, sync and reliability assessment.

---

## Product Polish Findings

Visual and UX maturity analysis.

---

## Onboarding & First Impression Findings

Assessment of beta-user first experience.

---

## Trust & Reputation Risks

Areas likely to damage long-term perception.

---

## Public Beta Suitability

Recommendation for:
- internal testing;
- closed beta;
- public beta.

---

## Most Beta-Ready Areas

Strongest and most mature parts of the experience.

---

## Recommended Stabilization Priorities

Highest-impact fixes before broader exposure.

---

## Observed Issues

Findings directly supported by evidence.

---

## Strategic Recommendations

Recommendations or inferences based on the observed evidence.

---

## Recommended Next Iteration

Top improvements required before advancing beta scope.

---

# Review Philosophy

The goal is not to release quickly.

The goal is to release:
- intentionally;
- confidently;
- respectfully;
- coherently.

A TestFlight build should make users think:
- “this already feels promising”
not
- “this is unfinished and unstable.”