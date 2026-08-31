package reporting

import (
	"bytes"
	"encoding/json"
	"path/filepath"
	"strings"
	"testing"

	"github.com/baa-211/Aeos-/internal/findings"
)

func sampleRecords() []Record {
	return []Record{
		{Type: "REQ", ID: "REQ-CLI-002", Path: "docs/requirements/b.md", Status: "accepted"},
		{Type: "ADR", ID: "ADR-004", Path: "docs/adr/d.md", Status: "accepted"},
		{Type: "STAGE", ID: "STAGE-01-INTAKE", Path: "docs/stages/s1.md", Status: "active"},
		{Type: "REQ", ID: "REQ-CLI-001", Path: "docs/requirements/a.md", Status: "implemented"},
	}
}

// The preview interface renders the record graph from the report. If the report
// carried no records it would have to parse the repository itself and become a
// second source of truth.
func TestReportCarriesRecordIndex(t *testing.T) {
	r := New(Project{ID: "AEOS-CLI"}, "aeos.yaml", sampleRecords(), nil)

	if len(r.Records) != 4 {
		t.Fatalf("report carries %d records, want 4", len(r.Records))
	}
	if r.Summary.RecordsDiscovered != 4 {
		t.Fatalf("summary count %d disagrees with the index length", r.Summary.RecordsDiscovered)
	}

	var buf bytes.Buffer
	if err := JSON(&buf, r); err != nil {
		t.Fatal(err)
	}
	var decoded Report
	if err := json.Unmarshal(buf.Bytes(), &decoded); err != nil {
		t.Fatal(err)
	}
	if len(decoded.Records) != 4 {
		t.Fatalf("records did not survive JSON round-trip: %s", buf.String())
	}
	if decoded.Records[0].ID != "ADR-004" {
		t.Fatalf("first record = %q, want ADR-004 (sorted by type)", decoded.Records[0].ID)
	}
}

func TestRecordIndexIsDeterministic(t *testing.T) {
	first := New(Project{}, "aeos.yaml", sampleRecords(), nil)

	shuffled := sampleRecords()
	shuffled[0], shuffled[3] = shuffled[3], shuffled[0]
	shuffled[1], shuffled[2] = shuffled[2], shuffled[1]
	second := New(Project{}, "aeos.yaml", shuffled, nil)

	var a, b bytes.Buffer
	if err := JSON(&a, first); err != nil {
		t.Fatal(err)
	}
	if err := JSON(&b, second); err != nil {
		t.Fatal(err)
	}
	if a.String() != b.String() {
		t.Fatalf("input order changed the report:\n%s\n---\n%s", a.String(), b.String())
	}
}

// New must not retain the caller's slice, or a later mutation would silently
// alter an already-produced report.
func TestNewCopiesRecords(t *testing.T) {
	input := sampleRecords()
	r := New(Project{}, "aeos.yaml", input, nil)
	input[0].ID = "MUTATED"

	for _, rec := range r.Records {
		if rec.ID == "MUTATED" {
			t.Fatal("report shares backing storage with the caller's slice")
		}
	}
}

func TestRecordPathsAreRelative(t *testing.T) {
	r := New(Project{}, "aeos.yaml", sampleRecords(), nil)
	for _, rec := range r.Records {
		if filepath.IsAbs(rec.Path) {
			t.Fatalf("record %s carries an absolute path: %q", rec.ID, rec.Path)
		}
		if strings.Contains(rec.Path, "\\") {
			t.Fatalf("record %s path is not slash-separated: %q", rec.ID, rec.Path)
		}
	}
}

func TestEmptyRecordIndexSerializesAsArray(t *testing.T) {
	r := New(Project{}, "aeos.yaml", nil, []findings.Finding{})
	var buf bytes.Buffer
	if err := JSON(&buf, r); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(buf.String(), `"records": []`) {
		t.Fatalf("empty index should serialize as [] not null, got: %s", buf.String())
	}
}
