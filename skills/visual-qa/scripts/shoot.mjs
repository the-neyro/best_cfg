#!/usr/bin/env node
// Screenshot a page at several viewports and color schemes, and report
// console errors, failed requests and horizontal overflow.
//
// Usage:
//   node shoot.mjs <url> [--out dir] [--widths 375,768,1440] [--schemes light,dark] [--viewport-only] [--wait ms] [--app] [--no-audit]
// Also runs a design audit on computed styles: fonts, radius > 4px, static shadows, h1 count,
// words and actions in the first screen, tiny text and tap targets, left-edge alignment.
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
const noAudit = args.includes("--no-audit");
const appMode = args.includes("--app"); // dashboards, CRMs, admin UIs: skip marketing content-density checks
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
    const audit = noAudit ? null : await page.evaluate(() => {
      const vis = (el) => { const r = el.getBoundingClientRect(); const cs = getComputedStyle(el); return r.width > 0 && r.height > 0 && cs.visibility !== "hidden" && cs.display !== "none" && cs.opacity !== "0"; };
      const all = [...document.body.querySelectorAll("*")].filter(vis);
      const floating = (el) => !!el.closest('[role="dialog"],[role="menu"],[role="tooltip"],[role="listbox"],dialog,[popover]') || /tooltip|popover|dropdown|menu|toast|modal/i.test(el.className && el.className.toString ? el.className.toString() : "") || ["fixed", "sticky"].includes(getComputedStyle(el).position);
      const textEls = all.filter((el) => [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim().length > 1));
      const fam = new Set(textEls.map((el) => getComputedStyle(el).fontFamily.split(",")[0].replace(/["']/g, "").trim()).filter((f) => !/mono|code|courier/i.test(f)));
      const textColors = new Set(textEls.map((el) => getComputedStyle(el).color));
      const rounded = all.filter((el) => { const cs = getComputedStyle(el); const r = parseFloat(cs.borderTopLeftRadius) || 0; const isCircle = cs.borderTopLeftRadius.includes("%") || r >= Math.min(el.offsetWidth, el.offsetHeight) / 2 - 1; return r > 4 && !isCircle && el.offsetWidth > 60 && !floating(el); });
      const shadowed = all.filter((el) => { const bs = getComputedStyle(el).boxShadow; return bs !== "none" && !/inset/.test(bs) && !floating(el) && el.offsetWidth > 60; });
      const vh = innerHeight;
      const aboveFold = textEls.filter((el) => el.getBoundingClientRect().top < vh);
      const words = aboveFold.map((el) => [...el.childNodes].filter((n) => n.nodeType === 3).map((n) => n.textContent).join(" ")).join(" ").split(/\s+/).filter(Boolean).length;
      // primary actions = filled buttons / button-links outside forms and interactive widgets
      const filled = (el) => { const bg = getComputedStyle(el).backgroundColor; return bg !== "rgba(0, 0, 0, 0)" && bg !== "transparent"; };
      const actions = all.filter((el) => el.getBoundingClientRect().top < vh && ["BUTTON", "A"].includes(el.tagName) && filled(el) && el.offsetHeight >= 30 && !el.closest("header,nav,form,fieldset,[role=group],[role=application],[role=toolbar],[role=tablist]")).length;
      const h1 = document.querySelectorAll("h1").length;
      const small = textEls.filter((el) => parseFloat(getComputedStyle(el).fontSize) < 12).length;
      const taps = [...document.querySelectorAll("a,button,input,select,textarea,[role=button]")].filter(vis).filter((el) => { const r = el.getBoundingClientRect(); return r.height < 24 || r.width < 24; }).length;
      const blocks = [...document.querySelectorAll("main p, main h1, main h2, main h3, section p, section h1, section h2, section h3, body > * h1, body > * h2")].filter(vis);
      const lefts = new Set(blocks.map((el) => Math.round(el.getBoundingClientRect().left / 4) * 4).filter((x) => x > 0 && x < innerWidth / 2));
      const samples = (els) => els.slice(0, 3).map((el) => el.tagName.toLowerCase() + (el.className && el.className.toString ? "." + el.className.toString().trim().split(/\s+/).slice(0, 2).join(".") : "")).join(", ");
      return { fonts: [...fam], textColors: textColors.size, rounded: rounded.length, roundedEx: samples(rounded), shadowed: shadowed.length, shadowEx: samples(shadowed), words, actions, h1, small, taps, leftEdges: lefts.size };
    });
    report.push({ file, scheme, width, consoleErrors, failedRequests, overflow, audit });
    await context.close();
  }
}
await browser.close();

let problems = 0;
for (const r of report) {
  const issues = [];
  if (r.overflow) issues.push(`horizontal overflow: page ${r.overflow.docWidth}px > viewport ${r.overflow.vw}px (e.g. ${r.overflow.offenders.join(", ")})`);
  const A = r.audit;
  if (A) {
    if (A.fonts.length > 2) issues.push(`design: ${A.fonts.length} font families (${A.fonts.join(", ")}) - max 2`);
    if (A.rounded > 0) issues.push(`design: ${A.rounded} element(s) with radius > 4px (e.g. ${A.roundedEx})`);
    if (A.shadowed > 0) issues.push(`design: ${A.shadowed} static element(s) with box-shadow (e.g. ${A.shadowEx})`);
    if (A.h1 !== 1) issues.push(`content: ${A.h1} h1 elements - expected exactly 1`);
    if (!appMode && A.words > 160) issues.push(`content: ${A.words} words in the first screen - aim for ~60-80 (use --app for dashboards/apps)`);
    if (!appMode && A.actions > 2) issues.push(`content: ${A.actions} filled buttons/button-links in the first screen - max 2 primary actions`);
    if (A.small > 0) issues.push(`a11y: ${A.small} text element(s) below 12px`);
    if (r.width <= 480 && A.taps > 0) issues.push(`a11y: ${A.taps} tap target(s) smaller than 24px`);
    if (A.leftEdges > 4) issues.push(`layout: ${A.leftEdges} different left text edges - align to a shared grid`);
  }
  for (const e of [...new Set(r.consoleErrors)]) issues.push(`console error: ${e}`);
  for (const f of [...new Set(r.failedRequests)]) issues.push(`request: ${f}`);
  problems += issues.length;
  console.log(`\n${r.scheme} @ ${r.width}px -> ${r.file}`);
  console.log(issues.length ? issues.map((i) => `  ! ${i}`).join("\n") : "  ok");
}
console.log(`\n${report.length} screenshots, ${problems} issue(s). Now open each PNG with the Read tool and review it visually.`);
