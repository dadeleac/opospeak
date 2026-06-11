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

# WCAG & Apple Accessibility Review Skill

## Purpose

Evaluate whether the application is accessible, inclusive and usable for people with diverse abilities, contexts and interaction needs.

This review must not focus only on formal WCAG compliance.

The objective is to determine whether the application:
- respects accessibility principles;
- supports Apple accessibility technologies;
- minimizes exclusion;
- preserves usability under accessibility settings;
- maintains dignity and emotional quality for all users.

Accessibility must be treated as:
- product quality;
not optional compliance.

The review should aggressively identify:
- exclusionary patterns;
- inaccessible interactions;
- hidden barriers;
- cognitive overload;
- visual dependency;
- motion issues;
- inaccessible custom UI.

---

# Expected Context

The review may receive:

- Screenshots
- Screen recordings
- SwiftUI code
- Accessibility labels
- Accessibility modifiers
- VoiceOver recordings
- Dynamic Type screenshots
- Reduce Motion behavior
- Navigation flows
- Forms
- Settings screens
- Color palette
- Typography system
- Gesture interactions
- Charts or visualizations
- Widgets
- Notifications
- Error states
- Empty states
- Animation descriptions
- App architecture summaries
- TestFlight builds

If context is incomplete, explicitly state confidence limitations.

Do not invent accessibility support.

---

# Core Review Philosophy

Accessibility is not:
- a checklist;
- a legal formality;
- a secondary feature.

Accessibility is:
- usability;
- inclusion;
- respect;
- clarity;
- product maturity.

A premium app should remain:
- understandable;
- operable;
- calm;
- trustworthy;

for as many users as possible.

Accessibility improvements often improve the experience for everyone.

---

# Standards & Platforms

Evaluate alignment with:

- WCAG 2.2 principles
- Apple Human Interface Guidelines
- Apple Accessibility APIs
- Dynamic Type best practices
- VoiceOver best practices
- iOS interaction accessibility conventions

Focus especially on:
- real-world usability;
not theoretical compliance only.

---

# Core Evaluation Areas

## 1. Dynamic Type Support

Evaluate:
- text scalability;
- layout resilience;
- truncation behavior;
- adaptive spacing;
- readability under large sizes.

Detect:
- clipped text;
- broken layouts;
- overlapping UI;
- unreadable scaling;
- fixed-size typography;
- inaccessible custom text rendering.

The application should remain usable at large accessibility text sizes.

---

## 2. VoiceOver Accessibility

Evaluate:
- accessibility labels;
- hints;
- semantic grouping;
- reading order;
- navigation clarity;
- focus behavior.

Detect:
- unlabeled controls;
- duplicate labels;
- meaningless labels;
- broken focus order;
- inaccessible custom gestures;
- hidden context.

VoiceOver users should understand:
- what elements are;
- what they do;
- where they are.

---

## 3. Contrast & Visual Accessibility

Evaluate:
- text contrast;
- icon contrast;
- semantic color usage;
- readability in light/dark mode;
- visual clarity.

Detect:
- low contrast text;
- decorative color dependency;
- inaccessible color combinations;
- hidden visual hierarchy;
- transparency-related readability issues.

Accessibility must survive:
- dark mode;
- bright environments;
- visual impairments.

---

## 4. Touch Targets & Motor Accessibility

Evaluate:
- tap target sizes;
- spacing between controls;
- gesture complexity;
- reachability;
- interaction precision requirements.

Detect:
- tiny controls;
- crowded actions;
- gesture-only interactions;
- difficult drag interactions;
- inaccessible swipe dependencies.

Interactions should not require:
- precision;
- speed;
- perfect motor control.

---

## 5. Reduce Motion & Motion Sensitivity

Evaluate:
- Reduce Motion support;
- animation intensity;
- parallax usage;
- transition aggressiveness;
- motion-triggering patterns.

Detect:
- mandatory motion-heavy flows;
- excessive animation;
- motion-triggering transitions;
- inaccessible visual effects.

Motion should support clarity, not overwhelm users.

---

## 6. Cognitive Accessibility

Evaluate:
- clarity;
- simplicity;
- predictability;
- cognitive load;
- language complexity;
- navigation consistency.

Detect:
- excessive information density;
- confusing flows;
- overwhelming onboarding;
- unclear actions;
- ambiguous labels;
- hidden functionality.

Accessibility includes:
- mental effort reduction.

---

## 7. Forms & Input Accessibility

Evaluate:
- keyboard support;
- form labeling;
- error clarity;
- validation feedback;
- input predictability.

