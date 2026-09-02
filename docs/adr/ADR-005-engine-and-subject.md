---
aeos_record: ADR
id: ADR-005
status: accepted
created: 2026-09-01
updated: 2026-09-01
---

# ADR-005 — The Engine and the Subject Are Different Things

## Context

AEOS exists to help build and redesign other people's software: applications, websites, services. The project it is pointed at is the **subject**. AEOS itself is the **engine**.

During M6 the engine is pointed at itself, which is the entire purpose of dogfooding. That produced a confusion the command interface made worse rather than clearer: its Output window offered to show "what the engine produced", and listed `docs/stages/STAGE-03-BUILD.md`, `docs/decisions/DEC-004.md` and similar.

Those are the engine's own scaffolding. They are not a work product. Nobody using AEOS on a website wants to see AEOS's stage records in a window describing what their project has produced — and worse, someone new to the tool would reasonably conclude those files are something AEOS creates for them.

The interface was not wrong about the data. It was wrong about what the data means, which is a harder error to notice and a more expensive one to leave.

## Decision

**The interface always describes the subject, never itself.**

Windows are named and worded in terms of the project under examination. The project's own name and identifier are shown rather than the word "engine". A window that lists records describes them as that project's records.

**Self-examination is declared, not hidden.** When the subject is AEOS itself — detected from the project identifier in the report — the interface says so plainly. It states that these records are the engine's own scaffolding, that this is a temporary condition of dogfooding, and that it ends when AEOS is used on something other than itself.

**The engine's scaffolding is a placeholder.** Every stage record, decision record and change entry currently visible is AEOS reasoning about its own construction. When the tool is pointed at a real subject, that subject supplies its own. None of the engine's records are examples of what a user's project should contain, and the interface must not imply they are.

## Consequences

The distinction has to be carried in wording rather than in filtering. There is no rule that separates engine files from subject files in the general case, because when AEOS examines a website every record it finds belongs to that website. The only case needing special handling is the self-referential one, and the honest handling is to name it rather than to hide it.

This constrains future interface work: a window may not describe AEOS's activity as though it were the subject's, and a count of records must be attributed to a named project.

`STATUS.md` records that the engine's own scaffolding is placeholder content for the duration of M6 and M7, and that M8 is the point at which AEOS is expected to be examining something other than itself.

## Alternatives Considered

**Filter engine files out of the interface.** Rejected. There is no general rule to filter on, and the filter would be wrong the moment AEOS examines a project that also has a `docs/stages/` directory. It would also hide the dogfooding rather than making it legible.

**Leave the wording and rely on people understanding the context.** Rejected. It already confused the project owner, who built the thing.
