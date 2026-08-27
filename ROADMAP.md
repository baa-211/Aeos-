# AEOS CLI Critical Path

## Objective
Reach a trustworthy v0.1 validator as quickly as possible without allowing useful-looking side work to displace the core pipeline.

## Main Pipeline

M1 Manifest loading → **DONE**

M2 Record discovery/index → **DONE**

M3 Integrity validation → **DONE** — duplicate IDs + broken references + required files

M4 Reporting contract → **DONE** — console + JSON + stable exit codes

M5 Security integration → **CURRENT / CI READY** — adapter and verification workflow implemented; repository identity/publish + successful real run required

M6 Dogfood → run against aeos-cli itself, fix real friction, and close accepted MVP gap REQ-CLI-006 (STATUS staleness)

M7 SEO Engine pilot → apply to the SEO Intelligence Engine and measure usefulness/noise

M8 v0.1 Release → only after pilot evidence

## Priority Rule
Work is prioritized in this order:

1. Blocks the current milestone.
2. Required for the next milestone.
3. Security/correctness issue that makes current work unsafe or misleading.
4. Evidence-producing work needed to validate AEOS.
5. Everything else.

## Branch Gate
Before opening a side branch, answer:

- Does this unblock M2–M8?
- Does this fix a security or correctness risk in the current implementation?
- Does this produce evidence required for a pending architecture decision?

If all answers are no, record it as backlog/debt and return to the critical path.

## Explicitly Deferred
Until v0.1 evidence justifies them:

- dashboard or GUI;
- cloud backend;
- database;
- plugin architecture;
- AI inside the deterministic validator;
- architecture inference;
- historical trend analytics;
- custom security scanner;
- generalized YAML implementation;
- optimization without measured performance problems.

## Stop Conditions
Pause the pipeline only for:

- a security flaw that makes continued development unsafe;
- evidence that the current architecture is fundamentally wrong;
- a blocker that prevents validating the next milestone;
- a requirement contradiction that would cause substantial rework.

Everything else is scheduled behind the current critical path.
