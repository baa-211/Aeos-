#!/usr/bin/env bash
# Regenerate the preview's data and serve it locally.
#
# The preview is strictly read-only: it renders report.json and computes
# nothing itself. Regenerating the report is the only way its contents change.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "Building aeos..."
go build -trimpath -o ./bin/aeos ./cmd/aeos

echo "Running check..."
# exit 2 and 3 are real findings, not script failures: the preview should be
# able to display a failing project.
set +e
./bin/aeos check --format json > preview/report.json
rc=$?
set -e
case "$rc" in
  0|2|3) ;;
  *) echo "aeos check failed to produce a report (exit $rc)"; exit "$rc" ;;
esac

result=$(python3 -c "import json;print(json.load(open('preview/report.json'))['result'])" 2>/dev/null || echo UNKNOWN)
echo "Report written: preview/report.json (result: $result, aeos exit: $rc)"
echo
echo "Serving at http://localhost:8000/preview/"
echo "Press Ctrl-C to stop."
exec python3 -m http.server 8000
