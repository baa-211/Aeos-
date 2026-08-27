---
aeos_record: ADR
id: ADR-001
status: accepted
impact: high
created: 2026-08-15
updated: 2026-08-16
---
# ADR-001 — AEOS CLI Implementation Language

## Decision
Implement the deterministic AEOS validator core in Go while keeping AEOS project records language-neutral through Markdown, YAML, JSON, Git, and CLI interfaces.

## Why
Go currently gives the best balance of standalone distribution, deterministic behavior, CI suitability, maintainability, and low operational complexity for a repository validator.

## Alternatives
TypeScript/Node.js and Python were considered. Both remain viable for different future layers, especially a Python intelligence/analytics layer if evidence justifies it.

## Reversal Trigger
Reconsider Go if implementation evidence shows materially higher total complexity, unacceptable agent/developer friction, or a fundamental shift away from a deterministic local validator.
