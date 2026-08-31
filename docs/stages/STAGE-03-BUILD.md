---
aeos_record: STAGE
id: STAGE-03-BUILD
sequence: 3
status: active
created: 2026-08-26
updated: 2026-08-26
adrs: "ADR-004"
---

# STAGE-03-BUILD — Build

## Purpose
Implement the accepted design in the smallest reviewable increments that keep the system working.

## Principles
1. Small reviewable changes over large correct ones. A change nobody can review is not trustworthy regardless of its quality.
2. Do not silently add dependencies.
3. Configuration is data, never executable code.
4. AI-generated code is not trusted until reviewed and tested.
5. Leave the build green. A broken main branch blocks everyone.

## Protocol
1. Inspect the code being changed before editing it.
2. Implement the smallest increment that is independently verifiable.
3. Keep formatting mechanical: `gofmt` decides, not preference.
4. Run build and vet continuously, not once at the end.
5. Write the comment that explains why, where the reason is not evident from the code.
6. Update affected records in the same change, not a follow-up.

## Entry Criteria
Design is recorded and its exit gate passed.

## Exit Gate
- `gofmt` reports no files needing formatting.
- `go build ./...` succeeds.
- `go vet ./...` is clean.
- No new dependency was added without a recorded decision.
- Affected AEOS records were updated in the same change.

## Memory
Append-only. Each entry is dated and never rewritten. Recording why a decision was made matters more than recording that it was made.

### 2026-08-26 — Normalize at the adapter boundary, not at the point of use
Two scan modes reported paths in incompatible forms. The fix belonged in the secrets adapter, where external output first enters the system, rather than in the reporting layer where the symptom appeared. Normalizing at the boundary meant one change fixed both the duplicate-findings defect and the report determinism defect. Correcting at the symptom would have fixed one and hidden the other.
