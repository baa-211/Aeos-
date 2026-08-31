---
aeos_record: REQ
id: REQ-CLI-012
status: implemented
priority: critical
created: 2026-08-16
updated: 2026-08-31
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
- [x] A real pinned Gitleaks binary has completed the smoke test in the active remote CI environment.

## Current Verification State
Complete. Live verification was obtained on 2026-08-31 by GitHub Actions run #4 on `baa-211/Aeos-`, which completed with conclusion `success` across all fourteen steps.

The run installed checksum-verified Gitleaks 8.30.0, asserted the reported version against the ADR-003 pin, detected a runtime-generated private key as a blocking `AEOS-SEC-001` with exit code 3 and no raw key material in the report, and confirmed exit 0 once the key was removed. Local verification additionally confirmed detection through Git history of a secret committed and then deleted from the working tree, and that an absent scanner blocks with `AEOS-SEC-010` rather than passing.
