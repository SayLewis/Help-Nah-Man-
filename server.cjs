const http = require("http");
const fs = require("fs");
const path = require("path");

const root = __dirname;
const port = Number(process.env.PORT || 4173);
const host = "127.0.0.1";

const mimeTypes = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
};

const server = http.createServer((request, response) => {
  try {
    const url = new URL(request.url, `http://${host}:${port}`);
    const relativePath = decodeURIComponent(url.pathname === "/" ? "index.html" : url.pathname.slice(1));
    const filePath = path.resolve(root, relativePath);

    if (!filePath.startsWith(root)) {
      response.writeHead(403).end("Forbidden");
      return;
    }

    fs.readFile(filePath, (error, data) => {
      if (error) {
        response.writeHead(404).end("Not found");
        return;
      }

      response.writeHead(200, {
        "Content-Type": mimeTypes[path.extname(filePath)] || "application/octet-stream",
      });
      response.end(data);
    });
  } catch {
    response.writeHead(500).end("Server error");
  }
});

server.listen(port, host, () => {
  console.log(`Help Nah Man running at http://${host}:${port}/`);
});
