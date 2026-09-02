#!/usr/bin/env bash
# Regenerate the preview and serve it locally.
#
# The preview is strictly read-only. It renders report.json and computes
# nothing; regenerating the report is the only way its contents change.
# Data is embedded into command.html so the file also works when opened
# directly, without a server.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "Building aeos..."
go build -trimpath -o ./bin/aeos ./cmd/aeos

echo "Running check..."
# exit 2 and 3 are real findings, not script failures: the preview must be
# able to display a failing project.
set +e
./bin/aeos check --format json > preview/report.json
rc=$?
set -e
case "$rc" in 0|2|3) ;; *) echo "aeos check could not produce a report (exit $rc)"; exit "$rc";; esac

echo "Embedding report and stage records..."
python3 preview/embed.py

result=$(python3 -c "import json;print(json.load(open('preview/report.json'))['result'])")
echo "Report: result=$result, aeos exit=$rc"
echo
echo
echo "Starting the local server. With it running, notes and decision"
echo "resolutions write straight into their records. Opened as a plain file"
echo "instead, the interface falls back to the clipboard and says so."
echo
exec python3 preview/serve.py
