---
aeos_record: STATUS
updated: 2026-08-31
version: "0.0.8"
environment: development
---

# Project Status

## Current Objective
M6 dogfooding: run AEOS against itself, fix real friction, and close accepted MVP gap REQ-CLI-006 (STATUS staleness).

## Current Milestone
M1 — Manifest loading: COMPLETE.

M2 — Record discovery/index: COMPLETE.

M3 — Integrity validation: COMPLETE.

M4 — Reporting contract: COMPLETE.

M5 — Security integration: **COMPLETE**, closed 2026-08-26 with live CI evidence.

Evidence: GitHub Actions run #4 on `baa-211/Aeos-`, all 14 steps green in 33s. The run installs pinned Gitleaks 8.30.0 and verifies its SHA-256 against published checksums before trusting the binary, then proves AEOS *blocks* on a runtime-generated planted secret (exit 3, AEOS-SEC-001) rather than merely proving the scanner detects one. It also asserts the JSON report contains no machine-specific absolute paths.

Prior local verification (dir-mode detection, git-history detection of a secret deleted from the working tree, redaction confirmed by grepping raw values out of console and JSON output, and correct AEOS-SEC-010 blocking when the scanner is absent) is now corroborated by reproducible CI.

M6 — Dogfood: **CURRENT**.

## Current Architecture
Single-process Go CLI. The deterministic core performs manifest loading, record discovery, integrity validation, standardized reporting, and external Gitleaks scanning when required by `aeos.yaml`.

Current pipeline:

`aeos check` → manifest → record discovery → integrity validation → pinned secret scan → standardized console/JSON report → stable exit code.

When the target is a Git repository, secret scanning uses both current-directory and Git-history coverage.

## Current Risks
0. `REQ-CLI-006` (STATUS staleness) is accepted but not implemented; it is assigned to M6 and must close before M8. Real evidence for it surfaced during M5 closure: `README.md` and `PROJECT.md` both still claimed milestone M1 while the project had reached M5. AEOS validated its own integrity and did not catch that, because staleness detection does not exist yet. This is the strongest available argument for the requirement.
2. Repository identity is RESOLVED. The user elected to keep the existing remote `baa-211/Aeos-`, and the Go module path was migrated to `github.com/baa-211/Aeos-` to match it. Consequence accepted: the path contains an uppercase letter, so the Go module proxy and local module cache address it case-encoded as `github.com/baa-211/!aeos-`. Renaming the repository later would require a second module-path migration and would break any `go get` already using the current path.
3. The narrow manifest/frontmatter parser must not silently become an incomplete general YAML implementation.
4. Secret-scanner pinning must be revisited when upstream releases are re-evaluated; `latest` must not be trusted automatically.
5. Scope drift remains a larger project risk than missing non-critical features before v0.1.

## Open M6 Gaps
1. `REQ-CLI-006` STATUS staleness remains unimplemented; freshness configuration must be built before detection. This is now the single remaining M6 blocker.
2. Stage gate enforcement — refusing to report readiness when a required stage record is missing or stale — needs new code and is scheduled behind item 1, which supplies the freshness mechanism it depends on.
3. The CLI has no `--version` flag; the binary cannot report what it is.

## Closed M6 Gaps
- Record index in the JSON report — closed by CHG-020, schema 0.2.
- Version drift across manifest and records — closed by CHG-021, enforced by `AEOS-VER-001`.
- No versioning policy or changelog — closed by CHG-022.

## Priority
Preserve the M5→M8 trust-engine critical path while allowing the new Preview/UI direction to prototype in an isolated, non-authoritative track that consumes the same AEOS truth model.

## Preview/UI Direction
A user-facing local preview is now a deliberate product direction. It must not duplicate validation logic, introduce hidden project state, or become a second source of truth. Main visual/product requirements live in the handoff bundle outside this canonical source snapshot until formally recorded.

## Current External State
Published at `https://github.com/baa-211/Aeos-.git`, public, MIT licensed, default branch `main`. Intentionally separate from `baa_atelier`. CI is live and passing.

The publishing token lacked `workflow` scope, so `.github/workflows/ci.yml` was added in a separate commit through the GitHub web UI rather than in the initial push.

## System Health
Local tests/build: PASSING (gofmt clean, `go vet ./...` clean, `go test ./...` green on Go 1.24.4)

M5 adapter tests: PASSING

M5 real-scanner verification (local): PASSING against pinned Gitleaks 8.30.0

Report determinism: VERIFIED — the same project checked from two different filesystem locations produces byte-identical JSON

Coverage: config 77.7%, records 79.0%, secrets 77.6%, validation 77.1%, reporting 58.7%, cmd 57.3%, findings 95.2%

Live Gitleaks CI verification: PASSING — run #4, 14/14 steps green

Production: NOT RELEASED

## Recently Closed
A cross-mode path defect in the secret scanner was found and fixed (CHG-012). `gitleaks dir` and `gitleaks git` reported paths in different forms, which defeated deduplication and put machine-specific absolute paths into the deterministic JSON report. Pre-publish hygiene was completed in CHG-013 and CI evidence strengthened in CHG-014.
