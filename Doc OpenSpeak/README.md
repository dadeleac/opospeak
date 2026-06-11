
# **OpoSpeak Product Docs**

This folder is the working memory for OpoSpeak’s product direction, foundations, specifications, audits, and agent workflows.

## **Start Here**

When opening a new AI-assisted conversation, read these in order:

1. `CurrentContext.md`
2. `foundation/product-foundation.md`
3. `foundation/core-domain-model.md`
4. `foundation/local-first-data-strategy.md`
5. `foundation/privacy-and-export-strategy.md`
6. `foundation/mvp-scope.md`
7. `openspec/config.yaml`
8. The OpenSpec change or specification relevant to the current task
9. The latest audit only when historical evidence or risk context is needed

---

## **Folder Structure**

```txt
docs/
│
├── README.md
├── CurrentContext.md
│
├── foundation/
├── openspec/
├── audits/
├── snapshots/
└── skills/
```

---

## **Responsibilities**

### **CurrentContext.md**

The living handoff document.

It captures:

- current product state
- recent decisions
- current direction
- open questions
- collaboration rules

It should stay concise and focus on the present state of the project.

---

### **foundation/**

Foundation documents define the stable identity of OpoSpeak.

These are long-lived documents that should evolve slowly and only through deliberate decisions.

Examples:

- Product foundation
- Domain model
- Privacy strategy
- Local-first strategy
- MVP scope
- Design principles
- Accessibility principles

Foundation documents explain what OpoSpeak is and how decisions should be made.

---

### **openspec/**

OpenSpec is the source of truth for durable product, UX, architecture, and implementation requirements.

Use OpenSpec whenever a change affects:

- product behaviour
- navigation
- data model
- architecture
- privacy
- monetization
- accessibility
- synchronization

Foundation explains principles.

OpenSpec explains requirements.

---

### **audits/**

Historical product reviews.

Audits are immutable records of findings at a specific point in time.

Do not rewrite old audits to match the current product.

Create a new audit instead.

---

### **snapshots/**

Frozen evidence used by audits.

Examples:

- screenshots
- UI captures
- exported flows
- architecture snapshots

Snapshots preserve historical context.

---

### **skills/**

Reusable review and analysis playbooks.

Examples:

- product reviews
- accessibility reviews
- architecture reviews
- UX reviews
- performance reviews

Skills should remain portable across projects.

---

### **.agents/**

Stored at repository root.

Contains:

- agent instructions
- OpenSpec workflows
- automation rules

It is operational documentation, not product documentation.

---

## **Product Thesis**

OpoSpeak exists because oral preparation is a long-term process.

The problem is not recording a topic.

The problem is managing years of oral practice.

The product focuses on:

- organization
- continuity
- historical context
- long-term progress

Not on:

- legal content
- academies
- social features
- AI tutoring

---

## **Product Principles**

OpoSpeak should remain:

- Apple-first
- Local-first
- Privacy-first
- Offline-capable
- Export-friendly

The user owns the data.

The application organizes it.

---

## **Documentation Hierarchy**

When documents appear to conflict, follow this order:

```txt
CurrentContext
        ↓
Foundation
        ↓
OpenSpec
        ↓
Audits
        ↓
Snapshots
```

CurrentContext describes today’s reality.

Foundation defines strategic direction.

OpenSpec defines implementation requirements.

Audits and snapshots provide historical evidence.

---

## **Update Rhythm**

Update `CurrentContext.md` after meaningful decisions involving:

- product direction
- navigation
- architecture
- privacy
- synchronization
- monetization
- MVP scope
- design direction

Update Foundation documents when strategic principles change.

Update OpenSpec when durable requirements change.

Create a new audit when validating a new version of the product.

Never rewrite historical audits or snapshots.

---

## **Collaboration Rules**

Use OpenSpec first for significant product or technical changes.

Prefer small, deliberate decisions.

Challenge scope creep.

Protect the product thesis.

Avoid introducing functionality that moves OpoSpeak toward:

- an academy
- a legal platform
- a social network
- a productivity tool
- an AI tutor

unless there is an explicit strategic decision supporting that direction.

---

## **Long-Term Goal**

OpoSpeak should become the complete history of an oppositor’s oral training.

Every decision should reinforce that vision.
