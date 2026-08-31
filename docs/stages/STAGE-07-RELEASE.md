---
aeos_record: STAGE
id: STAGE-07-RELEASE
sequence: 7
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-07-RELEASE — Release

## Purpose
Make the change available, only when evidence justifies it.

## Principles
1. Evidence precedes release. A milestone closes on a reproducible result, not on a local one.
2. A milestone is not complete because it is implemented.
3. Publication is one-way. Anything public should be assumed permanent.
4. Version numbers are claims. They should be defensible.
5. Prefer a release that admits what is missing over one that implies completeness.
6. One version, one source. `project.version` in the manifest is authoritative; every versioned record must agree, and `AEOS-VER-001` enforces it.
7. `main` is always the latest verified state. Tags are applied to commits that already passed CI, never in anticipation.
8. A diverged branch is ambiguity about which version is current. Merge it or delete it; never leave it.

## Protocol
1. Confirm all prior stage gates passed.
2. Run the full verification suite in a clean environment, not only locally.
3. Scan for secrets one final time against the exact tree being published.
4. Confirm continuous integration passes on the published artifact, not a local copy.
5. Record what is deliberately absent from this release.
6. Update version and status records to reflect the evidence, not the intent.

## Entry Criteria
Compliance & Accessibility gate passed.

## Exit Gate
- Every prior stage gate is passed and recorded.
- CI passes on the published repository.
- Final secret scan of the published tree is clean.
- Known gaps and deliberate omissions are recorded in the release notes.
- Version and status records match the evidence rather than the plan.
- `AEOS-VER-001` is clean: no record disagrees with the manifest version.
- A `CHANGELOG.md` entry exists for the version.
- The commit is tagged, and the tag, `main`, and `aeos.yaml` all agree.
- No branch remains diverged from `main` without a recorded reason.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Publish what you have, state what you do not
The publishing token lacked `workflow` scope, so `.github/workflows/ci.yml` could not be pushed with the initial commit. Rather than presenting the repository as complete, the omission was written into the commit message and M5 was held open until the workflow was added separately and passed. A release that admits a gap is more trustworthy than one that hides it.

### 2026-08-26 — Local evidence is not CI evidence
End-to-end verification against real Gitleaks 8.30.0 passed locally well before M5 closed. That result rested on one machine and one operator's honesty, and nobody could reproduce it. M5 closed only when GitHub Actions run #4 passed all fourteen steps independently.

### 2026-08-31 — Three versions, no tags, nothing watching
`aeos.yaml`, `PROJECT.md` and `STATUS.md` simultaneously declared 0.0.1, 0.0.7 and 0.1.1-rc. There were no Git tags and no changelog, so "the latest version" had no answer. Each file had been edited by a different session with a different idea of what the project had reached.

Resolved by making the manifest authoritative and adding `AEOS-VER-001`, which blocks when any record disagrees with it. Version drift can no longer reach `main`. The general lesson: duplicated state without a mechanism keeping it aligned will diverge, and the mechanism has to be automatic — noticing by eye is what failed here for eleven days.
