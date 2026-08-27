package findings

import "sort"

type Severity string

const (
	Info     Severity = "INFO"
	Warning  Severity = "WARNING"
	Error    Severity = "ERROR"
	Critical Severity = "CRITICAL"
)

type Finding struct {
	Rule              string   `json:"rule"`
	Severity          Severity `json:"severity"`
	Confidence        string   `json:"confidence"`
	Message           string   `json:"message"`
	Paths             []string `json:"paths,omitempty"`
	RecommendedAction string   `json:"recommended_action,omitempty"`
	Blocking          bool     `json:"blocking"`
}

func Sort(in []Finding) {
	sort.SliceStable(in, func(i, j int) bool {
		if in[i].Severity != in[j].Severity {
			return rank(in[i].Severity) > rank(in[j].Severity)
		}
		if in[i].Rule != in[j].Rule {
			return in[i].Rule < in[j].Rule
		}
		if in[i].Message != in[j].Message {
			return in[i].Message < in[j].Message
		}
		return firstPath(in[i]) < firstPath(in[j])
	})
}

func HighestSeverity(in []Finding) Severity {
	highest := Info
	for _, f := range in {
		if rank(f.Severity) > rank(highest) {
			highest = f.Severity
		}
	}
	return highest
}

func rank(s Severity) int {
	switch s {
	case Critical:
		return 4
	case Error:
		return 3
	case Warning:
		return 2
	default:
		return 1
	}
}

func firstPath(f Finding) string {
	if len(f.Paths) == 0 {
		return ""
	}
	return f.Paths[0]
}
