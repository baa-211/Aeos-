#!/usr/bin/env python3
"""Local server for the AEOS command interface.

Serves the repository and exposes a narrow write API so a note or a decision
resolution written in the interface lands in the record it belongs to, instead
of passing through the clipboard.

Boundaries, and why they are where they are:

  * Binds to 127.0.0.1 only. This is a local tool; it is never a service.
  * Writes are confined to Markdown files that already exist under docs/.
    No creation, no deletion, no path outside the tree, no non-Markdown target.
  * Every write is an append under a named heading or a replacement of a named
    section. Nothing rewrites a file wholesale.
  * Git is never touched implicitly. Staging and committing are separate calls
    the person makes deliberately, and the diff is returned first.
  * The validator is not invoked from here. AEOS output stays something the
    person runs, so the interface can never appear to certify its own edits.
"""

import http.server
import json
import os
import re
import shutil
import socketserver
import subprocess
import sys
import tempfile
import urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
PORT = int(os.environ.get("AEOS_PREVIEW_PORT", "8000"))
MAX_BODY = 256 * 1024


class Rejected(Exception):
    pass


def safe_record(rel):
    """Resolve a caller-supplied path to a writable record, or refuse."""
    if not isinstance(rel, str) or not rel.strip():
        raise Rejected("no path given")
    if "\x00" in rel:
        raise Rejected("illegal path")
    target = os.path.realpath(os.path.join(ROOT, rel))
    docs = os.path.realpath(DOCS)
    if os.path.commonpath([target, docs]) != docs:
        raise Rejected(f"outside docs/: {rel}")
    if not target.endswith(".md"):
        raise Rejected("only Markdown records are writable")
    if not os.path.isfile(target):
        raise Rejected(f"no such record: {rel}")
    if os.path.islink(os.path.join(ROOT, rel)):
        raise Rejected("symlinked records are not writable")
    return target


def atomic_write(path, text):
    """Write via a temporary file in the same directory, then replace."""
    d = os.path.dirname(path)
    fd, tmp = tempfile.mkstemp(dir=d, suffix=".aeos-tmp")
    try:
        with os.fdopen(fd, "w") as f:
            f.write(text)
        shutil.copymode(path, tmp)
        os.replace(tmp, path)
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def append_under(text, heading, block):
    """Append a block at the end of the named section, before the next one."""
    m = re.search(r"^## " + re.escape(heading) + r"\s*$", text, re.M)
    if not m:
        raise Rejected(f"record has no '## {heading}' section")
    rest = text[m.end():]
    nxt = re.search(r"^## ", rest, re.M)
    cut = m.end() + (nxt.start() if nxt else len(rest))
    head, tail = text[:cut], text[cut:]
    return head.rstrip("\n") + "\n\n" + block.strip("\n") + "\n\n" + tail.lstrip("\n")


def replace_section(text, heading, body):
    m = re.search(r"^## " + re.escape(heading) + r"\s*$", text, re.M)
    if not m:
        raise Rejected(f"record has no '## {heading}' section")
    rest = text[m.end():]
    nxt = re.search(r"^## ", rest, re.M)
    cut = m.end() + (nxt.start() if nxt else len(rest))
    return text[:m.end()] + "\n" + body.strip("\n") + "\n\n" + text[cut:].lstrip("\n")


def set_front_matter(text, key, value):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        raise Rejected("record has no frontmatter")
    fm = m.group(1)
    line = f"{key}: {value}"
    if re.search(rf"^{re.escape(key)}:", fm, re.M):
        fm = re.sub(rf"^{re.escape(key)}:.*$", line, fm, count=1, flags=re.M)
    else:
        fm = fm + "\n" + line
    return f"---\n{fm}\n---\n" + text[m.end():]


def git(*args):
    return subprocess.run(["git", "-C", ROOT, *args],
                          capture_output=True, text=True, timeout=30)


