const fs = require("fs");
const path = require("path");

const root = __dirname;
const outputDir = path.join(root, "dist", "server");
fs.mkdirSync(outputDir, { recursive: true });

const html = fs.readFileSync(path.join(root, "index.html"), "utf8");
const css = fs.readFileSync(path.join(root, "styles.css"), "utf8");
const js = fs.readFileSync(path.join(root, "app.js"), "utf8");
const og = fs.readFileSync(path.join(root, "og.jpg")).toString("base64");

const worker = `
const files = {
  "/": { body: ${JSON.stringify(html)}, type: "text/html; charset=utf-8" },
  "/index.html": { body: ${JSON.stringify(html)}, type: "text/html; charset=utf-8" },
  "/styles.css": { body: ${JSON.stringify(css)}, type: "text/css; charset=utf-8" },
  "/app.js": { body: ${JSON.stringify(js)}, type: "application/javascript; charset=utf-8" },
};
const ogBase64 = ${JSON.stringify(og)};

function decodeBase64(value) {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index);
  return bytes;
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    if (url.pathname === "/og.jpg") {
      return new Response(decodeBase64(ogBase64), {
        headers: { "content-type": "image/jpeg", "cache-control": "public, max-age=86400" },
      });
    }
    const file = files[url.pathname];
    if (!file) return new Response("Not found", { status: 404 });
    return new Response(request.method === "HEAD" ? null : file.body, {
      headers: {
        "content-type": file.type,
        "cache-control": url.pathname === "/" || url.pathname === "/index.html" ? "no-cache" : "public, max-age=3600",
        "x-content-type-options": "nosniff",
        "referrer-policy": "strict-origin-when-cross-origin",
      },
    });
  },
};
`;

fs.writeFileSync(path.join(outputDir, "index.js"), worker);
console.log("Built Help Nah Man for Sites.");
