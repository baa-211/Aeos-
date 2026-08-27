---
aeos_record: REQ
id: REQ-CLI-006
status: accepted
priority: medium
created: 2026-08-15
updated: 2026-08-16
---
# REQ-CLI-006 — STATUS Staleness

## Requirement
Detect STATUS records older than a configured freshness threshold.

## Acceptance Criteria
Fresh passes; stale warns; invalid/missing date is distinct. Implementation remains deferred until freshness configuration is added.
