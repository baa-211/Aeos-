---
aeos_record: REQ
id: REQ-CLI-012
status: implemented_pending_live_verification
priority: critical
created: 2026-08-16
updated: 2026-08-26
related_adrs:
  - ADR-003
---

# REQ-CLI-012 — Mature Secret Scanner Integration

## Requirement
When `security.secret_scan.required` is true, `aeos check` shall run the approved external secret scanner and fail safely if trustworthy scanning cannot be completed.

## Acceptance Criteria
- [x] Secret scanning is implemented through an established external scanner rather than custom detection logic.
- [x] The approved pilot scanner version is verified before scanning.
- [x] Missing scanner produces a blocking finding.
- [x] Unsupported scanner version produces a blocking finding.
- [x] Scanner execution failure produces a blocking finding.
- [x] Detected secrets produce CRITICAL AEOS findings.
- [x] AEOS findings never include raw secret values.
- [x] Adapter behavior is covered with controlled executable fixtures.
- [x] Current working/untracked project content is scanned.
- [x] Git history is additionally scanned when the target is a Git repository.
- [ ] A real pinned Gitleaks binary has completed the smoke test in the active remote CI environment.

## Current Verification State
Code-level integration is complete. Live scanner verification still requires the separate AEOS GitHub repository to be published and the prepared CI workflow to complete successfully with the pinned scanner.
