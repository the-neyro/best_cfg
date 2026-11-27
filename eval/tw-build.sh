#!/usr/bin/env bash
# Replaces the Tailwind Play CDN in an HTML file with a locally compiled stylesheet,
# so pages can be screenshotted in sandboxes where the CDN is blocked.
# usage: tw-build.sh <dir-with-index.html>   -> writes <dir>/index.local.html + tw.css
set -euo pipefail
dir="$1"; cd "$dir"
html=index.html
grep -q 'cdn.tailwindcss.com' "$html" || { cp "$html" index.local.html; echo "no tailwind cdn"; exit 0; }
ver="$(grep -oE 'cdn\.tailwindcss\.com/?[0-9.]*' "$html" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)"
ver="${ver:-3.4.16}"
python3 - "$html" <<'EOF'
import re, sys
s = open(sys.argv[1]).read()
m = re.search(r"tailwind\.config\s*=\s*(\{.*?\})\s*;?\s*</script>", s, re.S)
body = m.group(1) if m else "{}"
open("tailwind.config.js", "w").write("module.exports = Object.assign(" + body + ", { content: ['./index.html'] });\n")
s = re.sub(r'<script[^>]*cdn\.tailwindcss\.com[^>]*></script>', '<link rel="stylesheet" href="tw.css">', s)
s = re.sub(r"<script>\s*tailwind\.config\s*=.*?</script>", "", s, count=1, flags=re.S)
open("index.local.html", "w").write(s)
EOF
printf '@tailwind base;\n@tailwind components;\n@tailwind utilities;\n' > tw-in.css
npx -y "tailwindcss@$ver" -c tailwind.config.js -i tw-in.css -o tw.css --minify >/dev/null 2>&1
echo "built tw.css with tailwind $ver"
