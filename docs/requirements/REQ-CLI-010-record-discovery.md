---
aeos_record: REQ
id: REQ-CLI-010
status: implemented
priority: critical
created: 2026-08-15
updated: 2026-08-15
---

# REQ-CLI-010 — Discover AEOS Records

## Requirement
The CLI shall discover AEOS Markdown records from the project root and `docs/` tree without executing repository content or following symlinked content.

## Acceptance Criteria

- [x] `PROJECT.md` and `STATUS.md` are inspected when present.
- [x] Markdown files under `docs/` are inspected recursively.
- [x] Files without AEOS frontmatter are ignored.
- [x] AEOS record type, ID, status, and relative path are normalized.
- [x] Symlinked files are not followed in M2.
- [x] Invalid/unclosed AEOS frontmatter produces a clear error.
- [x] Discovery behavior has unit tests.

## Non-Requirements

M2 does not validate duplicate IDs or cross-record references. Those belong to M3.
