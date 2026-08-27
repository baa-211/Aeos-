package secrets

import (
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"
)

func fakeGitleaks(t *testing.T, body string) string {
	t.Helper()
	if runtime.GOOS == "windows" {
		t.Skip("shell fixture is Unix-only")
	}
	path := filepath.Join(t.TempDir(), "gitleaks")
	if err := os.WriteFile(path, []byte("#!/bin/sh\n"+body), 0o700); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestScanNoLeaks(t *testing.T) {
	tool := fakeGitleaks(t, `
if [ "$1" = "version" ]; then echo "8.30.0"; exit 0; fi
report=""
while [ $# -gt 0 ]; do
  if [ "$1" = "--report-path" ]; then report="$2"; shift 2; continue; fi
  shift
done
echo '[]' > "$report"
exit 0
`)
	got, err := Scan(t.TempDir(), tool)
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 0 {
		t.Fatalf("findings=%#v", got)
	}
}

func TestScanLeakRedactsSecretFromAEOSFinding(t *testing.T) {
	tool := fakeGitleaks(t, `
if [ "$1" = "version" ]; then echo "gitleaks version 8.30.0"; exit 0; fi
report=""
while [ $# -gt 0 ]; do
  if [ "$1" = "--report-path" ]; then report="$2"; shift 2; continue; fi
  shift
done
cat > "$report" <<'JSON'
[{"Description":"GitHub PAT","File":"config.txt","StartLine":7,"RuleID":"github-pat","Secret":"TOPSECRET"}]
JSON
exit 10
`)
	got, err := Scan(t.TempDir(), tool)
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 || got[0].Rule != "AEOS-SEC-001" || got[0].Paths[0] != "config.txt:7" {
		t.Fatalf("findings=%#v", got)
	}
	if got[0].Message == "TOPSECRET" {
		t.Fatal("secret leaked into AEOS output")
	}
}

func TestScanRejectsUnsupportedVersion(t *testing.T) {
	tool := fakeGitleaks(t, `if [ "$1" = "version" ]; then echo "8.30.1"; exit 0; fi`)
	_, err := Scan(t.TempDir(), tool)
	if !errors.Is(err, ErrUnsupportedVersion) {
		t.Fatalf("err=%v", err)
	}
}

func TestScanGitRepositoryRunsDirAndGitModes(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("shell fixture is Unix-only")
	}
	root := t.TempDir()
	cmd := exec.Command("git", "init", root)
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("git init: %v: %s", err, out)
	}
	logPath := filepath.Join(t.TempDir(), "calls.log")
	tool := fakeGitleaks(t, `
if [ "$1" = "version" ]; then echo "8.30.0"; exit 0; fi
printf '%s\n' "$1" >> "`+logPath+`"
report=""
while [ $# -gt 0 ]; do
  if [ "$1" = "--report-path" ]; then report="$2"; shift 2; continue; fi
  shift
done
echo '[]' > "$report"
exit 0
`)
	if _, err := Scan(root, tool); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(logPath)
	if err != nil {
		t.Fatal(err)
	}
	got := string(data)
	if got != "dir\ngit\n" {
		t.Fatalf("scan modes = %q, want dir then git", got)
	}
}
