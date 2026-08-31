---
aeos_record: STAGE
id: STAGE-08-REPORT
sequence: 8
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-08-REPORT — Report & Documentation

## Purpose
Record what actually happened and why, so the reasoning outlives the session that produced it. This stage absorbs what earlier vocabularies called Observe, Learn, Record and Guide.

## Principles
1. Preserve reasoning, not only outcomes. A decision without its rationale becomes folklore.
2. Records must age honestly. A document claiming a superseded state is worse than no document.
3. Report unknowns as unknowns. Never hide UNKNOWN, STALE or BLOCKED behind a score.
4. Documentation drift is a defect with a severity, not untidiness.
5. Write the negative result. Approaches that failed are as instructive as ones that worked.

## Protocol
1. Record what changed, why, and what evidence supports it.
2. Note which founding principle, if any, was strained.
3. Update every record the change invalidated — in the same change.
4. Append dated memory entries to the stages this work passed through.
5. State the known unknowns explicitly.
6. Name the next smallest high-value step.

## Entry Criteria
Release gate passed, or the work concluded without release.

## Exit Gate
- Change is recorded with reasoning and supporting evidence.
- Every record invalidated by the change has been updated.
- Strained principles are named.
- Known unknowns are stated rather than omitted.
- The next step is recorded.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Eleven days of undetected drift, found by accident
`README.md` and `PROJECT.md` both claimed milestone M1 while the project had reached M5. Four completed milestones went unreflected. AEOS validated its own integrity throughout and did not notice, because `REQ-CLI-006` staleness detection is accepted but unimplemented. The tool built to catch documentation drift failed to catch its own — which is the strongest available argument for building the requirement, and the reason it leads M6.

### 2026-08-26 — Four vocabularies for one pipeline
Seven conceptual phases, eleven professional stages, eight rendered globes and eight delivery stages all described the same process differently. Each was created in a separate session and none referenced the others. Reconciled in `ADR-004`. The general lesson: a naming decision made without reading the previous naming decision produces a fourth truth rather than a corrected one.
