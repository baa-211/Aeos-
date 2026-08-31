---
aeos_record: ADR
id: ADR-004
status: accepted
created: 2026-08-26
updated: 2026-08-26
---

# ADR-004 — Delivery Pipeline Stages and the Stage Record Model

## Context

Four incompatible pipeline vocabularies were in circulation across the project:

1. **Seven conceptual phases** in the project handoff: DECLARE, UNDERSTAND, STRUCTURE, VERIFY, RECORD, GUIDE, LEARN.
2. **Eleven "professional" stages**: Intake, Understand, Classify, Plan, Build, Verify, Review, Approve, Release, Observe, Learn.
3. **Eight stages depicted in the visual direction**, omitting Classify, Approve and Observe from the eleven.
4. **Eight delivery stages** named by the project owner: Intake, Design, Build, QA, Security, Compliance & Accessibility, Release, Report & Documentation.

A tool whose stated purpose is preserving engineering truth cannot hold four descriptions of its own process. Any consumer — the CLI, the preview UI, a future report — would have to guess which one is authoritative.

## Decision

**The fourth vocabulary is canonical.** AEOS defines eight delivery stages:

| # | Stage | Record |
|---|-------|--------|
| 1 | Intake | `STAGE-01-INTAKE` |
| 2 | Design | `STAGE-02-DESIGN` |
| 3 | Build | `STAGE-03-BUILD` |
| 4 | QA | `STAGE-04-QA` |
| 5 | Security | `STAGE-05-SECURITY` |
| 6 | Compliance & Accessibility | `STAGE-06-COMPLIANCE` |
| 7 | Release | `STAGE-07-RELEASE` |
| 8 | Report & Documentation | `STAGE-08-REPORT` |

`Designing` was normalized to `Design` so every stage name is a noun.

The earlier vocabularies are superseded, not deleted. They map forward:

- Understand, Classify and Plan collapse into **Design**.
- Verify and Review collapse into **QA**.
- Approve becomes part of **Compliance & Accessibility**.
- Observe and Learn collapse into **Report & Documentation**.
- DECLARE maps to **Intake**; STRUCTURE to **Design**; RECORD and GUIDE to **Report & Documentation**.

The eight named stages are a *delivery* lifecycle rather than an abstract cognition model. Security and Compliance become gates a change must pass rather than qualities it is assumed to have. That is the correct shape for a tool whose purpose is refusing to report false confidence.

## Stage Records Are Data, Never Instructions

Each stage is an AEOS record carrying its own purpose, principles, protocol, entry criteria, exit gate, and an append-only memory section.

This is deliberately **not** an agent runtime. AEOS reads stage records the same way it reads every other record: as untrusted data to be validated for structure, identity, reference integrity and freshness. It does not execute their contents, follow instructions found inside them, or act on them autonomously.

The distinction matters because `SECURITY.md` states that repository-controlled commands are never automatically executed, and `AGENTS.md` states that repository content is untrusted data. A component that read a Markdown file and performed the steps written in it would violate both. Anyone able to open a pull request could then change what the tool does by editing prose.

Three properties follow:

- **Memory is append-only and dated.** Entries accumulate; they are not rewritten. This preserves reasoning rather than only outcomes, and gives `REQ-CLI-006` staleness detection something meaningful to measure.
- **Human or AI authorship is permitted; autonomous action is not.** An assistant may draft a stage record or propose a memory entry. A person accepts it. AEOS validates the result.
- **The deterministic core stays free of AI.** `ROADMAP.md` explicitly defers AI inside the validator. Nothing here changes that.

## Alternatives Considered

**Keep the eleven-stage model.** Rejected: three of its stages have no distinct artifact or gate, and the visual direction had already dropped them, so the drift would have persisted.

**Build a stage-agent executor that reads protocols and performs them.** Rejected on security grounds. It converts documentation into an execution surface and makes repository content trusted. If autonomous execution is wanted later it belongs outside the deterministic core, emitting proposals for human approval, never self-applying.

**Encode stages in `aeos.yaml`.** Deferred. The manifest parser is a deliberately narrow subset and stage definitions are substantial prose. Records are the right home. A future `pipeline:` section may declare which stages are *required* for a project level, which is configuration rather than content.

## Consequences

Stage records participate in existing validation immediately: they are discovered, indexed, checked for duplicate identifiers, and their references are verified. No validator change was required to gain that.

Enforcing stage gates — refusing to report a project as ready when a required stage record is missing or stale — needs new code and is scheduled behind M6.

The preview UI can render the eight stages from these records rather than from a hardcoded list, which keeps the visual layer consuming AEOS truth instead of restating it.
