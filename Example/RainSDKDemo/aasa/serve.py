#!/usr/bin/env python3
"""
Local AASA (Apple App Site Association) server for passkey testing.

Serves the file at ./.well-known/apple-app-site-association with the
correct Content-Type so iOS's swcd will accept it. Run alongside
`ngrok http 8080` (or any HTTPS tunnel) to expose it to the simulator.

Usage:
    python3 serve.py [port]   # default port 8080
"""
import http.server
import socketserver
import sys
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
ROOT = Path(__file__).parent


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        if self.path.endswith("apple-app-site-association"):
            self.send_header("Content-Type", "application/json")
        super().end_headers()


socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving AASA on http://localhost:{PORT}")
    print(f"  -> {ROOT}/.well-known/apple-app-site-association")
    print("Run `ngrok http {0}` in another terminal to expose over HTTPS.".format(PORT))
    httpd.serve_forever()
