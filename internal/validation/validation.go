package validation

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"

	"github.com/baa-211/Aeos-/internal/config"
	"github.com/baa-211/Aeos-/internal/findings"
	"github.com/baa-211/Aeos-/internal/records"
)

func Validate(root string, manifest config.Manifest, recs []records.Record) []findings.Finding {
	var out []findings.Finding
	out = append(out, requiredFiles(root, manifest)...)
	out = append(out, duplicateIDs(recs)...)
	out = append(out, brokenReferences(recs)...)
	findings.Sort(out)
	return out
}

func requiredFiles(root string, manifest config.Manifest) []findings.Finding {
	if manifest.Project.Level == "A" {
		return nil
	}
	required := []struct {
		name string
		rule string
	}{
		{"PROJECT.md", "AEOS-DOC-001"},
		{"STATUS.md", "AEOS-DOC-002"},
	}
	var out []findings.Finding
	for _, item := range required {
		path := filepath.Join(root, item.name)
		info, err := os.Lstat(path)
		if err == nil && info.Mode().IsRegular() && info.Mode()&os.ModeSymlink == 0 {
			continue
		}
		if err != nil && !os.IsNotExist(err) {
			out = append(out, findings.Finding{
				Rule: item.rule, Severity: findings.Error, Confidence: "verified", Blocking: true,
				Message: fmt.Sprintf("cannot inspect required file %s: %v", item.name, err), Paths: []string{item.name},
				RecommendedAction: fmt.Sprintf("make %s readable as a regular non-symlink file", item.name),
			})
			continue
		}
		out = append(out, findings.Finding{
			Rule: item.rule, Severity: findings.Error, Confidence: "verified", Blocking: true,
			Message: fmt.Sprintf("required file %s is missing or not a regular file", item.name), Paths: []string{item.name},
			RecommendedAction: fmt.Sprintf("create %s as required by the active AEOS profile", item.name),
		})
	}
	return out
}

func duplicateIDs(recs []records.Record) []findings.Finding {
	byID := map[string][]string{}
	for _, r := range recs {
		byID[r.ID] = append(byID[r.ID], r.Path)
	}
	var ids []string
	for id, paths := range byID {
		if len(paths) > 1 {
			ids = append(ids, id)
		}
	}
	sort.Strings(ids)
	var out []findings.Finding
	for _, id := range ids {
		paths := append([]string(nil), byID[id]...)
		sort.Strings(paths)
		out = append(out, findings.Finding{
			Rule: "AEOS-DOC-005", Severity: findings.Error, Confidence: "verified", Blocking: true,
			Message: fmt.Sprintf("duplicate AEOS record id %s", id), Paths: paths,
			RecommendedAction: "assign a unique stable ID to each conflicting AEOS record",
		})
	}
	return out
}

func brokenReferences(recs []records.Record) []findings.Finding {
	ids := map[string]struct{}{}
	for _, r := range recs {
		ids[r.ID] = struct{}{}
	}
	var out []findings.Finding
	for _, r := range recs {
		refs := append([]string(nil), r.References...)
		sort.Strings(refs)
		for _, ref := range refs {
			if ref == "" || ref == "null" || ref == "none" {
				continue
			}
			if _, ok := ids[ref]; ok {
				continue
			}
			out = append(out, findings.Finding{
				Rule: "AEOS-REF-001", Severity: findings.Error, Confidence: "verified", Blocking: true,
				Message: fmt.Sprintf("record %s references missing record %s", r.ID, ref), Paths: []string{r.Path},
				RecommendedAction: fmt.Sprintf("create %s or correct/remove the reference from %s", ref, r.ID),
			})
		}
	}
	return out
}
