---
aeos_record: REQ
id: REQ-CLI-008
status: implemented
priority: high
created: 2026-08-16
updated: 2026-08-16
---

# REQ-CLI-008 — JSON Reporter

## Requirement
The CLI shall provide a deterministic, versioned JSON report suitable for CI systems and AI engineering agents.

## Acceptance Criteria
- [x] `aeos check --format json` emits valid JSON only to stdout.
- [x] JSON schema version is included.
- [x] Project metadata, summary, findings, and result are represented.
- [x] Findings use stable rule IDs and severity values.
- [x] Empty findings serialize as `[]`, not `null`.
- [x] Repository-relative manifest path is used so output does not depend on workstation path.
