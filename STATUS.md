---
aeos_record: STATUS
updated: 2026-08-26
version: "0.0.7"
environment: development
---

# Project Status

## Current Objective
Publish the isolated AEOS repository, close M5 with a real pinned Gitleaks smoke test in GitHub Actions, then begin M6 dogfooding.

## Current Milestone
M1 — Manifest loading: COMPLETE.

M2 — Record discovery/index: COMPLETE.

M3 — Integrity validation: COMPLETE.

M4 — Reporting contract: COMPLETE.

M5 — Security integration: IMPLEMENTED AND VERIFIED LOCALLY END TO END AGAINST REAL GITLEAKS 8.30.0; LIVE CI VERIFICATION STILL PENDING REMOTE PUBLISH.

Local M5 evidence obtained 2026-08-26: dir-mode detection, git-history detection of a secret deleted from the working tree, redaction confirmed by grepping raw secret values out of both console and JSON output, blocking exit code 3, and correct AEOS-SEC-010 blocking failure when the scanner is absent. This is real evidence but it is not CI evidence; M5 does not close until the workflow passes on the published repository.

## Current Architecture
Single-process Go CLI. The deterministic core performs manifest loading, record discovery, integrity validation, standardized reporting, and external Gitleaks scanning when required by `aeos.yaml`.

Current pipeline:

`aeos check` → manifest → record discovery → integrity validation → pinned secret scan → standardized console/JSON report → stable exit code.

When the target is a Git repository, secret scanning uses both current-directory and Git-history coverage.

## Current Risks
0. `REQ-CLI-006` (STATUS staleness) is accepted but not implemented; it is assigned to M6 and must close before M8.
1. M5 is not complete until the workflow runs successfully on the actual GitHub repository.
2. Repository identity is RESOLVED. The user elected to keep the existing remote `baa-211/Aeos-`, and the Go module path was migrated to `github.com/baa-211/Aeos-` to match it. Consequence accepted: the path contains an uppercase letter, so the Go module proxy and local module cache address it case-encoded as `github.com/baa-211/!aeos-`. Renaming the repository later would require a second module-path migration and would break any `go get` already using the current path.
3. The narrow manifest/frontmatter parser must not silently become an incomplete general YAML implementation.
4. Secret-scanner pinning must be revisited when upstream releases are re-evaluated; `latest` must not be trusted automatically.
5. Scope drift remains a larger project risk than missing non-critical features before v0.1.

## Priority
Preserve the M5→M8 trust-engine critical path while allowing the new Preview/UI direction to prototype in an isolated, non-authoritative track that consumes the same AEOS truth model.

## Preview/UI Direction
A user-facing local preview is now a deliberate product direction. It must not duplicate validation logic, introduce hidden project state, or become a second source of truth. Main visual/product requirements live in the handoff bundle outside this canonical source snapshot until formally recorded.

## Current External State
A separate GitHub repository has been created at `https://github.com/baa-211/Aeos-.git`. It is intentionally separate from `baa_atelier`. The repository has not yet been published from this development snapshot or used to produce live M5 CI evidence.

## System Health
Local tests/build: PASSING (gofmt clean, `go vet ./...` clean, `go test ./...` green on Go 1.24.4)

M5 adapter tests: PASSING

M5 real-scanner verification (local): PASSING against pinned Gitleaks 8.30.0

Report determinism: VERIFIED — the same project checked from two different filesystem locations produces byte-identical JSON

Coverage: config 77.7%, records 79.0%, secrets 77.6%, validation 77.1%, reporting 58.7%, cmd 57.3%, findings 95.2%

Live Gitleaks CI verification: PENDING REPOSITORY IDENTITY RESOLUTION + PUBLISH

Production: NOT RELEASED

## Recently Closed
A cross-mode path defect in the secret scanner was found and fixed (CHG-012). `gitleaks dir` and `gitleaks git` reported paths in different forms, which defeated deduplication and put machine-specific absolute paths into the deterministic JSON report. Pre-publish hygiene was completed in CHG-013 and CI evidence strengthened in CHG-014.
