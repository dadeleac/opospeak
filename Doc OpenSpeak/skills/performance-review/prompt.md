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

# Performance Review Skill

## Purpose

Evaluate whether the application delivers a fast, fluid, energy-efficient and technically polished experience aligned with premium iOS expectations.

This review must not focus only on benchmarks or raw speed.

The objective is to determine whether the application:
- feels responsive;
- scales gracefully;
- preserves fluidity;
- minimizes battery impact;
- avoids performance degradation over time;
- maintains premium perceived quality under real-world usage.

The review should aggressively identify:
- hidden bottlenecks;
- architectural performance risks;
- rendering inefficiencies;
- energy waste;
- memory pressure;
- interaction lag;
- scalability issues.

Performance must support calmness and trust.
A premium app should feel effortless.

---

# Expected Context

The review may receive:

- SwiftUI code
- Instruments captures
- Memory usage reports
- CPU usage reports
- Rendering traces
- Launch time measurements
- Battery usage observations
- Scrolling recordings
- Navigation flows
- Sync architecture
- Persistence strategy
- CloudKit operations
- Background task implementation
- Widget architecture
- Animation implementation
- Image handling strategy
- Async workflows
- App lifecycle handling
- Data loading patterns
- Large dataset examples
- Crash reports
- UI videos
- Build configurations
- Feature descriptions

If context is incomplete, explicitly state confidence limitations.

Do not invent measurements.

---

# Core Review Philosophy

Performance is not:
- benchmark chasing;
- micro-optimization;
- premature optimization;
- synthetic scoring.

Performance is:
- responsiveness;
- fluidity;
- predictability;
- energy efficiency;
- absence of friction;
- invisible technical quality.

Users perceive performance emotionally.

The review should optimize for:
- smoothness;
- calmness;
- perceived stability;
- long-term reliability.

---

# Core Evaluation Areas

## 1. Perceived Responsiveness

Evaluate:
- interaction latency;
- navigation responsiveness;
- tap feedback;
- transition smoothness;
- state update speed;
- startup responsiveness.

Detect:
- sluggish interactions;
- delayed feedback;
- blocked UI;
- loading hesitation;
- transition stutter;
- delayed rendering.

The app should feel immediately responsive.

---

## 2. SwiftUI Rendering Efficiency

Evaluate:
- view recomposition behavior;
- body recalculation patterns;
- state invalidation scope;
- list rendering efficiency;
- expensive computed properties;
- unnecessary redraws.

Review:
- Observable usage;
- state propagation;
- Equatable usage;
- lazy containers;
- view identity handling.

Detect:
- excessive recomposition;
- unstable identity;
- rendering loops;
- deeply nested expensive views;
- UI invalidation explosions.

SwiftUI performance issues often emerge from architecture.

---

## 3. Memory Management

Evaluate:
- memory growth;
- allocation patterns;
- caching strategy;
- image memory handling;
- background memory behavior;
- object lifecycle.

Detect:
- memory leaks;
- excessive retention;
- oversized caches;
- unnecessary copies;
- image inflation;
- unbounded memory growth.

The app should remain stable during long-term usage.

---

## 4. Scrolling & List Performance

Evaluate:
- scrolling smoothness;
- lazy loading behavior;
- virtualization strategy;
- image loading impact;
- large dataset handling.

Detect:
- scroll stutter;
- excessive cell work;
- layout thrashing;
- oversized view hierarchies;
- blocking operations during scrolling.

Scrolling quality strongly impacts perceived premium feel.

---

## 5. Startup & Launch Performance

Evaluate:
- cold launch behavior;
- warm launch behavior;
- initialization strategy;
- startup dependency loading;
- unnecessary startup work.

Detect:
- heavy initialization;
- blocking sync at startup;
- excessive eager loading;
- startup spikes;
- launch-time network dependency.

The app should become interactive quickly.

---

## 6. Async & Concurrency Performance

Evaluate:
- async orchestration;
- task lifecycle;
- cancellation handling;
- actor usage;
- main-thread isolation;
- concurrency safety.

Detect:
- excessive task spawning;
- unnecessary MainActor usage;
- hidden thread contention;
- race-condition risks;
- blocking async flows.

Concurrency should simplify performance, not damage it.

---

## 7. Battery & Energy Efficiency

Evaluate:
- background execution impact;
- widget refresh frequency;
- sync behavior;
- animation cost;
- CPU wakeups;
- unnecessary polling;
- sensor usage.

