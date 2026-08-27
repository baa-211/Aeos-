---
aeos_record: ADR
id: ADR-003
status: accepted
impact: high
created: 2026-08-16
updated: 2026-08-26
---

# ADR-003 — Secret Scanner Integration

## Context
AEOS M5 requires mature secret detection without building a custom scanner. The validator must avoid false confidence from unsupported or known-bad scanner versions and must cover both active project content and secrets that may have been committed and later removed.

## Options Considered
- Build a custom scanner — rejected because it would duplicate mature security tooling and create unacceptable false-negative risk.
- Integrate Gitleaks as an external executable — selected for the pilot.
- Defer secret scanning entirely — rejected because secret protection is on the critical path before dogfooding/release.

## Decision
Integrate Gitleaks through a narrow external-process adapter. During the pilot, require Gitleaks `8.30.0` exactly.

The CLI runs `gitleaks dir` for current/untracked working content and, when the target is a Git repository, also runs `gitleaks git` for committed history. Both scans use full redaction and JSON report output. AEOS never copies detected secret values into its own findings.

## Why Version 8.30.0 Is Pinned
The project audit documented an upstream 8.30.1 regression risk in which canonical secrets could be missed while the scanner exited successfully. AEOS therefore must not interpret “latest” as automatically safe. Re-evaluate this pin from current upstream evidence before a future release.

## Security Consequences
- Repository data is passed to an established scanner rather than a home-grown detector.
- Current working content and Git history receive separate coverage.
- Scanner output is treated as untrusted input.
- AEOS output includes rule/path metadata but not secret values.
- Missing, unsupported, or failed scanners create blocking findings rather than a false PASS.

## Path Normalization Across Scan Modes
The two scan modes disagree about path form: `gitleaks dir` reports absolute filesystem paths while `gitleaks git` reports repository-relative paths. The adapter therefore normalizes every reported path to a project-relative, slash-separated form before constructing an AEOS finding.

Without this, one secret present in both the working tree and Git history produced two findings that deduplication could not match, inflating critical counts; and the JSON report carried machine-specific absolute paths, breaking the deterministic reporting contract established in M4.

A path that resolves outside the project root keeps its absolute form. Misreporting where a secret lives would be a worse failure than a non-relative path in the report.

## Operational Consequences
The scanner is an external dependency and must be installed separately or supplied through `AEOS_GITLEAKS_PATH`.

## Reversal Trigger
Re-evaluate the pinned version or scanner when:
- a newer Gitleaks release is security-reviewed and verified against the regression concern;
- upstream maintenance/support changes materially;
- another scanner demonstrates stronger accuracy, maintenance, or operational fit;
- real pilot evidence shows unacceptable false positives/negatives.
