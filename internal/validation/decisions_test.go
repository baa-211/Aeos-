package validation

import (
	"strings"
	"testing"

	"github.com/baa-211/Aeos-/internal/findings"
	"github.com/baa-211/Aeos-/internal/records"
)

func TestOpenDecisionsAreReported(t *testing.T) {
	got := OpenDecisions([]records.Record{
		{Type: "DECISION", ID: "DEC-002", Status: "open", Path: "docs/decisions/DEC-002.md"},
		{Type: "DECISION", ID: "DEC-001", Status: "open", Path: "docs/decisions/DEC-001.md"},
	})

	if len(got) != 2 {
		t.Fatalf("got %d findings, want 2", len(got))
	}
	if got[0].Message[len("decision "):][:7] != "DEC-001" {
		t.Fatalf("findings are not sorted by id: %q first", got[0].Message)
	}
	for _, f := range got {
		if f.Rule != "AEOS-DEC-001" {
			t.Fatalf("rule = %q, want AEOS-DEC-001", f.Rule)
		}
	}
}

// An open decision is a healthy state. Blocking on one would make recording a
// question more expensive than leaving it unasked, which is the opposite of
// what these records are for.
func TestOpenDecisionsNeverBlock(t *testing.T) {
	got := OpenDecisions([]records.Record{
		{Type: "DECISION", ID: "DEC-001", Status: "open", Path: "a.md"},
	})
	if len(got) != 1 {
		t.Fatalf("want 1 finding, got %d", len(got))
	}
	if got[0].Severity != findings.Info {
		t.Fatalf("severity = %s, want INFO", got[0].Severity)
	}
	if got[0].Blocking {
		t.Fatal("an open decision must never block a check")
	}
}

func TestResolvedDecisionsAreSilent(t *testing.T) {
	for _, status := range []string{"accepted", "rejected", "superseded", "withdrawn", "implemented"} {
		t.Run(status, func(t *testing.T) {
			got := OpenDecisions([]records.Record{
				{Type: "DECISION", ID: "DEC-005", Status: status, Path: "a.md"},
			})
			if len(got) != 0 {
				t.Fatalf("status %q still reported as open: %#v", status, got)
			}
		})
	}
}

// A decision with no status at all is the most likely to be forgotten, so it
// must be reported rather than treated as resolved.
func TestUndeclaredStatusIsTreatedAsOpen(t *testing.T) {
	got := OpenDecisions([]records.Record{
		{Type: "DECISION", ID: "DEC-009", Path: "a.md"},
	})
	if len(got) != 1 {
		t.Fatalf("a statusless decision was not reported: %#v", got)
	}
	if !strings.Contains(got[0].Message, "undeclared") {
		t.Fatalf("message should name the missing status, got %q", got[0].Message)
	}
}

func TestNonDecisionRecordsAreIgnored(t *testing.T) {
	got := OpenDecisions([]records.Record{
		{Type: "REQ", ID: "REQ-CLI-006", Status: "accepted", Path: "a.md"},
		{Type: "ADR", ID: "ADR-004", Status: "open", Path: "b.md"},
		{Type: "STAGE", ID: "STAGE-01-INTAKE", Status: "active", Path: "c.md"},
	})
	if len(got) != 0 {
		t.Fatalf("non-decision records produced findings: %#v", got)
	}
}

func TestNoDecisionsMeansNoFindings(t *testing.T) {
	if got := OpenDecisions(nil); len(got) != 0 {
		t.Fatalf("empty input produced findings: %#v", got)
	}
}
