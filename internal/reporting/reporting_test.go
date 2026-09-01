package reporting

import (
	"bytes"
	"encoding/json"
	"strings"
	"testing"

	"github.com/baa-211/Aeos-/internal/findings"
)

func TestNewAndJSONAreDeterministic(t *testing.T) {
	fs := []findings.Finding{
		{Rule: "AEOS-X-002", Severity: findings.Warning, Confidence: "verified", Message: "warning"},
		{Rule: "AEOS-X-001", Severity: findings.Error, Confidence: "verified", Message: "error", Blocking: true},
	}
	r := New(Project{}, Pipeline{}, "aeos.yaml", []Record{
		{Type: "REQ", ID: "REQ-2", Path: "docs/b.md"},
		{Type: "ADR", ID: "ADR-1", Path: "docs/a.md"},
		{Type: "REQ", ID: "REQ-1", Path: "docs/c.md"},
	}, fs)
	if r.Result != "FAIL" || r.Summary.Errors != 1 || r.Summary.Warnings != 1 {
		t.Fatalf("unexpected report: %#v", r)
	}
	if r.Findings[0].Rule != "AEOS-X-001" {
		t.Fatalf("findings not deterministically sorted: %#v", r.Findings)
	}
	var buf bytes.Buffer
	if err := JSON(&buf, r); err != nil {
		t.Fatal(err)
	}
	var decoded Report
	if err := json.Unmarshal(buf.Bytes(), &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.SchemaVersion != SchemaVersion || decoded.Findings[0].Rule != "AEOS-X-001" {
		t.Fatalf("unexpected JSON: %s", buf.String())
	}
}

func TestConsoleIncludesAction(t *testing.T) {
	r := New(Project{}, Pipeline{}, "", nil, []findings.Finding{{
		Rule: "AEOS-T-001", Severity: findings.Error, Confidence: "verified", Message: "bad", RecommendedAction: "fix it", Blocking: true,
	}})
	var buf bytes.Buffer
	if err := Console(&buf, r); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(buf.String(), "Action: fix it") {
		t.Fatalf("console output missing action: %s", buf.String())
	}
}
