package records

import (
	"errors"
	"os"
	"path/filepath"
	"testing"
)

func writeFile(t *testing.T, path, content string) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
}

func TestDiscoverRecords(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "PROJECT.md"), `---
aeos_record: PROJECT
project_id: TEST
status: development
---
# Project
`)
	writeFile(t, filepath.Join(root, "STATUS.md"), `---
aeos_record: STATUS
updated: 2026-08-15
---
# Status
`)
	writeFile(t, filepath.Join(root, "docs", "adr", "ADR-001-test.md"), `---
aeos_record: ADR
id: ADR-001
status: accepted
related_requirements:
  - REQ-001
---
# ADR
`)
	writeFile(t, filepath.Join(root, "docs", "architecture", "overview.md"), "# Architecture\n")

	got, err := Discover(root)
	if err != nil {
		t.Fatalf("Discover() error = %v", err)
	}
	if len(got) != 3 {
		t.Fatalf("len(records) = %d, want 3: %#v", len(got), got)
	}
	if got[0].ID != "TEST" || got[1].ID != "STATUS" || got[2].ID != "ADR-001" {
		t.Fatalf("unexpected records: %#v", got)
	}
	if got[2].Path != "docs/adr/ADR-001-test.md" {
		t.Fatalf("record path = %q", got[2].Path)
	}
	if len(got[2].References) != 1 || got[2].References[0] != "REQ-001" {
		t.Fatalf("record references = %#v, want [REQ-001]", got[2].References)
	}
}

func TestDiscoverRejectsUnclosedFrontmatter(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "PROJECT.md"), `---
aeos_record: PROJECT
project_id: TEST
`)

	_, err := Discover(root)
	if !errors.Is(err, ErrInvalidFrontmatter) {
		t.Fatalf("error = %v, want ErrInvalidFrontmatter", err)
	}
}

func TestDiscoverSkipsSymlink(t *testing.T) {
	root := t.TempDir()
	outside := filepath.Join(t.TempDir(), "ADR-999.md")
	writeFile(t, outside, `---
aeos_record: ADR
id: ADR-999
---
`)
	docs := filepath.Join(root, "docs")
	if err := os.MkdirAll(docs, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(outside, filepath.Join(docs, "linked.md")); err != nil {
		t.Skipf("symlink unavailable: %v", err)
	}

	got, err := Discover(root)
	if err != nil {
		t.Fatalf("Discover() error = %v", err)
	}
	if len(got) != 0 {
		t.Fatalf("len(records) = %d, want 0", len(got))
	}
}
