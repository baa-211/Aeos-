#!/usr/bin/env python3
"""Embed the AEOS report and stage records into the preview interface.

Embedding rather than fetching keeps the interface usable when the file is
opened directly, since browsers block fetch on the file:// origin. The
interface still prefers a live report.json when one is served over HTTP.

This reads AEOS output and records. It never writes to either.
"""
import json
import os
import re
import sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
preview = os.path.join(root, "preview")


def section(text, name):
    m = re.search(r"## " + name + r"\n(.*?)(?=\n## |\Z)", text, re.S)
    return m.group(1).strip() if m else ""


def read_decisions():
    """Decision records, keyed by the stage they belong to.

    Read-only. The interface renders these; resolutions are drafted there and
    exported for a person to write back into the record.
    """
    out = {}
    d = os.path.join(root, "docs", "decisions")
    if not os.path.isdir(d):
        return out
    for fn in sorted(os.listdir(d)):
        if not fn.endswith(".md"):
            continue
        text = open(os.path.join(d, fn)).read()
        rid = re.search(r"^id: (\S+)", text, re.M)
        if not rid:
            continue
        stage = re.search(r'^related_stage: "?([^"\n]+)"?', text, re.M)
        status = re.search(r"^status: (\S+)", text, re.M)
        prio = re.search(r"^priority: (\S+)", text, re.M)
        title = re.search(r"^# \S+ — (.+)$", text, re.M)
        opts = [l.strip() for l in section(text, "Options").split("\n") if l.strip()]
        out.setdefault(stage.group(1) if stage else "unassigned", []).append({
            "id": rid.group(1),
            "title": title.group(1) if title else rid.group(1),
            "status": status.group(1) if status else "undeclared",
            "priority": prio.group(1) if prio else "",
            "question": section(text, "Question"),
            "why": section(text, "Why it is open"),
            "options": opts,
            "blocks": section(text, "Blocks"),
            "resolution": section(text, "Resolution"),
            "path": "docs/decisions/" + fn,
        })
    return out


def read_stages():
    out = {}
    stages_dir = os.path.join(root, "docs", "stages")
    if not os.path.isdir(stages_dir):
        return out
    for fn in sorted(os.listdir(stages_dir)):
        if not fn.endswith(".md"):
            continue
        text = open(os.path.join(stages_dir, fn)).read()
        m = re.search(r"^id: (\S+)", text, re.M)
        if not m:
            continue
        memory = re.findall(r"### (\S+) — (.+?)\n(.*?)(?=\n### |\Z)", section(text, "Memory"), re.S)
        out[m.group(1)] = {
            "purpose": section(text, "Purpose"),
            "principles": [l.strip() for l in section(text, "Principles").split("\n") if l.strip()],
            "protocol": [l.strip() for l in section(text, "Protocol").split("\n") if l.strip()],
            "gate": [l.strip().lstrip("- ") for l in section(text, "Exit Gate").split("\n")
                     if l.strip().startswith("-")],
            "memory": [{"date": d, "title": t, "body": " ".join(b.split())} for d, t, b in memory],
        }
    return out


def main():
    tpl_path = os.path.join(preview, "command.html.tpl")
    rep_path = os.path.join(preview, "report.json")
    for p in (tpl_path, rep_path):
        if not os.path.exists(p):
            sys.exit(f"missing {p}; run preview/build.sh from the repository root")

    html = open(tpl_path).read()
    html = html.replace("__REPORT__", json.dumps(json.load(open(rep_path)), separators=(",", ":")))
    html = html.replace("__STAGES__", json.dumps(read_stages(), separators=(",", ":")))
    html = html.replace("__DECISIONS__", json.dumps(read_decisions(), separators=(",", ":")))
    if "__REPORT__" in html or "__STAGES__" in html or "__DECISIONS__" in html:
        sys.exit("placeholder left unreplaced")

    open(os.path.join(preview, "command.html"), "w").write(html)
    print(f"preview/command.html written ({len(html)} bytes)")


if __name__ == "__main__":
    main()
