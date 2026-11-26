#!/usr/bin/env node
// Screenshot a page at several viewports and color schemes, and report
// console errors, failed requests and horizontal overflow.
//
// Usage:
//   node shoot.mjs <url> [--out dir] [--widths 375,768,1440] [--schemes light,dark] [--viewport-only] [--wait ms]
//
// Needs Playwright: it is resolved from the current project first, then globally.
// If missing:  npm i -D playwright && npx playwright install chromium

import { mkdirSync } from "node:fs";
import { createRequire } from "node:module";
import { join, resolve } from "node:path";
import { pathToFileURL } from "node:url";

const args = process.argv.slice(2);
if (!args.length || args.includes("--help")) {
  console.log("Usage: node shoot.mjs <url> [--out dir] [--widths 375,768,1440] [--schemes light,dark] [--viewport-only] [--wait ms]");
  process.exit(args.length ? 0 : 1);
}

const opt = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
let url = args[0];
if (!/^[a-z]+:\/\//i.test(url)) url = pathToFileURL(resolve(url)).href; // allow local html files
const outDir = resolve(opt("out", ".screenshots"));
const widths = opt("widths", "375,768,1440").split(",").map(Number);
const schemes = opt("schemes", "light,dark").split(",");
const fullPage = !args.includes("--viewport-only");
const waitMs = Number(opt("wait", "500"));
const heights = { 375: 812, 390: 844, 768: 1024, 1024: 768, 1280: 800, 1440: 900, 1920: 1080 };

async function loadPlaywright() {
  const require = createRequire(join(process.cwd(), "noop.js"));
  for (const name of ["playwright", "@playwright/test", "playwright-core"]) {
    try { return require(name); } catch {}
    try { return await import(name); } catch {}
  }
  console.error("Playwright not found. Install it in the project:\n  npm i -D playwright && npx playwright install chromium");
  process.exit(2);
}

const { chromium } = await loadPlaywright();
const launchOptions = process.env.PW_CHROMIUM_PATH ? { executablePath: process.env.PW_CHROMIUM_PATH } : {};
const browser = await chromium.launch(launchOptions);
mkdirSync(outDir, { recursive: true });

const report = [];
for (const scheme of schemes) {
  for (const width of widths) {
    const context = await browser.newContext({
      viewport: { width, height: heights[width] ?? 900 },
      colorScheme: scheme === "dark" ? "dark" : "light",
      deviceScaleFactor: 1,
    });
    const page = await context.newPage();
    const consoleErrors = [];
    const failedRequests = [];
    page.on("console", (m) => { if (m.type() === "error") consoleErrors.push(m.text()); });
    page.on("pageerror", (e) => consoleErrors.push(`pageerror: ${e.message}`));
    page.on("requestfailed", (r) => failedRequests.push(`${r.failure()?.errorText ?? "failed"} ${r.url()}`));
    page.on("response", (r) => { if (r.status() >= 400) failedRequests.push(`${r.status()} ${r.url()}`); });

    try {
      await page.goto(url, { waitUntil: "networkidle", timeout: 45_000 });
    } catch {
      await page.goto(url, { waitUntil: "load", timeout: 45_000 });
    }
    // Some apps toggle dark mode with a class rather than the media query.
    if (scheme === "dark") {
      await page.evaluate(() => document.documentElement.classList.add("dark"));
    }
    await page.waitForTimeout(waitMs);

    const overflow = await page.evaluate(() => {
      const docWidth = document.documentElement.scrollWidth;
      const vw = window.innerWidth;
      if (docWidth <= vw) return null;
      const offenders = [...document.querySelectorAll("body *")]
        .filter((el) => el.getBoundingClientRect().right > vw + 1)
        .slice(0, 5)
        .map((el) => `${el.tagName.toLowerCase()}${el.id ? "#" + el.id : ""}${el.className && typeof el.className === "string" ? "." + el.className.trim().split(/\s+/).slice(0, 3).join(".") : ""}`);
      return { docWidth, vw, offenders };
    });

    const file = join(outDir, `${scheme}-${width}.png`);
    await page.screenshot({ path: file, fullPage });
    report.push({ file, scheme, width, consoleErrors, failedRequests, overflow });
    await context.close();
  }
}
await browser.close();

let problems = 0;
for (const r of report) {
  const issues = [];
  if (r.overflow) issues.push(`horizontal overflow: page ${r.overflow.docWidth}px > viewport ${r.overflow.vw}px (e.g. ${r.overflow.offenders.join(", ")})`);
  for (const e of [...new Set(r.consoleErrors)]) issues.push(`console error: ${e}`);
  for (const f of [...new Set(r.failedRequests)]) issues.push(`request: ${f}`);
  problems += issues.length;
  console.log(`\n${r.scheme} @ ${r.width}px -> ${r.file}`);
  console.log(issues.length ? issues.map((i) => `  ! ${i}`).join("\n") : "  ok");
}
console.log(`\n${report.length} screenshots, ${problems} issue(s). Now open each PNG with the Read tool and review it visually.`);
