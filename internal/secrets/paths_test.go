package secrets

import (
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
)

// modeAwareGitleaks builds a fixture that answers `dir` with an absolute path
// and `git` with a repository-relative path for the same secret, reproducing
// real Gitleaks 8.30.0 behavior.
func modeAwareGitleaks(t *testing.T, root string) string {
	t.Helper()
	return fakeGitleaks(t, `
if [ "$1" = "version" ]; then echo "8.30.0"; exit 0; fi
mode="$1"
report=""
while [ $# -gt 0 ]; do
  if [ "$1" = "--report-path" ]; then report="$2"; shift 2; continue; fi
  shift
done
if [ "$mode" = "dir" ]; then
  printf '[{"File":"`+filepath.Join(root, "config.txt")+`","StartLine":7,"RuleID":"github-pat"}]' > "$report"
else
  printf '[{"File":"config.txt","StartLine":7,"RuleID":"github-pat"}]' > "$report"
fi
exit 10
`)
}

func initRepo(t *testing.T, root string) {
	t.Helper()
	if out, err := exec.Command("git", "init", root).CombinedOutput(); err != nil {
		t.Fatalf("git init: %v: %s", err, out)
	}
}

// TestScanDeduplicatesSameSecretAcrossDirAndGitModes is the regression test for
// the defect where one secret present in both the working tree and Git history
// produced two findings because the two scan modes report paths differently.
func TestScanDeduplicatesSameSecretAcrossDirAndGitModes(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("shell fixture is Unix-only")
	}
	root := t.TempDir()
	initRepo(t, root)

	got, err := Scan(root, modeAwareGitleaks(t, root))
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 {
		t.Fatalf("one secret in both tree and history produced %d findings, want 1: %#v", len(got), got)
	}
	if got[0].Paths[0] != "config.txt:7" {
		t.Fatalf("path = %q, want project-relative %q", got[0].Paths[0], "config.txt:7")
	}
}

// TestScanReportsNoAbsolutePathsWithinProject guards the deterministic
// reporting contract: a report containing machine-specific absolute paths is
// not reproducible across machines.
func TestScanReportsNoAbsolutePathsWithinProject(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("shell fixture is Unix-only")
	}
	root := t.TempDir()
	initRepo(t, root)

	got, err := Scan(root, modeAwareGitleaks(t, root))
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range got {
		for _, p := range f.Paths {
			if filepath.IsAbs(p) || strings.Contains(p, root) {
				t.Fatalf("finding leaks an absolute path into the report: %q", p)
			}
		}
	}
}

func TestNormalizePath(t *testing.T) {
	root := t.TempDir()

	cases := []struct {
		name string
		in   string
		want string
	}{
		{"relative is preserved", "config.txt", "config.txt"},
		{"nested relative is preserved", "internal/app/config.txt", "internal/app/config.txt"},
		{"absolute under root becomes relative", filepath.Join(root, "config.txt"), "config.txt"},
		{"nested absolute becomes relative", filepath.Join(root, "internal", "config.txt"), "internal/config.txt"},
		{"dot segments are cleaned", "./internal/../config.txt", "config.txt"},
		{"empty stays empty", "", ""},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := normalizePath(root, tc.in); got != tc.want {
				t.Fatalf("normalizePath(%q) = %q, want %q", tc.in, got, tc.want)
			}
		})
	}
}

// A secret found outside the project root keeps its absolute path. Rewriting it
// to something relative would misreport where the secret actually lives.
func TestNormalizePathKeepsPathsOutsideRootAbsolute(t *testing.T) {
	root := filepath.Join(t.TempDir(), "project")
	outside := filepath.Join(t.TempDir(), "elsewhere", "config.txt")

	got := normalizePath(root, outside)
	if !filepath.IsAbs(got) {
		t.Fatalf("normalizePath(%q) = %q, want the absolute path preserved", outside, got)
	}
}

func TestNormalizePathIsIdempotent(t *testing.T) {
	root := t.TempDir()
	once := normalizePath(root, filepath.Join(root, "internal", "config.txt"))
	twice := normalizePath(root, once)
	if once != twice {
		t.Fatalf("not idempotent: %q then %q", once, twice)
	}
}