Detect:
- unclear errors;
- inaccessible placeholders;
- validation-only color feedback;
- keyboard traps;
- hidden required fields.

Forms should feel:
- supportive;
not punishing.

---

## 8. Gesture & Navigation Accessibility

Evaluate:
- navigation discoverability;
- gesture alternatives;
- assistive interaction compatibility;
- navigation consistency.

Detect:
- hidden gesture dependencies;
- inaccessible swipe-only actions;
- unclear back navigation;
- navigation traps.

Core functionality should never depend only on hidden gestures.

---

## 9. Accessibility in Premium & Emotional UX

Evaluate whether:
- accessibility settings preserve emotional quality;
- accessible layouts still feel premium;
- larger text still feels calm and intentional.

Detect:
- accessibility treated as degraded mode;
- broken emotional coherence under accessibility settings;
- visually chaotic scaling.

Accessible UX should still feel:
- refined;
- calm;
- intentional.

---

## 10. Long-Term Accessibility Sustainability

Evaluate whether the accessibility approach is:
- systemic;
- maintainable;
- architecture-supported.

Detect:
- one-off fixes;
- inaccessible custom components;
- inconsistent accessibility practices;
- fragile accessibility support.

Accessibility should scale with the product.

---

# Areas to Challenge Aggressively

The review must aggressively challenge:

- Tiny touch targets
- Gesture-only interactions
- Fixed font sizes
- Low contrast aesthetics
- Decorative typography hurting readability
- Accessibility sacrificed for visual polish
- Motion-heavy transitions
- Unlabeled controls
- Placeholder-only forms
- Excessive information density
- Inaccessible custom controls
- Overly subtle UI
- Hidden navigation patterns
- Accessibility treated as optional
- “Looks premium but inaccessible” decisions

The review should optimize for:
- inclusion;
- clarity;
- dignity;
- usability.

---

# Accessibility Philosophy

The goal is not:
- minimum compliance;
- checkbox accessibility.

The goal is:
- respectful usability;
- inclusive design;
- emotional accessibility;
- long-term trust.

Accessibility should feel:
- integrated;
not bolted on.

A premium app should remain premium for everyone.

---

# Benchmarks

Compare against:
- top-tier accessible iOS apps;
- mature Apple ecosystem applications;
- accessibility-conscious premium products.

Do not compare against:
- visually trendy but inaccessible apps;
- web-first mobile ports;
- compliance-only implementations.

---

# Scoring

Provide a score from 0-10 for:

| Category | Score |
|---|---|
| Dynamic Type Support | /10 |
| VoiceOver Accessibility | /10 |
| Contrast & Visual Accessibility | /10 |
| Touch & Motor Accessibility | /10 |
| Motion Accessibility | /10 |
| Cognitive Accessibility | /10 |
| Forms & Input Accessibility | /10 |
| Navigation Accessibility | /10 |
| Accessibility Consistency | /10 |
| Overall Accessibility Maturity | /10 |

Also estimate:

- WCAG alignment confidence
- Risk of accessibility-related frustration
- Risk of exclusionary UX
- Long-term accessibility sustainability
- Confidence level for App Store accessibility quality

---

# Severity Levels

## Critical
Strongly blocks accessibility or excludes users.

## High
Noticeably harms usability or accessibility quality.

## Medium
Moderate accessibility weakness or inconsistency.

## Low
Minor accessibility improvement opportunity.

---

# Output Format

## Executive Summary

High-level assessment of accessibility quality and inclusiveness.

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

## Critical Accessibility Barriers

Major accessibility blockers requiring urgent attention.

---

## VoiceOver Findings

Screen reader usability analysis.

---

## Dynamic Type Findings

Large text scalability assessment.

---

## Motion & Cognitive Accessibility Findings

Assessment of animation, clarity and cognitive load.

---

## Visual Accessibility Findings

Contrast, readability and visual clarity analysis.

---

## Accessibility Architecture Risks

Structural accessibility weaknesses likely to scale poorly.

---

## Most Accessible Areas

Strongest accessibility-related design decisions.

---

## Recommended Accessibility Improvements

Highest-impact accessibility improvements ordered by severity.

---

## Observed Issues

Findings directly supported by evidence.

---

## Strategic Recommendations

Recommendations or inferences based on the observed evidence.

---

## Recommended Next Iteration

Top improvements with greatest impact on inclusiveness and usability.

---

# Review Philosophy

The goal is not simply to avoid accessibility failures.

The goal is to create a product that feels:
- usable;
- respectful;
- calm;
- understandable;
- emotionally safe;

for as many people as possible.

Accessibility is part of product craftsmanship.