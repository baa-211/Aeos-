package findings

import "testing"

func TestSortOrdersBySeverityThenRuleThenMessageThenPath(t *testing.T) {
	in := []Finding{
		{Rule: "AEOS-INT-002", Severity: Warning, Message: "b"},
		{Rule: "AEOS-SEC-001", Severity: Critical, Message: "z", Paths: []string{"z.txt"}},
		{Rule: "AEOS-INT-001", Severity: Info, Message: "a"},
		{Rule: "AEOS-SEC-001", Severity: Critical, Message: "a", Paths: []string{"b.txt"}},
		{Rule: "AEOS-SEC-001", Severity: Critical, Message: "a", Paths: []string{"a.txt"}},
		{Rule: "AEOS-INT-003", Severity: Error, Message: "c"},
	}
	Sort(in)

	want := []string{"CRITICAL", "CRITICAL", "CRITICAL", "ERROR", "WARNING", "INFO"}
	for i, f := range in {
		if string(f.Severity) != want[i] {
			t.Fatalf("position %d has severity %s, want %s", i, f.Severity, want[i])
		}
	}
	// Within equal severity and rule, message then path decide the order.
	if in[0].Message != "a" || in[0].Paths[0] != "a.txt" {
		t.Fatalf("first critical = %q %v, want message \"a\" path a.txt", in[0].Message, in[0].Paths)
	}
	if in[1].Paths[0] != "b.txt" {
		t.Fatalf("second critical path = %v, want b.txt", in[1].Paths)
	}
}

// Sorting must be a total order on equal input so that two runs of the same
// project produce byte-identical reports.
func TestSortIsDeterministicAcrossRuns(t *testing.T) {
	build := func() []Finding {
		return []Finding{
			{Rule: "AEOS-SEC-001", Severity: Critical, Message: "m", Paths: []string{"c.txt"}},
			{Rule: "AEOS-SEC-001", Severity: Critical, Message: "m", Paths: []string{"a.txt"}},
			{Rule: "AEOS-INT-001", Severity: Error, Message: "n"},
			{Rule: "AEOS-SEC-001", Severity: Critical, Message: "m", Paths: []string{"b.txt"}},
		}
	}
	first, second := build(), build()
	Sort(first)
	Sort(second)

	for i := range first {
		if first[i].Rule != second[i].Rule || firstPath(first[i]) != firstPath(second[i]) {
			t.Fatalf("position %d differs between runs: %#v vs %#v", i, first[i], second[i])
		}
	}
}

func TestSortHandlesEmptyAndSingle(t *testing.T) {
	var empty []Finding
	Sort(empty) // must not panic

	one := []Finding{{Rule: "AEOS-SEC-001", Severity: Critical}}
	Sort(one)
	if len(one) != 1 {
		t.Fatalf("len = %d, want 1", len(one))
	}
}

func TestHighestSeverity(t *testing.T) {
	cases := []struct {
		name string
		in   []Finding
		want Severity
	}{
		{"empty defaults to info", nil, Info},
		{"single warning", []Finding{{Severity: Warning}}, Warning},
		{"critical wins over error", []Finding{{Severity: Error}, {Severity: Critical}, {Severity: Info}}, Critical},
		{"error wins over warning", []Finding{{Severity: Warning}, {Severity: Error}}, Error},
		{"warning wins over info", []Finding{{Severity: Info}, {Severity: Warning}}, Warning},
		{"unknown severity ranks as info", []Finding{{Severity: Severity("MYSTERY")}}, Info},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := HighestSeverity(tc.in); got != tc.want {
				t.Fatalf("HighestSeverity = %s, want %s", got, tc.want)
			}
		})
	}
}

// An unrecognized severity must never outrank a real one; a malformed finding
// should not be able to suppress a genuine critical.
func TestUnknownSeverityCannotMaskCritical(t *testing.T) {
	in := []Finding{{Severity: Severity("")}, {Severity: Critical}, {Severity: Severity("BOGUS")}}
	if got := HighestSeverity(in); got != Critical {
		t.Fatalf("HighestSeverity = %s, want CRITICAL", got)
	}
}

func TestFirstPath(t *testing.T) {
	if got := firstPath(Finding{}); got != "" {
		t.Fatalf("firstPath(no paths) = %q, want empty", got)
	}
	if got := firstPath(Finding{Paths: []string{"a.txt", "b.txt"}}); got != "a.txt" {
		t.Fatalf("firstPath = %q, want a.txt", got)
	}
}
