---
aeos_record: STAGE
id: STAGE-02-DESIGN
sequence: 2
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-02-DESIGN — Design

## Purpose
Decide how the accepted request will be met, and record the reasoning so the decision survives the person who made it. Design absorbs what earlier vocabularies called Understand, Classify, Plan and Structure.

## Principles
1. Prefer the minimum trustworthy complexity the problem actually requires.
2. Record rejected alternatives. A decision without its discarded options cannot be re-evaluated later.
3. Do not create a parallel source of truth. Every consumer reads the same records.
4. Dependencies are decisions. Adding one is never incidental.
5. Reversibility is a design property. State what it would cost to undo this.

## Protocol
1. Read the existing implementation before proposing changes to it.
2. State the problem in terms of observable behavior, not desired code.
3. Enumerate at least two viable approaches.
4. Choose one and write down why the others were rejected.
5. Identify the security and data implications before implementation, not after.
6. Record the decision as an ADR when it constrains future work.
7. Define what evidence will prove the design correct.

## Entry Criteria
Intake accepted the request and its unknowns are either resolved or explicitly accepted as risks.

## Exit Gate
- The chosen approach is recorded, with rejected alternatives and reasons.
- Security and data implications are stated.
- Reversal cost is stated.
- New dependencies are named and justified, or confirmed as none.
- The evidence that would prove the design correct is defined in advance.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Design the escape hatch before it is needed
Module path migration was chosen over repository rename. The accepted consequence — Go case-encoding the path as `github.com/baa-211/!aeos-` — was recorded at decision time rather than discovered later. Reversal cost was also recorded: cheap before first publish, expensive after any consumer runs `go get`. That framing made the decision straightforward.

### 2026-08-26 — Sequencing is a design decision
Building authentication before a product surface existed would have committed the project permanently to password reset, recovery and migration obligations for state that did not yet exist. The design held was a local vault sealed with XChaCha20-Poly1305, whose sealing material is derived from the passphrase using Argon2id, with email as a label rather than a credential and no server. Deferring it was the design, not an absence of one.
