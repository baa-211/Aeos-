---
aeos_record: STAGE
id: STAGE-01-INTAKE
sequence: 1
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-01-INTAKE — Intake

## Purpose
Capture what is actually being asked before anything is designed or built. Intake exists to prevent the most expensive class of failure: building the wrong thing correctly.

## Principles
1. Ambiguity is a finding, not an inconvenience. An unclear request is recorded as unclear rather than resolved by assumption.
2. The requester's words are evidence. Restating a request in more convenient terms is how scope quietly changes owner.
3. Nothing enters the pipeline unclassified. A change with no level, no security level and no owner cannot be gated later.
4. Say no early. Rejecting work at Intake costs a conversation; rejecting it at Release costs a rollback.

## Protocol
1. Record the request verbatim, with its source and date.
2. Identify what is being asked for and what is being assumed.
3. Classify: change type, project level, security level, data classification.
4. Name the smallest outcome that would satisfy the request.
5. List what is unknown. Do not fill gaps with plausible guesses.
6. Check the request against `ROADMAP.md` priority rules and the Branch Gate.
7. Accept, defer to backlog, or reject — and record which, with the reason.

## Entry Criteria
A request exists from any source: a person, an incident, a failing check, or a scheduled review.

## Exit Gate
- The request is recorded with its original wording.
- Classification is complete: type, level, security level, data class.
- Unknowns are listed explicitly rather than resolved by assumption.
- A disposition is recorded: accepted, deferred, or rejected, with reasoning.
- If accepted, the request answers at least one Branch Gate question in `ROADMAP.md`.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Ambiguity resolved silently is ambiguity twice
A repository identity conflict (`baa-211/Aeos-` versus module `github.com/baa-211/aeos-cli`) went unresolved across several sessions because each session treated it as a detail rather than an Intake decision. It was finally settled by explicit choice: keep the repository, migrate the module. The cost of deciding late was a codebase-wide edit across seventeen files. Deciding at Intake would have cost one settings change.

### 2026-08-26 — A request for a feature is not a request for its architecture
An account system was requested as "a login screen with email and password." Taken literally that implies hosted accounts, a database and a credential store — all forbidden by `PROJECT.md` non-goals. The underlying need was persistence, not authentication. Intake's job is to surface that gap before Design commits to the literal reading.