def diff_for(paths):
    r = git("diff", "--", *paths) if paths else git("diff")
    return r.stdout


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=ROOT, **kw)

    def log_message(self, fmt, *args):
        if self.path.startswith("/api/"):
            sys.stderr.write("  %s %s\n" % (self.command, self.path))

    def _send(self, code, payload):
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _body(self):
        n = int(self.headers.get("Content-Length") or 0)
        if n > MAX_BODY:
            raise Rejected("request too large")
        return json.loads(self.rfile.read(n) or b"{}")

    def do_GET(self):
        route = urllib.parse.urlparse(self.path).path
        if route == "/api/ping":
            return self._send(200, {"ok": True, "root": os.path.basename(ROOT)})
        if route == "/api/git/status":
            st = git("status", "--porcelain")
            br = git("rev-parse", "--abbrev-ref", "HEAD")
            return self._send(200, {
                "ok": True,
                "branch": br.stdout.strip(),
                "dirty": [l[3:] for l in st.stdout.splitlines()],
            })
        return super().do_GET()

    def do_POST(self):
        route = urllib.parse.urlparse(self.path).path
        try:
            data = self._body()
            if route == "/api/record/append":
                return self._append(data)
            if route == "/api/decision/resolve":
                return self._resolve(data)
            if route == "/api/git/commit":
                return self._commit(data)
            return self._send(404, {"ok": False, "error": "no such endpoint"})
        except Rejected as e:
            return self._send(400, {"ok": False, "error": str(e)})
        except Exception as e:
            return self._send(500, {"ok": False, "error": f"{type(e).__name__}: {e}"})

    # ── writes ──

    def _append(self, d):
        path = safe_record(d.get("path"))
        block = d.get("block") or ""
        if not block.strip():
            raise Rejected("nothing to append")
        heading = d.get("heading") or "Memory"
        text = open(path).read()
        atomic_write(path, append_under(text, heading, block))
        rel = os.path.relpath(path, ROOT)
        return self._send(200, {"ok": True, "path": rel, "diff": diff_for([rel])})

    def _resolve(self, d):
        path = safe_record(d.get("path"))
        body = d.get("resolution") or ""
        status = d.get("status") or "accepted"
        if not body.strip():
            raise Rejected("no resolution given")
        if not re.fullmatch(r"[a-z_]{3,20}", status):
            raise Rejected("invalid status")
        text = open(path).read()
        text = replace_section(text, "Resolution", body)
        text = set_front_matter(text, "status", status)
        text = set_front_matter(text, "updated", d.get("date") or "")
        atomic_write(path, text)
        rel = os.path.relpath(path, ROOT)
        return self._send(200, {"ok": True, "path": rel, "diff": diff_for([rel])})

    def _commit(self, d):
        paths = d.get("paths") or []
        message = (d.get("message") or "").strip()
        if not paths:
            raise Rejected("nothing to commit")
        if not message:
            raise Rejected("a commit needs a message")
        rels = [os.path.relpath(safe_record(p), ROOT) for p in paths]
        add = git("add", "--", *rels)
        if add.returncode != 0:
            raise Rejected(add.stderr.strip() or "git add failed")
        com = git("-c", "commit.gpgsign=false", "commit", "-m", message, "--", *rels)
        if com.returncode != 0:
            raise Rejected(com.stderr.strip() or com.stdout.strip() or "git commit failed")
        sha = git("rev-parse", "--short", "HEAD").stdout.strip()
        return self._send(200, {"ok": True, "sha": sha, "paths": rels,
                                "output": com.stdout.strip()})


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def main():
    os.chdir(ROOT)
    with Server(("127.0.0.1", PORT), Handler) as httpd:
        print(f"AEOS preview  →  http://localhost:{PORT}/preview/command.html")
        print(f"repository    →  {ROOT}")
        print("writes are confined to existing Markdown records under docs/")
        print("Ctrl-C to stop.\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nstopped")


if __name__ == "__main__":
    main()
