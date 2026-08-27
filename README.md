# AEOS CLI

`aeos` is the deterministic repository validator for the A++ Engineering Operating System.

## Status

Pilot. Current milestone: M1 — manifest loading and validation.

## Run

```bash
go test ./...
go vet ./...
go build -o aeos ./cmd/aeos
./aeos check
```

The current parser intentionally supports only the AEOS v0.1 manifest subset needed by M1. It is not a general-purpose YAML parser.
