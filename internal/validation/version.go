package validation

import (
	"fmt"
	"sort"
	"strings"

	"github.com/baa-211/Aeos-/internal/findings"
	"github.com/baa-211/Aeos-/internal/records"
)

// VersionConsistency reports disagreement between the project version declared
// in the manifest and the version declared by any versioned AEOS record.
//
// This exists because version numbers were duplicated across aeos.yaml,
// PROJECT.md and STATUS.md with no mechanism keeping them aligned. On
// 2026-08-26 those three sources simultaneously claimed 0.0.1, 0.0.7 and
// 0.1.1-rc. Nothing detected it, because nothing was looking.
//
// The manifest is authoritative: it is the file AEOS is pointed at, and it is
// machine-read rather than prose. Records that declare a version must agree
// with it.
func VersionConsistency(manifestVersion string, discovered []records.Record) []findings.Finding {
	if strings.TrimSpace(manifestVersion) == "" {
		return nil
	}

	type mismatch struct {
		id      string
		path    string
		version string
	}
	var bad []mismatch
	for _, rec := range discovered {
		declared := strings.TrimSpace(rec.Version)
		if declared == "" {
			continue
		}
		if declared != manifestVersion {
			bad = append(bad, mismatch{id: rec.ID, path: rec.Path, version: declared})
		}
	}
	if len(bad) == 0 {
		return nil
	}

	sort.Slice(bad, func(i, j int) bool {
		if bad[i].id != bad[j].id {
			return bad[i].id < bad[j].id
		}
		return bad[i].path < bad[j].path
	})

	out := make([]findings.Finding, 0, len(bad))
	for _, m := range bad {
		out = append(out, findings.Finding{
			Rule:       "AEOS-VER-001",
			Severity:   findings.Error,
			Confidence: "verified",
			Blocking:   true,
			Message: fmt.Sprintf(
				"record %s declares version %q but the manifest declares %q",
				m.id, m.version, manifestVersion),
			Paths: []string{m.path},
			RecommendedAction: fmt.Sprintf(
				"set the version in %s to %s, or correct project.version in the manifest if the record is right",
				m.path, manifestVersion),
		})
	}
	return out
}
