---
aeos_record: STAGE
id: STAGE-05-SECURITY
sequence: 5
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-05-SECURITY — Security

## Purpose
Establish that the change does not create, hide, or weaken a security property. Security is a gate a change must pass, not a quality it is assumed to have.

## Principles
1. **No false green.** Reporting PASS when the system does not know is the worst possible failure. Unknown is reported as unknown.
2. Repository content is untrusted data. Repository-controlled commands are never automatically executed.
3. Silence is not safety. A silently ignored setting is a hazard, not a convenience.
4. Prove blocking, not merely detection. A scanner that fires while the tool ignores it is indistinguishable from a clean run.
5. Secrets are never printed, logged, or written to a report, including while reporting them.
6. Pin external security tooling to an exact version and verify its checksum before trusting it.

## Protocol
1. Identify what the change could cause the system to stop noticing.
2. Scan for secrets in both working content and version history before publishing anything.
3. Confirm findings are redacted by searching output for the raw values.
4. Confirm the tool blocks: assert the failing exit code, not just the presence of a finding.
5. Confirm the absent-tool path fails closed rather than passing.
6. Verify external tool version and checksum against the pin.

## Entry Criteria
QA gate passed.

## Exit Gate
- Secret scan is clean across working tree and history, or every finding is triaged and recorded.
- No raw secret appears in console output, JSON report, or logs.
- The blocking path is proven by exit code, not inferred from a finding count.
- Missing or unverifiable security tooling produces a blocking error, never a pass.
- External security tooling matches its exact pin by checksum.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — A typo silently disabled the security gate
Misspelling the manifest key `security` as `securty` caused the section to be silently ignored. Secret scanning was disabled and AEOS reported PASS with exit code 0 while a live private key sat in the directory. This was a false green inside the tool built to prevent false greens, and it failed open: the path defect found the same day over-counted findings, which errs safe, while this one under-reported to zero. Fixed by rejecting unknown top-level manifest sections outright, with a suggestion for near-misses. The general lesson: for a security tool, permissive parsing of its own configuration is a vulnerability.

### 2026-08-26 — Prove blocking, not detection
The original CI step proved Gitleaks detects a secret. It never proved AEOS acts on one. A regression where the scanner worked but AEOS dropped the finding would have produced a green build. The workflow now asserts exit code 3 and the presence of `AEOS-SEC-001` against a key generated at runtime.

### 2026-08-26 — A credential shared is a credential burned
A GitHub token was transmitted in plaintext through a chat interface. Regardless of intent, copies then existed in locations neither party controlled. The only effective response to credential exposure is revocation; retrieval is not possible.

### 2026-08-26 — AEOS blocked on its own documentation, correctly
The first `aeos check` run after adding the stage records failed with a CRITICAL finding: Gitleaks' `generic-api-key` rule matched a design memory entry where a cipher name appeared directly after the word `key`, reading the algorithm identifier as a high-entropy secret. The offending phrase is deliberately not reproduced here, because quoting it reproduces the finding. A genuine false positive, and the tool behaved correctly by refusing to pass.

Resolved by rewording the prose rather than adding a scanner allowlist. An allowlist would have silenced this finding and every future one matching the same rule, which is the mechanism by which real secrets eventually go unreported. Prose is cheap to change; a weakened detection rule is permanent and invisible.

Discovered during M6 dogfooding. Writing about cryptography in project documentation reliably trips secret scanners, and that friction is worth absorbing rather than configuring away.
