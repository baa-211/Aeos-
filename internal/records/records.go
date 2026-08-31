package records

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

var ErrInvalidFrontmatter = errors.New("invalid AEOS frontmatter")

type FrontmatterError struct {
	Path string
	Err  error
}

func (e *FrontmatterError) Error() string {
	return fmt.Sprintf("%s in %s: %v", ErrInvalidFrontmatter, e.Path, e.Err)
}

func (e *FrontmatterError) Unwrap() error { return ErrInvalidFrontmatter }

// Record is the minimal normalized representation required by M2.
// Additional typed fields and relationship parsing belong to later milestones.
type Record struct {
	Type       string
	ID         string
	Status     string
	Version    string
	Path       string
	References []string
}

// Discover finds AEOS Markdown records in the project root and docs tree.
// It intentionally does not follow symlinked files or directories.
func Discover(root string) ([]Record, error) {
	var paths []string

	for _, name := range []string{"PROJECT.md", "STATUS.md"} {
		path := filepath.Join(root, name)
		info, err := os.Lstat(path)
		if err == nil {
			if info.Mode()&os.ModeSymlink == 0 && info.Mode().IsRegular() {
				paths = append(paths, path)
			}
		} else if !errors.Is(err, os.ErrNotExist) {
			return nil, fmt.Errorf("inspect %s: %w", path, err)
		}
	}

	docsRoot := filepath.Join(root, "docs")
	if info, err := os.Lstat(docsRoot); err == nil && info.IsDir() && info.Mode()&os.ModeSymlink == 0 {
		err = filepath.WalkDir(docsRoot, func(path string, d os.DirEntry, walkErr error) error {
			if walkErr != nil {
				return walkErr
			}
			if d.Type()&os.ModeSymlink != 0 {
				if d.IsDir() {
					return filepath.SkipDir
				}
				return nil
			}
			if d.IsDir() {
				return nil
			}
			if !strings.EqualFold(filepath.Ext(d.Name()), ".md") {
				return nil
			}
			paths = append(paths, path)
			return nil
		})
		if err != nil {
			return nil, fmt.Errorf("walk docs: %w", err)
		}
	} else if err != nil && !errors.Is(err, os.ErrNotExist) {
		return nil, fmt.Errorf("inspect docs directory: %w", err)
	}

	sort.Strings(paths)
	out := make([]Record, 0, len(paths))
	for _, path := range paths {
		record, ok, err := parseFile(root, path)
		if err != nil {
			return nil, err
		}
		if ok {
			out = append(out, record)
		}
	}
	return out, nil
}

func parseFile(root, path string) (Record, bool, error) {
	f, err := os.Open(path)
	if err != nil {
		return Record{}, false, fmt.Errorf("open record %s: %w", path, err)
	}
	defer f.Close()

	record, ok, err := parseFrontmatter(f)
	if err != nil {
		rel, relErr := filepath.Rel(root, path)
		if relErr != nil {
			rel = path
		}
		return Record{}, false, &FrontmatterError{Path: filepath.ToSlash(rel), Err: err}
	}
	if !ok {
		return Record{}, false, nil
	}

	rel, err := filepath.Rel(root, path)
	if err != nil {
		return Record{}, false, fmt.Errorf("relative record path: %w", err)
	}
	record.Path = filepath.ToSlash(rel)
	return record, true, nil
}

func parseFrontmatter(r io.Reader) (Record, bool, error) {
	scanner := bufio.NewScanner(r)
	scanner.Buffer(make([]byte, 1024), 1024*1024)

	if !scanner.Scan() {
		if err := scanner.Err(); err != nil {
			return Record{}, false, err
		}
		return Record{}, false, nil
	}
	if strings.TrimSpace(scanner.Text()) != "---" {
		return Record{}, false, nil
	}

	values := map[string]string{}
	lists := map[string][]string{}
	var currentList string
	lineNo := 1
	closed := false
	for scanner.Scan() {
		lineNo++
		raw := scanner.Text()
		line := strings.TrimSpace(raw)
		if line == "---" {
			closed = true
			break
		}
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// M3 supports only simple frontmatter: top-level scalar keys and
		// indented lists of scalar AEOS record IDs. It remains intentionally
		// narrower than general YAML.
		if strings.HasPrefix(line, "-") {
			if currentList == "" {
				continue
			}
			item := strings.Trim(strings.TrimSpace(strings.TrimPrefix(line, "-")), `"'`)
			if item != "" {
				lists[currentList] = append(lists[currentList], item)
			}
			continue
		}
		if strings.HasPrefix(line, "[") || strings.HasPrefix(line, "{") || strings.ContainsAny(line, "&*!|") {
			continue
		}
		parts := strings.SplitN(line, ":", 2)
		if len(parts) != 2 || strings.TrimSpace(parts[0]) == "" {
			return Record{}, false, fmt.Errorf("line %d: expected key: value", lineNo)
		}
		key := strings.TrimSpace(parts[0])
		value := strings.Trim(strings.TrimSpace(parts[1]), `"'`)
		values[key] = value
		currentList = ""
		if value == "" && isReferenceKey(key) {
			currentList = key
		}
		if strings.HasPrefix(value, "[") && strings.HasSuffix(value, "]") && isReferenceKey(key) {
			body := strings.TrimSpace(strings.TrimSuffix(strings.TrimPrefix(value, "["), "]"))
			if body != "" {
				for _, part := range strings.Split(body, ",") {
					item := strings.Trim(strings.TrimSpace(part), `"'`)
					if item != "" {
						lists[key] = append(lists[key], item)
					}
				}
			}
		}
	}
	if err := scanner.Err(); err != nil {
		return Record{}, false, err
	}
	if !closed {
		return Record{}, false, errors.New("frontmatter is not closed")
	}

	recordType := values["aeos_record"]
	if recordType == "" {
		return Record{}, false, nil
	}
	id := values["id"]
	if id == "" {
		switch recordType {
		case "PROJECT":
			id = values["project_id"]
		case "STATUS":
			id = "STATUS"
		}
	}
	if id == "" {
		return Record{}, false, errors.New("AEOS record is missing id")
	}

	var refs []string
	for key, value := range values {
		if isReferenceKey(key) && value != "" && !(strings.HasPrefix(value, "[") && strings.HasSuffix(value, "]")) {
			refs = append(refs, value)
		}
	}
	for key, items := range lists {
		if isReferenceKey(key) {
			refs = append(refs, items...)
		}
	}
	refs = uniqueSorted(refs)

	return Record{Type: recordType, ID: id, Status: values["status"], Version: values["version"], References: refs}, true, nil
}

func isReferenceKey(key string) bool {
	if strings.HasPrefix(key, "related_") {
		return true
	}
	switch key {
	case "supersedes", "superseded_by", "related_change", "related_strategy", "changes", "requirements", "adrs", "bugs", "security", "data":
		return true
	default:
		return false
	}
}

func uniqueSorted(in []string) []string {
	seen := map[string]struct{}{}
	out := make([]string, 0, len(in))
	for _, v := range in {
		v = strings.TrimSpace(v)
		if v == "" {
			continue
		}
		if _, ok := seen[v]; ok {
			continue
		}
		seen[v] = struct{}{}
		out = append(out, v)
	}
	sort.Strings(out)
	return out
}
