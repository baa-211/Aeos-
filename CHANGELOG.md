# Changelog

Human-readable release history. The authoritative version is `project.version` in `aeos.yaml`; see `VERSIONING.md`. Engineering detail lives in `docs/changes/`.

`0.1.0` is reserved for the M8 release and will not be claimed before real pilot evidence exists.

## [0.0.17] — 2026-09-01

Milestone: M6 (Dogfood) in progress.

### Added
- **Intake window.** A standing log of every file presented to the engine, with its classification and when it arrived. A second tab lists what the engine actually holds — the records `aeos check` discovered. The window states the difference plainly rather than blurring it: a browser is handed a dropped file's name and size and nothing else, so a drop is a reference, never a transfer. The "held from drops" figure is zero and says so.
- **Output window.** What the engine has produced: the report with its schema version, result and findings, and a second tab listing files written but not yet committed. That list is read from git through the local server, so it is repository truth rather than the interface's account of its own actions. With no server it says so instead of showing an empty list.
- **A dock** in the lower right with live counts, and `I` and `O` shortcuts.

## [0.0.16] — 2026-09-01

Milestone: M6 (Dogfood) in progress.

### Removed
- **"Copy question only".** It copied back the exact text the person had just typed, from a box they could select. It existed because it was easy to add, not because anyone needed it.

### Changed
- **"Copy full brief" → "Copy with context".** The old name described a size. The new one names the reason to press it — the question leaves with the stage's purpose, principles, protocol, exit gate, open decisions and current findings attached.
- **"Copy for record" is gone as a label.** One generic fallback string had been applied to two different buttons. Each control now names its own action in both modes: Save to record / Copy entry, and Resolve in record / Copy resolution.
- **"Discard drafts" is hidden when there is nothing to discard.** With the server running, saving writes straight through and no draft is ever created, so the button was permanently dead.
- The mode line now says what the button will do rather than describing the connection.

## [0.0.15] — 2026-09-01

Milestone: M6 (Dogfood) in progress.

### Added
- **Notes and decisions write straight into their records.** `preview/serve.py` runs alongside the interface and appends a note under `## Memory`, or writes a decision resolution and flips its status, returning the diff. The clipboard step is gone. Opened as a plain file with no server, the interface falls back to the clipboard and states which mode it is in.
- **Windows are tabbed.** Decisions, Notes, Ask and Method. A window opens on Decisions when something is waiting there, and remembers the tab you were last on. Reference material — purpose, principles, protocol, exit gate — moved to Method, out of the way of the work.
- Committing from the interface, as a separate deliberate action with the diff shown first.

### Changed
- `preview/build.sh` launches the write server rather than a static one.
- Decisions now require a written reason before they can be resolved. A choice without its reasoning becomes folklore.
- `DEC-001` resolved: the clipboard flow was rejected by the project owner.

### Security
- The write server binds to the loopback interface only, writes exclusively to Markdown records that already exist under `docs/`, cannot create or delete files, refuses symlinks, and appends under a named heading rather than rewriting a file. Git is never touched implicitly. The validator is never invoked from the server, so the interface cannot appear to certify its own edits. Every refusal path was tested.

## [0.0.14] — 2026-08-31

Milestone: M6 (Dogfood) in progress.

### Fixed
- **Windows could not be closed or collapsed.** The drag handler on the title bar called `preventDefault` on pointerdown, which suppressed the click event for the buttons nested inside it. Both controls were silently dead. The handler now ignores pointer events originating on interactive descendants.

### Added
- **Closing a window loses nothing.** Window position, size and collapsed state persist per window and return on reopen. Drafted comments, decision choices and half-written text in the comment and prompt fields all survive being closed. Closing is a display action; it never advances or halts the pipeline, which moves only when `aeos check` runs and records change. The window says so.
- Draft storage routed through one helper with a shared in-memory fallback for `file://` origins where `localStorage` is unavailable.


Milestone: M6 (Dogfood) in progress.

### Added
- **`DECISION` record type.** Open questions are now records AEOS discovers, indexes and reference-checks like any other. Five seeded from real open questions in this project, one already accepted.
- **`AEOS-DEC-001`.** `aeos check` reports unresolved decisions as INFO. Never blocking — an open decision is a healthy state; an invisible one is not.
- **Decisions in the interface.** Each stage window lists the decisions waiting at that gate with their question, reasoning, options and what they block. Options are selectable, and the choice exports as a resolution block for the record.
- **Attention marks.** A stage orb with a waiting decision carries a pulsing amber count, and the HUD shows the standing total. Verified that the interface count and the CLI finding count agree.
- **Prompt composer.** Assembles your question together with the stage's purpose, principles, protocol, exit gate, open decisions and live findings into a copyable brief. Nothing is transmitted; the ROADMAP defers AI inside the validator, and a preview that called a model would be doing exactly that one layer up.


Milestone: M6 (Dogfood) in progress.

### Added
- **Windows.** Stage and intake panels are real windows: draggable by the title bar, resizable from the corner grip, collapsible to the bar, closable, and focus-stacked. Several can be open at once and cascade so a stack stays readable. Escape closes the focused window; Cmd/Ctrl-W closes all.
- **Comments per stage.** Each stage window carries a title and body field for notes on the work at that gate. Comments are drafted locally and exported as a Markdown block in the exact shape of a record memory entry, ready to paste under `## Memory` and commit. Verified to round-trip through the same parser `embed.py` uses to read records.

### Changed
- Removed the "Personal Engineering Command System" subtitle from the display.
- Number shortcuts 1–8 are suppressed while a text field has focus.


Milestone: M6 (Dogfood) in progress.

### Changed
- **Removed the light shaft.** The cone of light anchoring the globe to the floor read as a stray triangle rather than illumination. The globe is now suspended, drifting on a slow vertical cycle, and rises slightly while a drag is in flight.
- **The platform is a marble slab.** Layered stone gradient lit from the upper left, five irregular veins, fine grain, a polished rim catching the chamber light, and a cast shadow grounding it. The stone body is static, so it renders once to an offscreen canvas and is blitted per frame; only the light animates.
- **Orbits are light inlaid in the stone.** Each ring is a dark groove cut into the marble with light lying inside it — a shadowed cut, a warm bed, a bright core — rather than a line drawn on the surface. Twelve quieter radial channels run outward, and the suspended globe pools light on the stone beneath it.
- **The plate is sized from the orb layout** rather than a fixed multiple of the globe. Orbs previously overflowed the slab edge at four of five viewport sizes.

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