Detect:
- battery-draining patterns;
- excessive background work;
- aggressive refresh strategies;
- inefficient timers;
- unnecessary persistence churn.

A wellbeing app should never feel expensive to run.

---

## 8. Persistence & Sync Performance

Evaluate:
- local database efficiency;
- CloudKit operation batching;
- sync scheduling;
- conflict handling cost;
- persistence frequency.

Detect:
- excessive writes;
- redundant sync operations;
- large transaction overhead;
- blocking persistence operations;
- sync storms.

Offline-first apps require careful performance discipline.

---

## 9. Animation & Motion Performance

Evaluate:
- animation smoothness;
- transition consistency;
- frame pacing;
- rendering complexity;
- motion restraint.

Detect:
- dropped frames;
- animation overload;
- GPU-heavy effects;
- excessive blur/material usage;
- visually expensive transitions.

Motion should feel effortless and stable.

---

## 10. Scalability Over Time

Evaluate whether performance remains sustainable with:
- years of user data;
- larger journals/logs;
- more widgets;
- increased sync complexity;
- expanded feature sets.

Detect:
- performance degradation risks;
- unbounded data assumptions;
- scalability bottlenecks;
- architectural limits.

Performance sustainability matters more than short-term optimization.

---

# Areas to Challenge Aggressively

The review must aggressively challenge:

- Premature optimization
- Over-engineered caching
- Excessive background activity
- Sync-heavy architectures
- Animation overuse
- Rendering-heavy UI patterns
- Deep view hierarchies
- Expensive SwiftUI recomposition
- Main-thread blocking
- Excessive CloudKit chatter
- Widget abuse
- Polling-based logic
- Excessive timers
- Large in-memory datasets
- Battery-hostile patterns
- “Looks fancy but performs badly” design decisions

The review should optimize for:
- smoothness;
- stability;
- efficiency;
- calmness.

---

# Performance Philosophy

The goal is not maximum technical complexity.

The goal is:
- fluidity;
- responsiveness;
- stability;
- energy efficiency;
- sustainable scalability.

A premium app should:
- feel invisible;
- react instantly;
- remain stable over years of use;
- avoid draining user resources.

---

# Benchmarks

Compare against:
- top-tier native iOS apps;
- premium indie applications;
- polished SwiftUI experiences;
- mature local-first apps.

Do not compare against:
- benchmark demos;
- gaming apps;
- enterprise dashboards;
- animation-heavy showcase apps.

---

# Scoring

Provide a score from 0-10 for:

| Category | Score |
|---|---|
| Perceived Responsiveness | /10 |
| SwiftUI Rendering Efficiency | /10 |
| Memory Management | /10 |
| Scrolling Performance | /10 |
| Launch Performance | /10 |
| Async & Concurrency Quality | /10 |
| Battery Efficiency | /10 |
| Sync & Persistence Efficiency | /10 |
| Animation Performance | /10 |
| Long-Term Scalability | /10 |

Also estimate:

- Risk of future performance degradation
- Battery impact risk
- Risk of scalability bottlenecks
- Probability of performance-related UX degradation
- Confidence level for long-term smoothness

---

# Severity Levels

## Critical
Likely to create major UX degradation, instability or battery problems.

## High
Strongly impacts fluidity, scalability or responsiveness.

## Medium
Noticeable performance inefficiency or architectural weakness.

## Low
Minor optimization opportunity.

---

# Output Format

## Executive Summary

High-level assessment of performance quality and sustainability.

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

## Critical Performance Risks

Major bottlenecks or instability risks.

---

## Rendering & SwiftUI Findings

Rendering efficiency and recomposition analysis.

---

## Memory & Battery Findings

Resource usage and energy efficiency assessment.

---

## Sync & Persistence Analysis

Performance implications of local-first and sync architecture.

---

## Scalability Risks

Potential future degradation or scaling bottlenecks.

---

## Most Efficient Areas

Strongest performance-related architectural decisions.

---

## Recommended Optimizations

High-impact improvements ordered by expected benefit.

---

## Observed Issues

Findings directly supported by evidence.

---

## Strategic Recommendations

Recommendations or inferences based on the observed evidence.

---

## Recommended Next Iteration

Top performance improvements with highest product impact.

---

# Review Philosophy

The goal is not technical vanity metrics.

The goal is to create an experience that feels:
- smooth;
- effortless;
- stable;
- calm;
- reliable.

Users should never think about performance.

They should simply feel:
- confidence;
- fluidity;
- trust.