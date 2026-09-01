package reporting

import (
	"encoding/json"
	"fmt"
	"io"
	"sort"
	"strings"

	"github.com/baa-211/Aeos-/internal/findings"
)

// SchemaVersion is the version of the report contract itself, not of AEOS.
// Consumers must gate on this rather than on the tool version.
const SchemaVersion = "0.3"

type Project struct {
	ID            string `json:"id,omitempty"`
	Name          string `json:"name,omitempty"`
	Level         string `json:"level,omitempty"`
	SecurityLevel string `json:"security_level,omitempty"`
}

type Summary struct {
	RecordsDiscovered int `json:"records_discovered"`
	Info              int `json:"info"`
	Warnings          int `json:"warnings"`
	Errors            int `json:"errors"`
	Critical          int `json:"critical"`
}

// Record is the report-facing view of a discovered AEOS record. It exists so
// that consumers such as the preview interface can render the record graph from
// the report itself rather than parsing the repository independently, which
// would make them a second source of truth.
type Record struct {
	Type       string   `json:"type"`
	ID         string   `json:"id"`
	Status     string   `json:"status,omitempty"`
	Path       string   `json:"path"`
	References []string `json:"references,omitempty"`
}

// Pipeline reports what the project declares about its own position in the
// delivery pipeline. AEOS does not infer progress; an undeclared stage is
// reported as empty and must be displayed as unknown, never guessed.
type Pipeline struct {
	CurrentStage string `json:"current_stage,omitempty"`
}

type Report struct {
	SchemaVersion string             `json:"schema_version"`
	Project       Project            `json:"project"`
	Pipeline      Pipeline           `json:"pipeline"`
	ManifestPath  string             `json:"manifest_path,omitempty"`
	Summary       Summary            `json:"summary"`
	Records       []Record           `json:"records"`
	Findings      []findings.Finding `json:"findings"`
	Result        string             `json:"result"`
}

// SortRecords orders records deterministically by type, then identifier, then
// path, so that two runs over the same project produce identical output.
func SortRecords(rs []Record) {
	sort.Slice(rs, func(i, j int) bool {
		a, b := rs[i], rs[j]
		if a.Type != b.Type {
			return a.Type < b.Type
		}
		if a.ID != b.ID {
			return a.ID < b.ID
		}
		return a.Path < b.Path
	})
}

func New(project Project, pipeline Pipeline, manifestPath string, recs []Record, fs []findings.Finding) Report {
	findings.Sort(fs)
	indexed := append([]Record{}, recs...)
	SortRecords(indexed)
	r := Report{
		SchemaVersion: SchemaVersion,
		Project:       project,
		Pipeline:      pipeline,
		ManifestPath:  manifestPath,
		Summary:       Summary{RecordsDiscovered: len(indexed)},
		Records:       indexed,
		Findings:      append([]findings.Finding{}, fs...),
		Result:        "PASS",
	}
	for _, f := range fs {
		switch f.Severity {
		case findings.Critical:
			r.Summary.Critical++
		case findings.Error:
			r.Summary.Errors++
		case findings.Warning:
			r.Summary.Warnings++
		default:
			r.Summary.Info++
		}
	}
	if r.Summary.Critical > 0 || r.Summary.Errors > 0 {
		r.Result = "FAIL"
	} else if r.Summary.Warnings > 0 {
		r.Result = "PASS_WITH_WARNINGS"
	}
	return r
}

func Console(w io.Writer, r Report) error {
	if _, err := fmt.Fprintln(w, "AEOS project check"); err != nil {
		return err
	}
	if _, err := fmt.Fprintln(w, "=================="); err != nil {
		return err
	}
	if r.Project.Name != "" || r.Project.ID != "" {
		if _, err := fmt.Fprintf(w, "Project: %s (%s)\n", r.Project.Name, r.Project.ID); err != nil {
			return err
		}
	}
	if r.Project.Level != "" || r.Project.SecurityLevel != "" {
		if _, err := fmt.Fprintf(w, "Level: %s / %s\n", r.Project.Level, r.Project.SecurityLevel); err != nil {
			return err
		}
	}
	if r.ManifestPath != "" {
		if _, err := fmt.Fprintf(w, "Manifest: %s\n", r.ManifestPath); err != nil {
			return err
		}
	}
	if _, err := fmt.Fprintf(w, "Records discovered: %d\n", r.Summary.RecordsDiscovered); err != nil {
		return err
	}
	if _, err := fmt.Fprintf(w, "Findings: %d (critical=%d error=%d warning=%d info=%d)\n", len(r.Findings), r.Summary.Critical, r.Summary.Errors, r.Summary.Warnings, r.Summary.Info); err != nil {
		return err
	}
	for _, f := range r.Findings {
		if _, err := fmt.Fprintf(w, "%s %s: %s", f.Rule, f.Severity, f.Message); err != nil {
			return err
		}
		if len(f.Paths) > 0 {
			if _, err := fmt.Fprintf(w, " [%s]", strings.Join(f.Paths, ", ")); err != nil {
				return err
			}
		}
		if _, err := fmt.Fprintln(w); err != nil {
			return err
		}
		if f.RecommendedAction != "" {
			if _, err := fmt.Fprintf(w, "  Action: %s\n", f.RecommendedAction); err != nil {
				return err
			}
		}
	}
	_, err := fmt.Fprintf(w, "Result: %s\n", r.Result)
	return err
}

func JSON(w io.Writer, r Report) error {
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(r)
}
