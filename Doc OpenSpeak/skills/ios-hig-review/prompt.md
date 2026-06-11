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

# iOS Human Interface Guidelines Review Skill

## Purpose

Evaluate whether the application delivers a native, polished, accessible and emotionally coherent iOS experience aligned with Apple Human Interface Guidelines (HIG).

This review must not focus only on visual correctness.
It must also evaluate:
- platform authenticity;
- interaction quality;
- emotional perception;
- clarity;
- consistency;
- accessibility;
- premium feel.

The objective is to determine whether the product feels like a high-quality iOS application designed specifically for the Apple ecosystem instead of a generic cross-platform interface.

---

# Expected Context

The review may receive:

- Screenshots
- Screen recordings
- SwiftUI views
- Navigation structure
- Component hierarchy
- Design system
- Animations
- Onboarding flows
- Empty states
- Permission flows
- Settings screens
- Widget designs
- Lock screen/live activities
- Haptic descriptions
- Accessibility settings support
- Dark mode screenshots
- Dynamic Type screenshots
- App architecture summaries
- TestFlight builds
- Feature descriptions

If context is incomplete, explicitly state confidence limitations instead of inventing assumptions.

---

# Core Evaluation Areas

## 1. Native iOS Feel

Evaluate whether the app behaves like a real iOS application.

Review:
- navigation patterns;
- tab structure;
- sheets;
- modal presentation;
- gestures;
- transitions;
- spacing;
- typography;
- safe areas;
- scrolling behavior;
- inline actions;
- swipe interactions;
- contextual menus;
- keyboard behavior.

Detect:
- Android-like patterns;
- web-like layouts;
- non-native navigation;
- excessive custom UI;
- interaction friction;
- platform inconsistencies.

---

## 2. Visual Hierarchy & Clarity

Evaluate:
- readability;
- hierarchy;
- spacing consistency;
- typography scaling;
- information density;
- breathing room;
- cognitive load;
- visual rhythm.

Detect:
- overloaded screens;
- unclear CTA hierarchy;
- excessive decoration;
- poor alignment;
- inconsistent spacing;
- typography misuse;
- insufficient contrast;
- visual imbalance.

---

## 3. Apple HIG Compliance

Evaluate alignment with Apple recommendations regarding:

- navigation;
- controls;
- layout;
- typography;
- motion;
- feedback;
- accessibility;
- onboarding;
- permissions;
- alerts;
- gestures;
- color usage;
- SF Symbols usage;
- touch targets;
- platform conventions.

Identify:
- direct HIG violations;
- risky UX patterns;
- misleading interactions;
- anti-patterns;
- unnecessary friction.

---

## 4. Accessibility (WCAG + Apple Accessibility)

Evaluate:
- Dynamic Type support;
- VoiceOver compatibility;
- contrast ratios;
- touch target sizes;
- Reduce Motion compatibility;
- color dependency;
- semantic labeling;
- focus order;
- readability;
- accessibility affordances.

Detect:
- inaccessible interactions;
- low contrast;
- tiny touch areas;
- hidden context;
- unsupported scaling;
- poor screen reader support.

---

## 5. Emotional & Premium Experience

Evaluate whether the application feels:
- calm;
- intentional;
- trustworthy;
- premium;
- focused;
- emotionally coherent.

Review:
- animation restraint;
- pacing;
- transitions;
- content density;
- tone;
- visual softness;
- friction;
- perceived quality.

Detect:
- aggressive UX;
- gamification pressure;
- dopamine-driven mechanics;
- rushed flows;
- visually noisy interfaces;
- emotionally incoherent screens;
- cheap-feeling patterns.

The app should feel crafted, not assembled.

---

## 6. Onboarding & First Impression

Evaluate:
- clarity of value proposition;
- emotional connection;
- onboarding friction;
- permission timing;
- first-session experience;
- cognitive overload;
- initial trust perception.

Detect:
- overwhelming onboarding;
- permission abuse;
- unclear product value;
- premature monetization;
- excessive explanations;
- poor first-use experience.

---

## 7. Motion & Interaction Quality

Evaluate:
- animation timing;
- responsiveness;
- continuity;
- tactile feeling;
- gesture coherence;
- transition smoothness.

Detect:
- excessive animations;
- laggy transitions;
- abrupt state changes;
- animation inconsistency;
- fake physics;
- unnecessary motion.

Motion should support clarity, not decoration.

---

## 8. Consistency

Evaluate consistency across:
- spacing;
- typography;
- button styles;
- card styles;
- iconography;
- shadows;
- corner radius;
- navigation behavior;
- interaction rules;
- language tone.

Detect:
- fragmented visual identity;
- multiple design languages;
- inconsistent interaction patterns;
- feature-by-feature design drift.

---

# Specific Areas to Challenge Aggressively

The review must aggressively identify:

- Screens trying to do too much
- Features hurting simplicity
- UI elements competing for attention
- Unnecessary settings
- “Productivity app” feeling instead of wellbeing experience
- Generic SaaS patterns
- Dashboard syndrome
- Visual clutter
- Overuse of cards
- Overuse of gradients
- Excessive metrics
- Psychological pressure mechanics
- Android/web mental models leaking into iOS
- Features damaging premium perception
- Inconsistency between emotional positioning and actual UX

---

# Scoring

Provide a score from 0-10 for each category:

| Category | Score |
|---|---|
| Native iOS Feel | /10 |
| HIG Compliance | /10 |
| Accessibility | /10 |
| Visual Polish | /10 |
| Emotional Coherence | /10 |
| Premium Feel | /10 |
| Navigation Quality | /10 |
| Interaction Quality | /10 |
| Onboarding Quality | /10 |
| Overall Product Maturity | /10 |

Also provide:

- Estimated readiness for public TestFlight
- Estimated readiness for App Store launch
- Estimated perceived product quality compared to top-tier iOS indie apps

---

# Severity Levels

Classify findings as:

## Critical
Likely to severely damage usability, accessibility, trust or App Store perception.

## High
Strongly impacts experience quality or platform consistency.

## Medium
Noticeable quality or coherence issues.

## Low
Minor polish opportunities.

---

# Output Format

## Executive Summary

Short high-level assessment of the current product quality.

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

## Critical Issues

Most important issues requiring immediate attention.

---

## High Priority Improvements

Important improvements with high UX impact.

---

## HIG Violations

Explicit Apple HIG deviations.

---

## Accessibility Findings

Accessibility-specific problems.

---

## Premium Experience Gaps

Areas where the product feels less premium or emotionally coherent.

---

## Product Identity Risks

Features or design decisions that may dilute the product vision.

---

## Most Successful Areas

What currently feels strongest and most differentiated.

---

## Observed Issues

Findings directly supported by evidence.

---

## Strategic Recommendations

Recommendations or inferences based on the observed evidence.

---

## Recommended Next Iteration

Top 5 improvements that would most increase perceived quality.

---

# Review Philosophy

The goal is not only to validate correctness.

The goal is to determine whether the application feels:
- intentional;
- calm;
- deeply native;
- emotionally coherent;
- trustworthy;
- premium;
- worthy of long-term retention.

The review should optimize for long-term product quality, not feature quantity.