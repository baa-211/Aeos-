package config

import (
	"errors"
	"os"
	"path/filepath"
	"testing"
)

func writeManifest(t *testing.T, root, content string) {
	t.Helper()
	if err := os.WriteFile(filepath.Join(root, ManifestName), []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
}

func TestLoadValidManifest(t *testing.T) {
	root := t.TempDir()
	writeManifest(t, root, `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "TEST"
  name: "test-project"
  version: "0.0.1"
  stage: "development"
  level: "B"
  security_level: "S2"
classification:
  default_data: "internal"
`)

	manifest, _, err := Load(root)
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}
	if manifest.Project.ID != "TEST" {
		t.Fatalf("Project.ID = %q, want TEST", manifest.Project.ID)
	}
}

func TestLoadMissingManifest(t *testing.T) {
	_, _, err := Load(t.TempDir())
	if !errors.Is(err, ErrManifestNotFound) {
		t.Fatalf("error = %v, want ErrManifestNotFound", err)
	}
}

func TestLoadMalformedManifest(t *testing.T) {
	root := t.TempDir()
	writeManifest(t, root, "aeos: [\n")
	_, _, err := Load(root)
	if !errors.Is(err, ErrManifestInvalid) {
		t.Fatalf("error = %v, want ErrManifestInvalid", err)
	}
}

func TestLoadMissingRequiredFields(t *testing.T) {
	root := t.TempDir()
	writeManifest(t, root, `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "TEST"
`)
	_, _, err := Load(root)
	if !errors.Is(err, ErrManifestInvalid) {
		t.Fatalf("error = %v, want ErrManifestInvalid", err)
	}
}

func TestLoadRejectsUnsupportedConstruct(t *testing.T) {
	root := t.TempDir()
	writeManifest(t, root, `aeos:
  specification: [AEOS]
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "TEST"
  name: "test"
  level: "B"
  security_level: "S2"
`)
	_, _, err := Load(root)
	if !errors.Is(err, ErrManifestInvalid) {
		t.Fatalf("error = %v, want ErrManifestInvalid", err)
	}
}

func TestLoadSecretScanRequirement(t *testing.T) {
	root := t.TempDir()
	writeManifest(t, root, `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "TEST"
  name: "test"
  level: "B"
  security_level: "S2"
security:
  secret_scan:
    required: true
`)
	manifest, _, err := Load(root)
	if err != nil {
		t.Fatal(err)
	}
	if !manifest.Security.SecretScanRequired {
		t.Fatal("secret scan requirement not parsed")
	}
}

func TestLoadRejectsInvalidProjectClassifications(t *testing.T) {
	cases := []struct{ name, level, security string }{
		{"bad-level", "Z", "S2"},
		{"bad-security", "B", "S9"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			root := t.TempDir()
			writeManifest(t, root, `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "0.1"
project:
  id: "TEST"
  name: "test"
  level: "`+tc.level+`"
  security_level: "`+tc.security+`"
`)
			_, _, err := Load(root)
			if !errors.Is(err, ErrManifestInvalid) {
				t.Fatalf("error=%v", err)
			}
		})
	}
}

func TestLoadRejectsUnsupportedManifestVersion(t *testing.T) {
	root := t.TempDir()
	writeManifest(t, root, `aeos:
  specification: "AEOS"
  version: "0.1"
  manifest_version: "9.9"
project:
  id: "TEST"
  name: "test"
  level: "B"
  security_level: "S2"
`)
	_, _, err := Load(root)
	if !errors.Is(err, ErrManifestInvalid) {
		t.Fatalf("error=%v", err)
	}
}
