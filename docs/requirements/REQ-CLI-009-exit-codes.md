---
aeos_record: REQ
id: REQ-CLI-009
status: implemented
priority: critical
created: 2026-08-16
updated: 2026-08-16
---

# REQ-CLI-009 — Stable Exit Codes

## Requirement
The CLI shall return stable exit codes suitable for local automation and CI.

## Contract
- `0` — validation completed without blocking findings
- `2` — deterministic validation error
- `3` — critical finding
- `4` — configuration/input failure
- `5` — internal validator failure

Warnings do not fail by default.

## Acceptance Criteria
- [x] Configuration failures use exit code 4.
- [x] Integrity errors use exit code 2.
- [x] Critical severity has a reserved blocking code 3.
- [x] Internal failures use exit code 5.
- [x] Successful checks return 0.
