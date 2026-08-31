package validation

import (
	"strings"
	"testing"

	"github.com/baa-211/Aeos-/internal/findings"
	"github.com/baa-211/Aeos-/internal/records"
)

// TestVersionDriftIsDetected reproduces the real drift found on 2026-08-26,
// when aeos.yaml, PROJECT.md and STATUS.md simultaneously declared 0.0.1,
// 0.0.7 and 0.1.1-rc with nothing detecting it.
func TestVersionDriftIsDetected(t *testing.T) {
	got := VersionConsistency("0.0.1", []records.Record{
		{Type: "PROJECT", ID: "AEOS-CLI", Version: "0.0.7", Path: "PROJECT.md"},
		{Type: "STATUS", ID: "STATUS", Version: "0.1.1-rc", Path: "STATUS.md"},
	})

	if len(got) != 2 {
		t.Fatalf("got %d findings, want 2: %#v", len(got), got)
	}
	for _, f := range got {
		if f.Rule != "AEOS-VER-001" {
			t.Fatalf("rule = %q, want AEOS-VER-001", f.Rule)
		}
		if f.Severity != findings.Error || !f.Blocking {
			t.Fatalf("version drift must block; got severity %s blocking %v", f.Severity, f.Blocking)
		}
	}
	// Deterministic order: PROJECT record sorts before STATUS by ID.
	if !strings.Contains(got[0].Message, "AEOS-CLI") {
		t.Fatalf("findings not sorted by id: %q first", got[0].Message)
	}
	if !strings.Contains(got[0].Message, "0.0.7") || !strings.Contains(got[0].Message, "0.0.1") {
		t.Fatalf("message should name both versions, got %q", got[0].Message)
	}
}

func TestMatchingVersionsProduceNoFindings(t *testing.T) {
	got := VersionConsistency("0.0.8", []records.Record{
		{Type: "PROJECT", ID: "AEOS-CLI", Version: "0.0.8", Path: "PROJECT.md"},
		{Type: "STATUS", ID: "STATUS", Version: "0.0.8", Path: "STATUS.md"},
	})
	if len(got) != 0 {
		t.Fatalf("aligned versions produced findings: %#v", got)
	}
}

// Most records carry no version. Their silence is not disagreement.
func TestUnversionedRecordsAreIgnored(t *testing.T) {
	got := VersionConsistency("0.0.8", []records.Record{
		{Type: "REQ", ID: "REQ-CLI-001", Path: "docs/requirements/a.md"},
		{Type: "ADR", ID: "ADR-004", Path: "docs/adr/d.md"},
		{Type: "STAGE", ID: "STAGE-01-INTAKE", Path: "docs/stages/s.md"},
	})
	if len(got) != 0 {
		t.Fatalf("unversioned records were treated as mismatches: %#v", got)
	}
}

// Without a manifest version there is no authority to compare against, so the
// check must stay silent rather than guess which record is correct.
func TestNoManifestVersionMeansNoCheck(t *testing.T) {
	recs := []records.Record{{Type: "PROJECT", ID: "AEOS-CLI", Version: "9.9.9", Path: "PROJECT.md"}}
	if got := VersionConsistency("", recs); len(got) != 0 {
		t.Fatalf("check ran without an authoritative version: %#v", got)
	}
	if got := VersionConsistency("   ", recs); len(got) != 0 {
		t.Fatalf("whitespace-only manifest version was treated as authoritative: %#v", got)
	}
}

func TestWhitespaceInRecordVersionIsTolerated(t *testing.T) {
	got := VersionConsistency("0.0.8", []records.Record{
		{Type: "PROJECT", ID: "AEOS-CLI", Version: "  0.0.8  ", Path: "PROJECT.md"},
	})
	if len(got) != 0 {
		t.Fatalf("padded but equal version reported as drift: %#v", got)
	}
}

func TestFindingNamesThePathToFix(t *testing.T) {
	got := VersionConsistency("0.0.8", []records.Record{
		{Type: "STATUS", ID: "STATUS", Version: "0.0.7", Path: "STATUS.md"},
	})
	if len(got) != 1 {
		t.Fatalf("want 1 finding, got %d", len(got))
	}
	if len(got[0].Paths) != 1 || got[0].Paths[0] != "STATUS.md" {
		t.Fatalf("finding should point at the offending file, got %v", got[0].Paths)
	}
	if !strings.Contains(got[0].RecommendedAction, "STATUS.md") {
		t.Fatalf("action should name the file to edit, got %q", got[0].RecommendedAction)
	}
}
