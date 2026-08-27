package secrets

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"github.com/baa-211/Aeos-/internal/findings"
)

const SupportedVersion = "8.30.0"

var (
	ErrUnavailable        = errors.New("gitleaks is not available")
	ErrUnsupportedVersion = errors.New("unsupported gitleaks version")
	ErrScanFailed         = errors.New("gitleaks scan failed")
)

type rawFinding struct {
	File      string `json:"File"`
	StartLine int    `json:"StartLine"`
	RuleID    string `json:"RuleID"`
}

// Scan verifies the pinned Gitleaks executable, scans both the current working
// tree and Git history, and returns only redacted AEOS metadata. The two scans
// are intentional: dir catches untracked/current content while git catches
// secrets that were committed and later removed.
func Scan(root, executable string) ([]findings.Finding, error) {
	path, err := resolveExecutable(executable)
	if err != nil {
		return nil, err
	}
	gotVersion, err := version(path)
	if err != nil {
		return nil, err
	}
	if gotVersion != SupportedVersion {
		return nil, fmt.Errorf("%w: got %s, require %s during AEOS pilot", ErrUnsupportedVersion, gotVersion, SupportedVersion)
	}

	modes := []string{"dir"}
	if isGitRepository(root) {
		modes = append(modes, "git")
	}

	var all []findings.Finding
	for _, mode := range modes {
		fs, err := runScan(root, path, mode)
		if err != nil {
			return nil, err
		}
		all = append(all, fs...)
	}
	return dedupe(all), nil
}

func runScan(root, path, mode string) ([]findings.Finding, error) {
	tmp, err := os.CreateTemp("", "aeos-gitleaks-*.json")
	if err != nil {
		return nil, fmt.Errorf("create gitleaks report: %w", err)
	}
	reportPath := tmp.Name()
	if err := tmp.Close(); err != nil {
		os.Remove(reportPath)
		return nil, fmt.Errorf("close gitleaks report: %w", err)
	}
	defer os.Remove(reportPath)

	args := []string{mode, "--no-banner", "--no-color", "--redact=100", "--report-format", "json", "--report-path", reportPath, "--exit-code", "10", root}
	cmd := exec.Command(path, args...)
	cmd.Dir = root
	output, runErr := cmd.CombinedOutput()
	if runErr != nil {
		var exitErr *exec.ExitError
		if !errors.As(runErr, &exitErr) || exitErr.ExitCode() != 10 {
			return nil, fmt.Errorf("%w (%s): %v: %s", ErrScanFailed, mode, runErr, sanitizeToolOutput(string(output)))
		}
	}

	data, err := os.ReadFile(reportPath)
	if err != nil {
		return nil, fmt.Errorf("read gitleaks report: %w", err)
	}
	if len(strings.TrimSpace(string(data))) == 0 {
		return nil, nil
	}
	var raw []rawFinding
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("parse gitleaks report: %w", err)
	}
	out := make([]findings.Finding, 0, len(raw))
	for _, rf := range raw {
		p := normalizePath(root, rf.File)
		if rf.StartLine > 0 {
			p += ":" + strconv.Itoa(rf.StartLine)
		}
		msg := "potential secret detected"
		if rf.RuleID != "" {
			msg += " by gitleaks rule " + rf.RuleID
		}
		out = append(out, findings.Finding{Rule: "AEOS-SEC-001", Severity: findings.Critical, Confidence: "high", Blocking: true, Message: msg, Paths: []string{p}, RecommendedAction: "remove the secret from active content, determine exposure, rotate/revoke the credential if real, and inspect Git history"})
	}
	findings.Sort(out)
	return out, nil
}

// normalizePath converts a Gitleaks-reported file path into a stable,
// project-relative, slash-separated form.
//
// This exists because the two scan modes disagree: `gitleaks dir` reports
// absolute filesystem paths while `gitleaks git` reports repository-relative
// paths. Left unnormalized, the same secret yields two AEOS findings that
// dedupe cannot match, inflating critical counts, and the JSON report carries
// machine-specific absolute paths, which breaks the deterministic reporting
// contract.
//
// A path that resolves outside the project root keeps its absolute form:
// misreporting the location of a secret would be worse than a non-relative
// path in the report.
func normalizePath(root, file string) string {
	file = strings.TrimSpace(file)
	if file == "" {
		return ""
	}
	if !filepath.IsAbs(file) {
		return filepath.ToSlash(filepath.Clean(file))
	}
	for _, base := range rootCandidates(root) {
		rel, err := filepath.Rel(base, file)
		if err != nil {
			continue
		}
		rel = filepath.ToSlash(filepath.Clean(rel))
		if rel == ".." || strings.HasPrefix(rel, "../") {
			continue
		}
		return rel
	}
	return filepath.ToSlash(filepath.Clean(file))
}

// rootCandidates returns the forms a project root can take in Gitleaks output:
// the absolute path, and the symlink-resolved path. Both are needed because
// some platforms report a resolved prefix for a symlinked root (macOS reports
// /private/tmp for /tmp).
func rootCandidates(root string) []string {
	abs, err := filepath.Abs(root)
	if err != nil {
		return nil
	}
	out := []string{abs}
	if resolved, err := filepath.EvalSymlinks(abs); err == nil && resolved != abs {
		out = append(out, resolved)
	}
	return out
}

func isGitRepository(root string) bool {
	cmd := exec.Command("git", "-C", root, "rev-parse", "--is-inside-work-tree")
	out, err := cmd.Output()
	return err == nil && strings.TrimSpace(string(out)) == "true"
}

func dedupe(in []findings.Finding) []findings.Finding {
	seen := map[string]struct{}{}
	out := make([]findings.Finding, 0, len(in))
	for _, f := range in {
		key := f.Rule + "|" + f.Message + "|" + strings.Join(f.Paths, ",")
		if _, ok := seen[key]; ok {
			continue
		}
		seen[key] = struct{}{}
		out = append(out, f)
	}
	sort.SliceStable(out, func(i, j int) bool {
		return out[i].Rule+strings.Join(out[i].Paths, ",") < out[j].Rule+strings.Join(out[j].Paths, ",")
	})
	return out
}

func resolveExecutable(explicit string) (string, error) {
	if explicit != "" {
		info, err := os.Stat(explicit)
		if err != nil || info.IsDir() {
			return "", fmt.Errorf("%w: %s", ErrUnavailable, explicit)
		}
		return explicit, nil
	}
	path, err := exec.LookPath("gitleaks")
	if err != nil {
		return "", ErrUnavailable
	}
	return path, nil
}

func version(path string) (string, error) {
	cmd := exec.Command(path, "version")
	out, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("read gitleaks version: %w: %s", err, sanitizeToolOutput(string(out)))
	}
	for _, field := range strings.Fields(strings.TrimSpace(string(out))) {
		candidate := strings.TrimPrefix(strings.TrimSpace(field), "v")
		if strings.Count(candidate, ".") != 2 {
			continue
		}
		valid := true
		for _, p := range strings.Split(candidate, ".") {
			if _, err := strconv.Atoi(p); err != nil {
				valid = false
			}
		}
		if valid {
			return candidate, nil
		}
	}
	return "", fmt.Errorf("read gitleaks version: unrecognized output")
}

func sanitizeToolOutput(s string) string {
	s = strings.TrimSpace(s)
	if len(s) > 500 {
		s = s[:500] + "..."
	}
	return s
}
