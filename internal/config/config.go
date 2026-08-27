package config

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

const ManifestName = "aeos.yaml"

var (
	ErrManifestNotFound = errors.New("aeos manifest not found")
	ErrManifestInvalid  = errors.New("aeos manifest invalid")
)

type Manifest struct {
	AEOS struct {
		Specification   string
		Version         string
		ManifestVersion string
	}
	Project struct {
		ID            string
		Name          string
		Version       string
		Stage         string
		Level         string
		SecurityLevel string
	}
	Security struct {
		SecretScanRequired bool
	}
}

// Load parses the deliberately small AEOS v0.1 manifest subset required by M1.
// It does not execute configuration and intentionally rejects unsupported YAML
// constructs instead of trying to be a general-purpose YAML parser.
func Load(root string) (Manifest, string, error) {
	path := filepath.Join(root, ManifestName)
	f, err := os.Open(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return Manifest{}, path, fmt.Errorf("%w: %s", ErrManifestNotFound, path)
		}
		return Manifest{}, path, fmt.Errorf("read manifest: %w", err)
	}
	defer f.Close()

	var manifest Manifest
	var section string
	var subsection string
	scanner := bufio.NewScanner(f)
	scanner.Buffer(make([]byte, 1024), 1024*1024)
	lineNo := 0

	for scanner.Scan() {
		lineNo++
		raw := scanner.Text()
		trimmed := strings.TrimSpace(raw)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}

		if strings.ContainsAny(trimmed, "[]{}&*!|") {
			return Manifest{}, path, invalid(lineNo, "unsupported YAML construct")
		}

		indent := len(raw) - len(strings.TrimLeft(raw, " "))
		if strings.Contains(raw[:indent], "\t") {
			return Manifest{}, path, invalid(lineNo, "tabs are not allowed for indentation")
		}

		if indent == 0 {
			if !strings.HasSuffix(trimmed, ":") {
				return Manifest{}, path, invalid(lineNo, "expected top-level section")
			}
			section = strings.TrimSuffix(trimmed, ":")
			subsection = ""
			if section != "aeos" && section != "project" && section != "security" {
				section = "_ignored"
			}
			continue
		}

		if section == "_ignored" {
			continue
		}
		if section == "security" {
			if indent == 2 && strings.HasSuffix(trimmed, ":") {
				subsection = strings.TrimSuffix(trimmed, ":")
				continue
			}
			if indent == 4 && subsection == "secret_scan" {
				parts := strings.SplitN(trimmed, ":", 2)
				if len(parts) != 2 || strings.TrimSpace(parts[0]) != "required" {
					return Manifest{}, path, invalid(lineNo, "expected secret_scan.required")
				}
				v := strings.TrimSpace(parts[1])
				switch v {
				case "true":
					manifest.Security.SecretScanRequired = true
				case "false":
					manifest.Security.SecretScanRequired = false
				default:
					return Manifest{}, path, invalid(lineNo, "secret_scan.required must be true or false")
				}
				continue
			}
			continue
		}

		if indent != 2 {
			return Manifest{}, path, invalid(lineNo, "expected two-space indentation")
		}

		parts := strings.SplitN(trimmed, ":", 2)
		if len(parts) != 2 || strings.TrimSpace(parts[0]) == "" {
			return Manifest{}, path, invalid(lineNo, "expected key: value")
		}
		key := strings.TrimSpace(parts[0])
		value, err := parseScalar(strings.TrimSpace(parts[1]))
		if err != nil {
			return Manifest{}, path, invalid(lineNo, err.Error())
		}

		switch section {
		case "aeos":
			switch key {
			case "specification":
				manifest.AEOS.Specification = value
			case "version":
				manifest.AEOS.Version = value
			case "manifest_version":
				manifest.AEOS.ManifestVersion = value
			}
		case "project":
			switch key {
			case "id":
				manifest.Project.ID = value
			case "name":
				manifest.Project.Name = value
			case "version":
				manifest.Project.Version = value
			case "stage":
				manifest.Project.Stage = value
			case "level":
				manifest.Project.Level = value
			case "security_level":
				manifest.Project.SecurityLevel = value
			}
		}
	}
	if err := scanner.Err(); err != nil {
		return Manifest{}, path, fmt.Errorf("read manifest: %w", err)
	}

	if manifest.AEOS.Specification == "" || manifest.AEOS.Version == "" || manifest.AEOS.ManifestVersion == "" {
		return Manifest{}, path, fmt.Errorf("%w: aeos.specification, aeos.version, and aeos.manifest_version are required", ErrManifestInvalid)
	}
	if manifest.Project.ID == "" || manifest.Project.Name == "" || manifest.Project.Level == "" || manifest.Project.SecurityLevel == "" {
		return Manifest{}, path, fmt.Errorf("%w: project.id, project.name, project.level, and project.security_level are required", ErrManifestInvalid)
	}
	if manifest.AEOS.Specification != "AEOS" {
		return Manifest{}, path, fmt.Errorf("%w: aeos.specification must be AEOS", ErrManifestInvalid)
	}
	if manifest.AEOS.ManifestVersion != "0.1" {
		return Manifest{}, path, fmt.Errorf("%w: unsupported manifest version %q", ErrManifestInvalid, manifest.AEOS.ManifestVersion)
	}
	if !oneOf(manifest.Project.Level, "A", "B", "C", "D") {
		return Manifest{}, path, fmt.Errorf("%w: project.level must be A, B, C, or D", ErrManifestInvalid)
	}
	if !oneOf(manifest.Project.SecurityLevel, "S1", "S2", "S3", "S4") {
		return Manifest{}, path, fmt.Errorf("%w: project.security_level must be S1, S2, S3, or S4", ErrManifestInvalid)
	}

	return manifest, path, nil
}

func parseScalar(v string) (string, error) {
	if v == "" {
		return "", nil
	}
	if strings.HasPrefix(v, "\"") {
		if len(v) < 2 || !strings.HasSuffix(v, "\"") {
			return "", errors.New("unterminated quoted scalar")
		}
		return strings.Trim(v, "\""), nil
	}
	if strings.HasPrefix(v, "'") {
		if len(v) < 2 || !strings.HasSuffix(v, "'") {
			return "", errors.New("unterminated quoted scalar")
		}
		return strings.Trim(v, "'"), nil
	}
	if strings.Contains(v, ": ") {
		return "", errors.New("complex scalar is not supported in M1")
	}
	return v, nil
}

func invalid(line int, msg string) error {
	return fmt.Errorf("%w at line %d: %s", ErrManifestInvalid, line, msg)
}

func oneOf(value string, allowed ...string) bool {
	for _, candidate := range allowed {
		if value == candidate {
			return true
		}
	}
	return false
}
