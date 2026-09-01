package validation

import (
	"fmt"
	"sort"

	"github.com/baa-211/Aeos-/internal/findings"
	"github.com/baa-211/Aeos-/internal/records"
)

// OpenDecisions reports DECISION records that are still unresolved.
//
// These are informational, never blocking. An open decision is a normal and
// healthy state for a project; what is unhealthy is an open decision nobody can
// see. Reporting them keeps the CLI and the command interface describing the
// same reality — the interface marks the stage orbs that are waiting on a
// choice, and this is where that same signal reaches anyone using the CLI.
//
// A decision is considered open unless it declares a terminal status.
func OpenDecisions(discovered []records.Record) []findings.Finding {
	resolved := map[string]bool{
		"accepted": true, "rejected": true, "superseded": true,
		"withdrawn": true, "implemented": true,
	}

	var open []records.Record
	for _, rec := range discovered {
		if rec.Type != "DECISION" {
			continue
		}
		if !resolved[rec.Status] {
			open = append(open, rec)
		}
	}
	if len(open) == 0 {
		return nil
	}

	sort.Slice(open, func(i, j int) bool { return open[i].ID < open[j].ID })

	out := make([]findings.Finding, 0, len(open))
	for _, rec := range open {
		status := rec.Status
		if status == "" {
			status = "undeclared"
		}
		out = append(out, findings.Finding{
			Rule:              "AEOS-DEC-001",
			Severity:          findings.Info,
			Confidence:        "verified",
			Blocking:          false,
			Message:           fmt.Sprintf("decision %s is unresolved (status %q)", rec.ID, status),
			Paths:             []string{rec.Path},
			RecommendedAction: "record a resolution, or set the status to rejected or withdrawn if it is no longer live",
		})
	}
	return out
}
