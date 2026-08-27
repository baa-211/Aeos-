---
aeos_record: ADR
id: ADR-002
status: accepted
impact: medium
created: 2026-08-15
updated: 2026-08-15
---

# ADR-002 — M1 Manifest Parser Strategy

## Context
The build environment could not reach the Go package registry, so a mature YAML dependency could not be fetched during M1 implementation.

## Decision
For M1 only, implement a deliberately constrained, dependency-free parser for the small AEOS manifest subset required to identify AEOS and project metadata.

## Why
This allows deterministic progress without pretending the implementation is a complete YAML parser or introducing an unverified vendored dependency.

## Constraints
Unsupported YAML constructs are rejected. Unknown top-level sections may be ignored until their schemas are implemented.

## Risk
Maintaining a custom general-purpose YAML parser would be a bad engineering decision.

## Reversal Trigger
Adopt a mature parser when full manifest semantics require it and dependency acquisition is available and security-reviewed.
