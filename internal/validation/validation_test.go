package validation

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/baa-211/Aeos-/internal/config"
	"github.com/baa-211/Aeos-/internal/records"
)

func manifest(level string) config.Manifest {
	var m config.Manifest
	m.Project.Level = level
	return m
}

func TestDuplicateIDs(t *testing.T) {
	recs := []records.Record{{ID: "REQ-001", Path: "a.md"}, {ID: "REQ-001", Path: "b.md"}}
	got := duplicateIDs(recs)
	if len(got) != 1 || got[0].Rule != "AEOS-DOC-005" {
		t.Fatalf("unexpected findings: %#v", got)
	}
}

func TestBrokenReferences(t *testing.T) {
	recs := []records.Record{{ID: "ADR-001", Path: "adr.md", References: []string{"REQ-404"}}}
	got := brokenReferences(recs)
	if len(got) != 1 || got[0].Rule != "AEOS-REF-001" {
		t.Fatalf("unexpected findings: %#v", got)
	}
}

func TestRequiredFilesLevelB(t *testing.T) {
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "PROJECT.md"), []byte("x"), 0o600); err != nil {
		t.Fatal(err)
	}
	got := requiredFiles(root, manifest("B"))
	if len(got) != 1 || got[0].Rule != "AEOS-DOC-002" {
		t.Fatalf("unexpected findings: %#v", got)
	}
}
