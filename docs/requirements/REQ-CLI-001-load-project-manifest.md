---
aeos_record: REQ
id: REQ-CLI-001
status: accepted
priority: critical
created: 2026-08-15
updated: 2026-08-16
---
# REQ-CLI-001 — Load Project Manifest

## Requirement
Locate and safely parse aeos.yaml from the project root.

## Acceptance Criteria
Valid manifests parse; missing/malformed manifests produce structured findings; configuration is never executed.
