package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/baa-211/Aeos-/internal/reporting"
)

func write(t *testing.T, root, name, content string) {
	t.Helper()
	path := filepath.Join(root, name)
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
}

func validManifest() string {
	return `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "TEST"
  name: "test"
  version: "0.0.1"
  stage: "development"
  level: "A"
  security_level: "S1"
`
}

func TestCheckJSONContract(t *testing.T) {
	root := t.TempDir()
	write(t, root, "aeos.yaml", validManifest())
	old, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	defer os.Chdir(old)
	if err := os.Chdir(root); err != nil {
		t.Fatal(err)
	}

	var out, errOut bytes.Buffer
	code := run([]string{"check", "--format", "json"}, &out, &errOut)
	if code != exitOK {
		t.Fatalf("exit=%d stderr=%s stdout=%s", code, errOut.String(), out.String())
	}
	var r reporting.Report
	if err := json.Unmarshal(out.Bytes(), &r); err != nil {
		t.Fatalf("invalid json: %v: %s", err, out.String())
	}
	if r.SchemaVersion != reporting.SchemaVersion || r.Project.ID != "TEST" || r.Result != "PASS" {
		t.Fatalf("unexpected report: %#v", r)
	}
}

func TestMalformedFrontmatterUsesFindingModel(t *testing.T) {
	root := t.TempDir()
	write(t, root, "aeos.yaml", validManifest())
	write(t, root, "PROJECT.md", "---\naeos_record: PROJECT\nproject_id TEST\n---\n")
	old, _ := os.Getwd()
	defer os.Chdir(old)
	_ = os.Chdir(root)
	var out, errOut bytes.Buffer
	code := run([]string{"check", "--format", "json"}, &out, &errOut)
	if code != exitConfiguration {
		t.Fatalf("exit=%d want %d", code, exitConfiguration)
	}
	var r reporting.Report
	if err := json.Unmarshal(out.Bytes(), &r); err != nil {
		t.Fatal(err)
	}
	if len(r.Findings) != 1 || r.Findings[0].Rule != "AEOS-DOC-006" {
		t.Fatalf("unexpected report: %#v", r)
	}
}

func TestBadArgs(t *testing.T) {
	var out, errOut bytes.Buffer
	if code := run([]string{"nope"}, &out, &errOut); code != exitConfiguration {
		t.Fatalf("exit=%d", code)
	}
}

func TestRequiredSecretScannerUnavailableIsBlockingFinding(t *testing.T) {
	root := t.TempDir()
	manifest := validManifest() + "security:\n  secret_scan:\n    required: true\n"
	write(t, root, "aeos.yaml", manifest)
	old, _ := os.Getwd()
	defer os.Chdir(old)
	_ = os.Chdir(root)
	t.Setenv("AEOS_GITLEAKS_PATH", filepath.Join(root, "missing-gitleaks"))
	var out, errOut bytes.Buffer
	code := run([]string{"check", "--format", "json"}, &out, &errOut)
	if code != exitValidation {
		t.Fatalf("exit=%d stdout=%s stderr=%s", code, out.String(), errOut.String())
	}
	var r reporting.Report
	if err := json.Unmarshal(out.Bytes(), &r); err != nil {
		t.Fatal(err)
	}
	if len(r.Findings) != 1 || r.Findings[0].Rule != "AEOS-SEC-010" {
		t.Fatalf("unexpected report: %#v", r)
	}
}
