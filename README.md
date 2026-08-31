# AEOS CLI

`aeos` is the deterministic repository validator for the A++ Engineering Operating System.

## Status

Pilot. Current milestone: M6 — dogfooding.

M1–M5 complete. Secret scanning is verified in CI against pinned Gitleaks 8.30.0: the workflow proves AEOS *blocks* on a planted secret rather than merely proving the scanner detects one.

## Run

```bash
go test ./...
go vet ./...
go build -o aeos ./cmd/aeos
./aeos check
```

The current parser intentionally supports only the AEOS v0.1 manifest subset.  It is not a general-purpose YAML parser.
