# Architecture Overview

Current M2 flow:

`aeos check` → working directory → `config.Load` → constrained manifest parser → `records.Discover` → normalized record inventory → console result → exit code.

## Current Components

- `config`: load the minimal AEOS manifest required by the active milestones.
- `records`: discover and normalize AEOS Markdown records.
- `cmd/aeos`: command orchestration and user-facing exit behavior.

## Current Trust Boundary

Repository files are untrusted input.

The validator does not execute repository configuration or Markdown. M2 skips symlinked content rather than following it outside the intended tree.

## Critical Path

M3 adds integrity validation on top of the record inventory. M4 then stabilizes reporting and exit-code contracts.

No network, database, AI, plugin system, or external command execution is required for M2.
