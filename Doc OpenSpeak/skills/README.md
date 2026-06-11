# Product Review Skills

This folder contains reusable review skills for AI-assisted product, UX, architecture, accessibility, performance, monetization and release-readiness audits.

These skills are not executable plugins by themselves. They are structured review playbooks that can be used by Codex, Claude, ChatGPT, Cursor, Cline or other LLM/agent tools when explicitly referenced.

## Usage

Use a skill by explicitly asking an LLM to review a product area using:

- the global rules in `skills/README.md`;
- the specific `skill.yaml`;
- the specific `prompt.md`;
- the relevant product evidence.

Example:

```text
Review the current onboarding flow using:
- skills/README.md
- skills/onboarding-retention-review/skill.yaml
- skills/onboarding-retention-review/prompt.md

Context:
- screenshots from snapshots/2026-05-27-v0.3
- OpenSpec requirements
- current SwiftUI views
- known limitations
```

## Global Output Language

All audit reports must be generated in Spanish from Spain.

The skill files may be written in English, but the final review output must be in Spanish.

## Evidence Rules

- Cite files, screenshots, flows, code areas, OpenSpec requirements or product documents when possible.
- Mark confidence as High, Medium or Low.
- Do not invent metrics, user behavior, implementation details, business data or technical maturity.
- Separate observed issues from strategic recommendations.
- If evidence is incomplete, explicitly state the limitation.
- Prefer specific findings over generic feedback.
- Avoid claiming that something is broken unless there is evidence.
- Use “risk” language when something is inferred but not directly observed.

## Confidence Rules

Use:

- High: Direct evidence exists in code, screenshots, flows, OpenSpec or previous audits.
- Medium: Evidence is partial but the inference is reasonable.
- Low: The finding is speculative or depends on missing context.

Every major finding should include a confidence level.

## Severity Rules

Use these severity levels consistently:

### Critical

Strongly damages trust, usability, accessibility, stability, security, monetization, retention or long-term sustainability.

### High

Significant negative impact on product quality, user experience, architecture, release readiness or perceived maturity.

### Medium

Noticeable weakness that should be addressed but is not immediately blocking.

### Low

Minor refinement, polish opportunity or future improvement.

## Recommendation Rules

Every recommendation should:

- explain why it matters;
- explain the expected impact;
- explain the risk if ignored;
- be actionable;
- prioritize simplicity when possible;
- avoid adding unnecessary complexity;
- distinguish short-term fixes from strategic improvements.

## Review Philosophy

The goal is not to maximize features.

The goal is to improve:

- product quality;
- clarity;
- calmness;
- trust;
- emotional coherence;
- accessibility;
- maintainability;
- resilience;
- performance;
- sustainability;
- premium perception.

Challenge aggressively:

- unnecessary complexity;
- feature creep;
- vague product direction;
- visual noise;
- fragile architecture;
- inaccessible UX;
- manipulative monetization;
- retention tactics based on pressure;
- premature production release.

## Report Structure

Unless a specific skill overrides it, each report should include:

1. Executive Summary
2. Evidence & Confidence Notes
3. Overall Scores
4. Critical Findings
5. High Priority Findings
6. Medium / Low Priority Findings
7. Observed Issues
8. Strategic Recommendations
9. Recommended Next Iteration
10. Open Questions / Missing Evidence

## Snapshot & Audit Convention

Audits should be stored outside this folder using a date-version convention:

```text
audits/
  2026-05-27-v1.0/
    ios-hig-review.md
    architecture-review.md
    executive-product-review.md
```

Snapshots should use the same naming convention:

```text
snapshots/
  2026-05-27-v1.0/
```

Audit folders should be treated as immutable historical records.

These skills define how to review the product. They do not define current product requirements; use `../openspec/` for stable requirements and `../CurrentContext.md` for live handoff context.
