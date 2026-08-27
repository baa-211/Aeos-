---
aeos_record: REQ
id: REQ-CLI-007
status: implemented
priority: high
created: 2026-08-16
updated: 2026-08-16
---

# REQ-CLI-007 — Console Reporter

## Requirement
The CLI shall produce concise, deterministic, human-readable findings for `aeos check`.

## Acceptance Criteria
- [x] Each finding includes stable rule ID, severity, and message.
- [x] Paths are included when available.
- [x] Recommended action is included when defined.
- [x] Higher-severity findings are ordered before lower-severity findings.
- [x] The result clearly reports PASS, PASS_WITH_WARNINGS, or FAIL.
