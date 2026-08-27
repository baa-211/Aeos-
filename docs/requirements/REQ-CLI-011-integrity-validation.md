---
aeos_record: REQ
id: REQ-CLI-011
status: implemented
priority: critical
created: 2026-08-15
updated: 2026-08-15
---
# REQ-CLI-011 — Integrity Validation

## Requirement
`aeos check` shall validate the minimum repository integrity needed before the reporting milestone.

## Acceptance Criteria
- [x] Level B+ projects require `PROJECT.md` and `STATUS.md` as regular non-symlink files.
- [x] Duplicate AEOS record IDs produce deterministic ERROR findings.
- [x] Simple AEOS record references are extracted from supported frontmatter scalars/lists.
- [x] References to nonexistent record IDs produce deterministic ERROR findings.
- [x] Findings are ordered deterministically.
- [x] Integrity errors return exit code 2.
- [x] The implementation remains intentionally narrower than a general YAML parser.

## Non-Goals
JSON reporting, generalized finding schemas, secret scanning, and heuristic architecture analysis remain later milestones.

## Verification
Unit tests, `go vet`, build, and repository self-check.
