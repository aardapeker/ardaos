#!/usr/bin/env python3
"""ArdaOS share — tiny Wi-Fi file server, Python standard library only.

  share.py send    <port> <token> <file-or-folder>
  share.py receive <port> <token> <destination-folder>

Every URL starts with /<token>/ so other people on the network can't guess it.
Prints one line per transfer to stdout. Stop with Ctrl+C.
"""
import html
import os
import sys
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

MODE, PORT, TOKEN, TARGET = sys.argv[1], int(sys.argv[2]), sys.argv[3], os.path.abspath(sys.argv[4])
PREFIX = f"/{TOKEN}/"
CHUNK = 1024 * 256

STYLE = """
body{margin:0;background:#1a1b26;color:#c0caf5;font:16px/1.5 system-ui,sans-serif}
main{max-width:640px;margin:0 auto;padding:24px 16px}
h1{font-size:20px;margin:0 0 4px}.muted{color:#565f89;font-size:14px}
a{color:#7aa2f7;text-decoration:none}
ul{list-style:none;padding:0}li{padding:10px 12px;margin:6px 0;background:#24283b;border-radius:8px;
display:flex;justify-content:space-between;gap:12px}li span{color:#565f89;white-space:nowrap}
label{display:block;padding:32px;border:2px dashed #565f89;border-radius:12px;text-align:center;cursor:pointer}
input{display:none}#log div{padding:8px 12px;margin:6px 0;background:#24283b;border-radius:8px}
.ok{color:#9ece6a}.err{color:#f7768e}
"""


def size(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return f"{n:.0f} {unit}" if unit == "B" else f"{n:.1f} {unit}"
        n /= 1024


def page(title, body):
    return (f"<!doctype html><html><head><meta charset=utf-8>"
            f"<meta name=viewport content='width=device-width,initial-scale=1'>"
            f"<title>{html.escape(title)}</title><style>{STYLE}</style></head>"
            f"<body><main>{body}</main></body></html>").encode()


UPLOAD_JS = """
<script>
const log = document.getElementById('log');
document.getElementById('f').addEventListener('change', async (e) => {
  for (const file of e.target.files) {
    const row = document.createElement('div'); row.textContent = file.name + ' …'; log.prepend(row);
    try {
      const r = await fetch('upload/' + encodeURIComponent(file.name), {method: 'PUT', body: file});
      if (!r.ok) throw new Error(r.status);
      row.innerHTML = '<span class=ok>✓</span> ' + file.name + ' sent';
    } catch (err) { row.innerHTML = '<span class=err>✗</span> ' + file.name + ' failed'; }
  }
  e.target.value = '';
});
</script>"""


def free_name(folder, name):
    """name.txt → name (1).txt when it already exists."""
    base, ext = os.path.splitext(name)
    path, n = os.path.join(folder, name), 1
    while os.path.exists(path):
        path = os.path.join(folder, f"{base} ({n}){ext}")
        n += 1
    return path


class Handler(BaseHTTPRequestHandler):
    server_version = "ArdaOS-share"

    def log_message(self, *args):  # quiet: we print our own lines
        pass

    def reply(self, code, body=b"", ctype="text/html; charset=utf-8"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def path_in_token(self):
        path = urllib.parse.unquote(urllib.parse.urlsplit(self.path).path)
        if path == PREFIX.rstrip("/"):
            return ""
        return path[len(PREFIX):] if path.startswith(PREFIX) else None

    # --- send mode: download page + files ---------------------------------------------
    def send_file(self, path):
        name = os.path.basename(path)
        total = os.path.getsize(path)
        self.send_response(200)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Length", str(total))
        self.send_header("Content-Disposition",
                         "attachment; filename*=UTF-8''" + urllib.parse.quote(name))
        self.end_headers()
        with open(path, "rb") as f:
            while chunk := f.read(CHUNK):
                self.wfile.write(chunk)
        print(f"sent\t{name}\t{size(total)}\t{self.client_address[0]}", flush=True)

    def do_GET(self):
        rel = self.path_in_token()
        if rel is None:
            return self.reply(404, page("Not found", "<h1>Not found</h1>"))
        if MODE == "receive":
            return self.reply(200, page("Send to ArdaOS", (
                "<h1>📥 Send files</h1><p class=muted>They land in the ArdaOS downloads folder.</p>"
                "<label for=f>Tap to pick files</label><input id=f type=file multiple>"
                "<div id=log></div>" + UPLOAD_JS)))
        if os.path.isfile(TARGET):
            if rel in ("", "dl"):
                return self.send_file(TARGET)
            return self.reply(404)
        # a folder: list it, files are under f/<relative path>
        if rel.startswith("f/"):
            want = os.path.realpath(os.path.join(TARGET, rel[2:]))
            if want.startswith(TARGET + os.sep) and os.path.isfile(want):
                return self.send_file(want)
            return self.reply(404, page("Not found", "<h1>Not found</h1>"))
        rows = []
        for root, dirs, files in os.walk(TARGET):
            dirs[:] = sorted(d for d in dirs if not d.startswith("."))
            for name in sorted(files):
                if name.startswith("."):
                    continue
                full = os.path.join(root, name)
                relp = os.path.relpath(full, TARGET)
                rows.append(f"<li><a href='f/{urllib.parse.quote(relp)}'>{html.escape(relp)}</a>"
                            f"<span>{size(os.path.getsize(full))}</span></li>")
                if len(rows) >= 500:
                    break
        self.reply(200, page(os.path.basename(TARGET), (
            f"<h1>📂 {html.escape(os.path.basename(TARGET))}</h1>"
            f"<p class=muted>{len(rows)} files · tap to download</p><ul>{''.join(rows)}</ul>")))

    # --- receive mode: uploads (browser page or curl -T) ---------------------------------
    def do_PUT(self):
        rel = self.path_in_token()
        if MODE != "receive" or rel is None or not rel.startswith("upload"):
            return self.reply(403)
        name = os.path.basename(rel[len("upload"):].strip("/")) or self.headers.get("X-Filename", "file")
        name = name.replace("\x00", "").lstrip(".") or "file"
        length = int(self.headers.get("Content-Length", 0))
        dest = free_name(TARGET, name)
        left = length
        with open(dest, "wb") as f:
            while left > 0:
                chunk = self.rfile.read(min(CHUNK, left))
                if not chunk:
                    break
                f.write(chunk)
                left -= len(chunk)
        if left:
            os.remove(dest)
            return self.reply(400, b"incomplete upload\n", "text/plain")
        print(f"received\t{os.path.basename(dest)}\t{size(length)}\t{self.client_address[0]}", flush=True)
        self.reply(200, b"ok\n", "text/plain")

    do_POST = do_PUT


if __name__ == "__main__":
    os.makedirs(TARGET, exist_ok=True) if MODE == "receive" else None
    try:
        ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
    except KeyboardInterrupt:
        pass
