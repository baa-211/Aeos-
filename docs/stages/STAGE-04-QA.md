---
aeos_record: STAGE
id: STAGE-04-QA
sequence: 4
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-04-QA — QA

## Purpose
Prove the change behaves as designed, and prove the system still behaves as it did. QA absorbs what earlier vocabularies called Verify and Review.

## Principles
1. Every validator defect adds a regression test. A fix without one is a fix that will be undone.
2. A test that cannot fail proves nothing. Verify the negative case.
3. Determinism is testable. Assert it rather than assuming it.
4. Coverage is a signal, not a goal. High coverage of trivial paths is not assurance.
5. Reproduce before fixing. A defect you cannot demonstrate is a defect you cannot confirm you fixed.

## Protocol
1. Reproduce the defect or demonstrate the new behavior before changing code.
2. Write the failing test first where practical.
3. Verify the test fails without the fix and passes with it.
4. Run the full suite uncached, not only the affected package.
5. Test the boundary cases: empty, absent, malformed, outside expected range.
6. Confirm the negative control — that a clean input still passes.

## Entry Criteria
Build gate passed.

## Exit Gate
- `go test ./...` passes uncached across all packages.
- Each defect fixed in this change has a regression test that fails without the fix.
- Boundary and negative cases are covered.
- A clean control case still passes, confirming the test can distinguish states.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Verify the fixture before trusting the result
A planted-secret test initially reported no findings, which looked like a scanner failure. The planted values were the AWS documentation example keys, which Gitleaks correctly allowlists. The tool was right and the test was wrong. Re-testing with realistically shaped credentials confirmed detection. A test fixture that is itself invalid produces a false defect report, which costs as much trust as a false pass.

### 2026-08-26 — Assert determinism directly
Report determinism was proven by checking the same project from two different filesystem locations and comparing SHA-256 digests of the output. Byte-identical output is a testable property; "should be deterministic" is not.
