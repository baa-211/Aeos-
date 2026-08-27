# Testing Strategy

Current checks:
- unit tests for valid manifest parsing;
- missing manifest handling;
- malformed input handling;
- missing required fields;
- unsupported construct rejection;
- `go vet ./...`;
- dogfood execution via `./aeos check`.

Every validator defect should normally add a regression test.
