package reporting

import (
	"encoding/json"
	"fmt"
	"io"
	"strings"

	"github.com/baa-211/Aeos-/internal/findings"
)

const SchemaVersion = "0.1"

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

type Report struct {
	SchemaVersion string             `json:"schema_version"`
	Project       Project            `json:"project"`
	ManifestPath  string             `json:"manifest_path,omitempty"`
	Summary       Summary            `json:"summary"`
	Findings      []findings.Finding `json:"findings"`
	Result        string             `json:"result"`
}

func New(project Project, manifestPath string, records int, fs []findings.Finding) Report {
	findings.Sort(fs)
	r := Report{
		SchemaVersion: SchemaVersion,
		Project:       project,
		ManifestPath:  manifestPath,
		Summary:       Summary{RecordsDiscovered: records},
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
