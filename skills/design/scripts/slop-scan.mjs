#!/usr/bin/env node
// Static scanner for "AI slop" UI patterns in source code.
// Usage: node slop-scan.mjs [dir-or-file ...] [--max N]
// Exit code 1 if any HIGH finding exists (usable in CI / hooks), else 0.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { extname, join, relative } from "node:path";

const args = process.argv.slice(2);
const maxIdx = args.indexOf("--max");
const maxExamples = maxIdx >= 0 ? Number(args[maxIdx + 1]) : 5;
const targets = args.filter((a, i) => !a.startsWith("--") && !(maxIdx >= 0 && i === maxIdx + 1));
if (!targets.length) targets.push(".");

const EXT = new Set([".tsx", ".jsx", ".ts", ".js", ".vue", ".svelte", ".astro", ".html", ".css", ".scss", ".mdx"]);
const SKIP = new Set(["node_modules", ".git", ".next", ".nuxt", ".svelte-kit", "dist", "build", "out", "coverage", ".turbo", ".vercel", "storybook-static"]);

const rules = [
  // id, severity, description, regex (tested per line)
  ["card-trinity", "HIGH", "border + large radius + shadow on one element (generic card)",
    /(?=.*\bborder\b)(?=.*\brounded-(?:lg|xl|2xl|3xl)\b)(?=.*\bshadow(?:-(?:sm|md|lg|xl|2xl))?\b)/],
  ["big-radius", "HIGH", "large radius classes (rounded-xl/2xl/3xl)", /\brounded-(?:xl|2xl|3xl)\b/],
  ["shadow", "MED", "drop shadow on elements (allowed only for floating overlays)", /\bshadow-(?:md|lg|xl|2xl)\b|box-shadow:\s*(?!none|0 0 0)/],
  ["icon-tile", "HIGH", "icon in a colored rounded square (icon tile)",
    /(?=.*\brounded-(?:md|lg|xl|2xl|full)\b)(?=.*\bbg-[a-z]+-(?:50|100|500\/10|500\/20)\b)(?=.*\b(?:h-(?:8|10|12|14)\s+w-(?:8|10|12|14)|size-(?:8|10|12|14)|p-(?:2|2\.5|3))\b)(?=.*\b(?:flex|grid|inline-flex)\b)/],
  ["ai-gradient", "HIGH", "purple/indigo/violet/fuchsia/pink gradient", /\b(?:from|via|to)-(?:purple|indigo|violet|fuchsia|pink)-\d{2,3}\b|linear-gradient\([^)]*(?:purple|violet|indigo|#(?:7c3aed|8b5cf6|6366f1|a855f7|ec4899))/i],
  ["gradient-text", "HIGH", "gradient text (bg-clip-text + text-transparent)", /bg-clip-text[^"'`]*text-transparent|text-transparent[^"'`]*bg-clip-text|background-clip:\s*text/],
  ["glass", "MED", "glassmorphism / backdrop blur", /\bbackdrop-blur(?:-\w+)?\b|backdrop-filter:\s*blur/],
  ["blob", "MED", "blurred decorative blobs", /\bblur-(?:2xl|3xl)\b/],
  ["pill-badge", "MED", "pill badge (rounded-full with border/bg and tiny text)", /(?=.*\brounded-full\b)(?=.*\b(?:border|bg-[a-z]+-(?:50|100))\b)(?=.*\btext-(?:xs|sm)\b)(?=.*\bpx-(?:2|2\.5|3)\b)/],
  ["emoji", "MED", "emoji in markup (use real icons or typography)", /[\u{1F300}-\u{1FAFF}\u{2728}\u{2B50}\u{1F680}\u{26A1}]/u],
  ["placeholder", "HIGH", "placeholder content", /lorem ipsum|John Doe|Jane Doe|Acme(?: Inc| Corp)?\b|Feature (?:One|1)\b/i],
  ["bounce", "LOW", "bouncing / pulsing decoration", /\banimate-(?:bounce|ping)\b/],
  ["big-css-radius", "MED", "CSS border-radius >= 12px", /border-radius:\s*(?:1[2-9]|[2-9]\d)px|border-radius:\s*(?:0\.[89]|[1-9])(?:\.\d+)?rem/],
];

const findings = new Map(rules.map(([id]) => [id, []]));
let files = 0;

function walk(p) {
  let st;
  try { st = statSync(p); } catch { return; }
  if (st.isDirectory()) {
    for (const name of readdirSync(p)) if (!SKIP.has(name)) walk(join(p, name));
  } else if (EXT.has(extname(p))) {
    files++;
    const lines = readFileSync(p, "utf8").split("\n");
    lines.forEach((line, i) => {
      if (line.length > 2000) return; // minified
      for (const [id, , , re] of rules) if (re.test(line)) findings.get(id).push(`${relative(process.cwd(), p)}:${i + 1}`);
    });
  }
}
targets.forEach(walk);

// Second pass: CSS rule blocks (plain CSS / <style>), where card styling spans several lines.
const cssRules = [
  ["css-card-trinity", "HIGH", "CSS rule with border + radius >= 8px + shadow (generic card)",
    (b) => /(^|[;{\s])border(-[a-z]+)?\s*:\s*[^;]*\d+px/.test(b) && radiusPx(b) >= 8 && /box-shadow\s*:\s*(?!none)/.test(b)],
  ["css-card", "MED", "CSS rule with border + radius >= 10px (boxed card)",
    (b) => /(^|[;{\s])border\s*:\s*[^;]*\d+px/.test(b) && radiusPx(b) >= 10],
  ["css-icon-circle", "MED", "small fixed-size circle/rounded box with background (icon tile)",
    (b) => /(width|inline-size)\s*:\s*(2[4-9]|3\d|4[0-8])px/.test(b) && /(height|block-size)\s*:\s*(2[4-9]|3\d|4[0-8])px/.test(b) && (radiusPx(b) >= 8 || /border-radius\s*:\s*50%/.test(b)) && /background/.test(b)],
];
function radiusPx(b) {
  const m = b.match(/border-radius\s*:\s*([0-9.]+)(px|rem)/);
  if (!m) return 0;
  return m[2] === "rem" ? parseFloat(m[1]) * 16 : parseFloat(m[1]);
}
for (const [id, , ] of cssRules) findings.set(id, []);
function scanCss(p) {
  const text = readFileSync(p, "utf8");
  const re = /([^{}]+)\{([^{}]*)\}/g;
  let m;
  while ((m = re.exec(text))) {
    const sel = m[1].trim().split("\n").pop().trim();
    if (/tooltip|(^|[^a-z])tip([^a-z]|$)|popover|dropdown|menu|dialog|modal|toast|overlay/i.test(sel)) continue; // floating layers may have shadows
    const line = text.slice(0, m.index + m[1].length).split("\n").length;
    for (const [id, , , test] of cssRules) if (test(m[2])) findings.get(id).push(`${relative(process.cwd(), p)}:${line} ${sel.slice(0, 40)}`);
  }
}
function walkCss(p) {
  let st; try { st = statSync(p); } catch { return; }
  if (st.isDirectory()) { for (const n of readdirSync(p)) if (!SKIP.has(n)) walkCss(join(p, n)); }
  else if ([".css", ".scss", ".html", ".vue", ".svelte", ".astro"].includes(extname(p))) scanCss(p);
}
targets.forEach(walkCss);
rules.push(...cssRules.map(([id, sev, desc]) => [id, sev, desc, null]));

let high = 0;
let total = 0;
console.log(`slop-scan: ${files} files scanned\n`);
for (const [id, sev, desc] of rules) {
  const hits = findings.get(id);
  if (!hits.length) continue;
  total += hits.length;
  if (sev === "HIGH") high += hits.length;
  console.log(`[${sev}] ${id} (${hits.length}) - ${desc}`);
  for (const h of hits.slice(0, maxExamples)) console.log(`    ${h}`);
  if (hits.length > maxExamples) console.log(`    ... +${hits.length - maxExamples} more`);
}
if (!total) console.log("No slop patterns found. Still check the rendered screenshots.");
else console.log(`\n${total} finding(s), ${high} HIGH. Fix them or justify each one against the brief.`);
process.exit(high ? 1 : 0);
