---
aeos_record: STAGE
id: STAGE-06-COMPLIANCE
sequence: 6
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-06-COMPLIANCE — Compliance & Accessibility

## Purpose
Establish that the change is lawful to distribute and usable by people who do not interact the way its authors do. This stage absorbs what an earlier vocabulary called Approve.

## Principles
1. Unlicensed is not permissive. Code published without a license grants nobody any rights.
2. Accessibility is a correctness property, not a polish task. An interface unusable by keyboard is broken, not unrefined.
3. Colour never carries meaning alone.
4. State must be honest in every mode. A status that reads OPTIMAL when the truth is UNKNOWN fails here as surely as in Security.
5. Attribution obligations of dependencies are inherited, not optional.

## Protocol
1. Confirm a license file exists and matches the intended terms.
2. Review dependency licenses for compatibility and attribution obligations.
3. For any interface: verify full keyboard operability and visible focus.
4. Verify contrast meets WCAG 2.2 AA and that no state is signalled by colour alone.
5. Verify semantic structure: labels bound to controls, live regions for dynamic messages, correct heading order.
6. Verify reduced-motion preferences are respected.
7. Confirm no personal data is collected or transmitted without an explicit recorded decision.

## Entry Criteria
Security gate passed.

## Exit Gate
- A license file is present and correct; dependency licenses are compatible.
- Every interactive element is reachable and operable by keyboard with visible focus.
- Contrast meets WCAG 2.2 AA; no meaning depends on colour alone.
- Dynamic status changes are announced to assistive technology.
- Reduced-motion preferences are honoured.
- Data handling matches the declared classification.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Published without a license for one commit
The repository was made public before a license file existed, which meant that for a short window nobody could legally use, fork or contribute to it. Caught during pre-publish review and corrected with MIT before the first push. License presence belongs on the publish checklist, not in a follow-up commit.

### 2026-08-26 — A green status badge is an accessibility and honesty failure at once
The visual direction placed a single `OPTIMAL` indicator in the interface. It communicates state by colour alone, and it collapses unknown and healthy into the same signal. The prototype replaced it with explicit textual states: `VAULT LOCKED`, `SESSION NONE`, `LAST CHECK UNKNOWN`.
