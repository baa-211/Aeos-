# Changelog

Human-readable release history. The authoritative version is `project.version` in `aeos.yaml`; see `VERSIONING.md`. Engineering detail lives in `docs/changes/`.

`0.1.0` is reserved for the M8 release and will not be claimed before real pilot evidence exists.

## [0.0.10] — 2026-08-31

Milestone: M6 (Dogfood) in progress.

### Changed
- **Stage orbs moved to the front rim of the platform.** They previously arced upward behind the globe, where the sphere occluded them and made them awkward to hit. Every orb now sits entirely below the globe's lower edge, verified geometrically at six viewport sizes.
- **Each stage carries a glyph and its own voxel texture**, so the eight are distinguishable by silhouette and colour before any label is read: a funnel for Intake, dividers for Design, stacked plates for Build, a lens for QA, a shield for Security, scales for Compliance, an ascending mark for Release, a scroll for Report. Textures differ too — latitude bands, ordered lattice, coarse plates, packed shell, spiral, and broken shards.
- Orbs are seated with a cast shadow so they rest on the rim rather than float, and each carries a lit core so glyphs read against the shell.
- **Narrow viewports use two rows of four** rather than eight on one arc. Shrinking eight orbs to fit a phone would have made them smaller than a fingertip.
- Word labels are hidden below 700px except for the hovered or declared stage; the glyph and number carry identification there.
- Hit radius tightened to the orb itself, so labels are no longer clickable dead zones.

## [0.0.9] — 2026-08-31

Milestone: M6 (Dogfood) in progress.

### Added
- **Command interface** (`preview/command.html`). Voxel globe rendering the engine, whose first voxels are the project's real records. Cursor-reactive surface, eight interactive stage orbs generated from STAGE records, per-stage panels showing protocol, principles, exit gate and memory, and drag-and-drop Intake that proposes a classification without reading, moving or writing anything.
- **`pipeline.current_stage`** in the manifest, surfaced in the report. Declarative: AEOS reports what a project claims about its position, and never infers it. Report schema `0.2` → `0.3`.

### Fixed
- The earlier preview could not load its data when opened directly, because browsers block fetch on the `file://` origin. Report and stage data are now embedded at build time.

## [0.0.8] — 2026-08-31

Milestone: M6 (Dogfood) in progress. M1–M5 complete.

### Added
- **Record index in the JSON report.** The report now carries every discovered record with its type, id, status, project-relative path and references. Consumers such as the preview interface can render the record graph from AEOS output instead of parsing the repository themselves and becoming a second source of truth. Report schema `0.1` → `0.2`.
- **`AEOS-VER-001` version consistency check.** Any record whose frontmatter version disagrees with `project.version` in the manifest is now a blocking error. Written because three files in this repository were simultaneously claiming three different versions.
- `VERSIONING.md` and this changelog.

### Fixed
- **Version drift resolved.** `aeos.yaml` (0.0.1), `PROJECT.md` (0.0.7) and `STATUS.md` (0.1.1-rc) now all declare 0.0.8.

### Changed
- Report schema `0.2` adds a `records` array. Additive only; existing fields are unchanged.

## [0.0.7] — 2026-08-31

Milestone: M5 (Security integration) **closed** with live CI evidence — GitHub Actions run #4, all 14 steps green.

### Security
- **Silent security downgrade fixed (critical).** Unknown top-level sections in `aeos.yaml` were silently ignored. Misspelling `security` as `securty` disabled secret scanning entirely while AEOS reported `PASS` with exit code 0 and a live private key present in the directory. The parser now rejects unknown sections with exit code 4 and suggests the intended one. Permissive parsing of its own configuration is a vulnerability in a security tool.
- **CI now proves blocking, not detection.** The workflow asserts exit code 3 and an `AEOS-SEC-001` finding against a private key generated at runtime. A regression where the scanner worked but AEOS dropped the finding previously produced a green build.

### Fixed
- **Scanner path normalization.** `gitleaks dir` reported absolute paths while `gitleaks git` reported relative ones. Deduplication could not match them, so one secret present in both working tree and history counted as two criticals; and machine-specific absolute paths reached the JSON report, breaking the deterministic reporting contract. All paths are now normalized to project-relative form at the adapter boundary.

### Added
- Canonical eight-stage delivery pipeline (`ADR-004`) reconciling four competing vocabularies, with `docs/stages/` records carrying protocols, principles, exit gates and append-only memory.
- MIT `LICENSE`. The repository was briefly public without one, which grants nobody any rights.
- `internal/findings` test coverage, 0% → 95.2%.

### Changed
- Go module path migrated to `github.com/baa-211/Aeos-` to match the repository. Accepted consequence: Go case-encodes it as `github.com/baa-211/!aeos-` in module cache and proxy paths.
- CI reads the Go toolchain from `go-version-file: go.mod` rather than a hardcoded patch version that could not be verified to exist.
- `.env.example` documents `AEOS_GITLEAKS_PATH`, which it previously claimed did not exist.

## [0.0.1] — 2026-08-15 to 2026-08-26

Initial development. M1 manifest loading, M2 record discovery, M3 integrity validation, M4 reporting contract with stable exit codes, and the M5 Gitleaks adapter. Not published.
