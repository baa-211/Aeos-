package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func manifestRoot(t *testing.T, body string) string {
	t.Helper()
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, ManifestName), []byte(body), 0o600); err != nil {
		t.Fatal(err)
	}
	return root
}

const validManifest = `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "AEOS-CLI"
  name: "aeos-cli"
  version: "0.0.1"
  stage: "development"
  level: "B"
  security_level: "S2"
classification:
  default_data: "internal"
security:
  secret_scan:
    required: true
`

// TestTypoInSecuritySectionIsRejected is the regression test for a silent
// security downgrade: a manifest whose `security` section was misspelled
// previously parsed cleanly, leaving SecretScanRequired false, so a project
// containing live secrets reported PASS with exit code 0.
func TestTypoInSecuritySectionIsRejected(t *testing.T) {
	body := strings.Replace(validManifest, "security:\n  secret_scan:", "securty:\n  secret_scan:", 1)
	root := manifestRoot(t, body)

	_, _, err := Load(root)
	if err == nil {
		t.Fatal("a misspelled security section parsed without error; secret scanning would be silently disabled")
	}
	if !strings.Contains(err.Error(), "securty") {
		t.Fatalf("error should name the offending section, got: %v", err)
	}
	if !strings.Contains(err.Error(), `did you mean "security"`) {
		t.Fatalf("error should suggest the intended section, got: %v", err)
	}
}

func TestUnknownTopLevelSectionIsRejected(t *testing.T) {
	root := manifestRoot(t, validManifest+"deployment:\n  target: \"prod\"\n")

	_, _, err := Load(root)
	if err == nil {
		t.Fatal("unknown top-level section was silently ignored")
	}
	if !strings.Contains(err.Error(), "deployment") {
		t.Fatalf("error should name the unknown section, got: %v", err)
	}
}

// Every section in the specification must load, or the stricter parser would
// reject valid manifests.
func TestKnownSectionsAllLoad(t *testing.T) {
	root := manifestRoot(t, validManifest)

	m, _, err := Load(root)
	if err != nil {
		t.Fatalf("valid manifest rejected: %v", err)
	}
	if !m.Security.SecretScanRequired {
		t.Fatal("secret scanning should be required by this manifest")
	}
	if m.Project.ID != "AEOS-CLI" {
		t.Fatalf("project id = %q, want AEOS-CLI", m.Project.ID)
	}
}

func TestClosestSection(t *testing.T) {
	cases := map[string]string{
		"securty":        "security",
		"secuirty":       "security",
		"projct":         "project",
		"aeoss":          "aeos",
		"classifcation":  "classification",
		"zzzzzzzzzzzzzz": "", // too far from anything to guess
	}
	for input, want := range cases {
		t.Run(input, func(t *testing.T) {
			if got := closestSection(input); got != want {
				t.Fatalf("closestSection(%q) = %q, want %q", input, got, want)
			}
		})
	}
}

func TestEditDistance(t *testing.T) {
	cases := []struct {
		a, b string
		want int
	}{
		{"", "", 0},
		{"security", "security", 0},
		{"securty", "security", 1},
		{"abc", "", 3},
		{"", "abc", 3},
		{"kitten", "sitting", 3},
	}
	for _, tc := range cases {
		if got := editDistance(tc.a, tc.b); got != tc.want {
			t.Fatalf("editDistance(%q, %q) = %d, want %d", tc.a, tc.b, got, tc.want)
		}
	}
}
