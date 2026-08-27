package main

import (
	"errors"
	"fmt"
	"io"
	"os"

	"github.com/baa-211/Aeos-/internal/config"
	"github.com/baa-211/Aeos-/internal/findings"
	"github.com/baa-211/Aeos-/internal/records"
	"github.com/baa-211/Aeos-/internal/reporting"
	"github.com/baa-211/Aeos-/internal/secrets"
	"github.com/baa-211/Aeos-/internal/validation"
)

const (
	exitOK            = 0
	exitValidation    = 2
	exitCritical      = 3
	exitConfiguration = 4
	exitInternal      = 5
)

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

func run(args []string, stdout, stderr io.Writer) int {
	format, ok := parseArgs(args)
	if !ok {
		fmt.Fprintln(stderr, "usage: aeos check [--format console|json]")
		return exitConfiguration
	}

	cwd, err := os.Getwd()
	if err != nil {
		fmt.Fprintf(stderr, "AEOS internal error: determine working directory: %v\n", err)
		return exitInternal
	}

	report, exit := check(cwd)
	if err := writeReport(stdout, format, report); err != nil {
		fmt.Fprintf(stderr, "AEOS internal error: write report: %v\n", err)
		return exitInternal
	}
	return exit
}

func parseArgs(args []string) (string, bool) {
	if len(args) == 1 && args[0] == "check" {
		return "console", true
	}
	if len(args) == 3 && args[0] == "check" && args[1] == "--format" && (args[2] == "console" || args[2] == "json") {
		return args[2], true
	}
	return "", false
}

func check(root string) (reporting.Report, int) {
	manifest, _, err := config.Load(root)
	if err != nil {
		f := findings.Finding{Severity: findings.Error, Confidence: "verified", Blocking: true, Paths: []string{config.ManifestName}}
		exit := exitConfiguration
		switch {
		case errors.Is(err, config.ErrManifestNotFound):
			f.Rule = "AEOS-CFG-001"
			f.Message = err.Error()
			f.RecommendedAction = "create aeos.yaml at the project root"
		case errors.Is(err, config.ErrManifestInvalid):
			f.Rule = "AEOS-CFG-002"
			f.Message = err.Error()
			f.RecommendedAction = "correct the manifest syntax and required AEOS fields"
		default:
			f.Rule = "AEOS-INTERNAL-001"
			f.Message = fmt.Sprintf("cannot load manifest: %v", err)
			f.RecommendedAction = "inspect filesystem access and rerun the validator"
			exit = exitInternal
		}
		return reporting.New(reporting.Project{}, config.ManifestName, 0, []findings.Finding{f}), exit
	}

	project := reporting.Project{ID: manifest.Project.ID, Name: manifest.Project.Name, Level: manifest.Project.Level, SecurityLevel: manifest.Project.SecurityLevel}
	discovered, err := records.Discover(root)
	if err != nil {
		f := findings.Finding{Severity: findings.Error, Confidence: "verified", Blocking: true, Message: err.Error()}
		exit := exitConfiguration
		var frontmatterErr *records.FrontmatterError
		if errors.As(err, &frontmatterErr) {
			f.Rule = "AEOS-DOC-006"
			f.Paths = []string{frontmatterErr.Path}
			f.RecommendedAction = "correct the AEOS record frontmatter"
		} else {
			f.Rule = "AEOS-INTERNAL-002"
			f.RecommendedAction = "inspect repository filesystem access and rerun the validator"
			exit = exitInternal
		}
		return reporting.New(project, config.ManifestName, 0, []findings.Finding{f}), exit
	}

	fs := validation.Validate(root, manifest, discovered)
	if manifest.Security.SecretScanRequired {
		secretFindings, scanErr := secrets.Scan(root, os.Getenv("AEOS_GITLEAKS_PATH"))
		if scanErr != nil {
			f := findings.Finding{Severity: findings.Error, Confidence: "verified", Blocking: true}
			switch {
			case errors.Is(scanErr, secrets.ErrUnavailable):
				f.Rule = "AEOS-SEC-010"
				f.Message = "required Gitleaks secret scanner is unavailable"
				f.RecommendedAction = "install the AEOS-pinned Gitleaks version or set AEOS_GITLEAKS_PATH to its executable"
			case errors.Is(scanErr, secrets.ErrUnsupportedVersion):
				f.Rule = "AEOS-SEC-011"
				f.Message = scanErr.Error()
				f.RecommendedAction = "use the AEOS-pinned Gitleaks version; do not bypass version verification"
			default:
				f.Rule = "AEOS-SEC-012"
				f.Message = scanErr.Error()
				f.RecommendedAction = "repair the scanner execution before trusting the security result"
			}
			fs = append(fs, f)
		} else {
			fs = append(fs, secretFindings...)
		}
	}
	report := reporting.New(project, config.ManifestName, len(discovered), fs)
	if report.Summary.Critical > 0 {
		return report, exitCritical
	}
	if report.Summary.Errors > 0 {
		return report, exitValidation
	}
	return report, exitOK
}

func writeReport(w io.Writer, format string, report reporting.Report) error {
	if format == "json" {
		return reporting.JSON(w, report)
	}
	return reporting.Console(w, report)
}
