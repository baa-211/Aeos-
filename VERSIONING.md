# Versioning and Release Discipline

## Why this document exists

On 2026-08-26 three files in this repository simultaneously declared three different project versions: `aeos.yaml` said `0.0.1`, `PROJECT.md` said `0.0.7`, `STATUS.md` said `0.1.1-rc`. There were no Git tags and no changelog. Nothing detected the drift because nothing was looking for it.

Not knowing which version is current is a trust failure, not a tidiness problem. This document defines the rule; `AEOS-VER-001` enforces it.

## Single source of truth

**`aeos.yaml` → `project.version` is authoritative.** It is machine-read, it is the file AEOS is pointed at, and it is the only version any tool should parse.

Every AEOS record that declares a `version` in its frontmatter must match it. `aeos check` fails with `AEOS-VER-001` and exit code 2 when they disagree. Version drift can no longer reach `main`.

Records that declare no version are unaffected. Silence is not disagreement.

## Numbering

`MAJOR.MINOR.PATCH`, incremented as follows while the project is pre-release:

| Change | Increment | Example |
|---|---|---|
| Defect fix, docs, tests, records | PATCH | 0.0.7 → 0.0.8 |
| New validator rule or CLI capability | PATCH until v0.1 | 0.0.8 → 0.0.9 |
| Milestone closure with evidence | PATCH, and a Git tag | 0.0.8 → 0.0.9 |
| Report schema change | see below | |

`0.0.x` covers M1 through M7. **`0.1.0` is reserved for the M8 release** and may not be claimed before real pilot evidence exists, per `ROADMAP.md`. Claiming a release number before the evidence supporting it is the same class of error as reporting PASS on an unknown state.

Pre-release suffixes such as `-rc` are not used. A version either has evidence behind it or it does not.

## The report schema versions separately

`reporting.SchemaVersion` describes the JSON report contract, not the tool. Consumers must gate on the schema version, never on the project version.

- Additive field → PATCH on schema (consumers unaffected)
- Field removed, renamed, or its meaning changed → MINOR on schema (breaking)

Current schema: `0.2`, which added the `records` index.

## Release procedure

1. Confirm every stage gate in `docs/stages/` has passed.
2. Set `project.version` in `aeos.yaml`; align every versioned record.
3. Run `aeos check` — `AEOS-VER-001` must be clean.
4. Add a `CHANGELOG.md` entry under the new version.
5. Commit, push, and confirm CI passes on the published repository.
6. Tag the commit: `git tag -a v0.0.8 -m "..."` and push the tag.
7. Only then update `STATUS.md` to describe the version as current.

Tags are applied to commits that have already passed CI, never in anticipation.

## Branch discipline

`main` is always the latest verified state. It is the only long-lived branch.

Working branches are short-lived, named `type/short-description`, and are merged and deleted promptly. A branch that has diverged from `main` in both directions is a source of ambiguity about which version is current; it is either merged or deleted, never left.

Before deleting any branch, its unique content is inspected and either salvaged into `main` or explicitly recorded as discarded.

## What "the latest version" means

Three things must agree, and it is an error if they do not:

1. `main` at its newest commit
2. The newest Git tag
3. `project.version` in `aeos.yaml` on `main`

If you need to know what is current, read `aeos.yaml` on `main`. Everything else derives from it.
