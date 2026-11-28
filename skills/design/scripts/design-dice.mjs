#!/usr/bin/env node
// Design dice: proposes 3 deliberately different design concepts so every project
// does not end up with the same 2-3 looks. Avoids what was used recently
// (history file) and mixes a fitting pick with a wildcard.
//
// Usage:
//   node design-dice.mjs "<brief / domain keywords>" [--cyrillic if the site has Russian text] [--seed N]
//   node design-dice.mjs --log '{"project":"x","composition":"…","type":"…","palette":"…","signature":"…"}'
// History: $DESIGN_HISTORY or ~/.claude/design-history.jsonl

import { appendFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const HISTORY = process.env.DESIGN_HISTORY || join(homedir(), ".claude", "design-history.jsonl");
const args = process.argv.slice(2);

if (args[0] === "--log") {
  const entry = { date: new Date().toISOString().slice(0, 10), ...JSON.parse(args[1] || "{}") };
  mkdirSync(dirname(HISTORY), { recursive: true });
  appendFileSync(HISTORY, JSON.stringify(entry) + "\n");
  console.log(`logged to ${HISTORY}`);
  process.exit(0);
}

const seedArg = args.indexOf("--seed");
const brief = args.filter((a, i) => !a.startsWith("--") && !(seedArg >= 0 && i === seedArg + 1)).join(" ").toLowerCase();
// Cyrillic only when the SITE has Russian text - pass --cyrillic; the brief language does not matter.
const needCyr = args.includes("--cyrillic");
let seed = seedArg >= 0 ? Number(args[seedArg + 1]) : Date.now() ^ [...brief].reduce((h, c) => (h * 31 + c.charCodeAt(0)) | 0, 7);
const rand = () => ((seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff);
const pick = (arr) => arr[Math.floor(rand() * arr.length)];

// tags: which subjects a choice suits (matched against the brief); [] = universal
const COMPOSITIONS = [
  { id: "typographic-poster", fam: ["refined", "bold", "technical"], tags: ["agency", "event", "culture", "manifest", "law", "studio"], desc: "Type only, full width, one huge statement; no hero image." },
  { id: "full-bleed-photo", fam: ["refined", "warm"], tags: ["restaurant", "bar", "wine", "hotel", "travel", "fashion", "real estate", "café", "food"], desc: "Edge-to-edge art-directed photo with type set into it." },
  { id: "product-first", fam: ["technical", "refined"], tags: ["saas", "app", "software", "tool", "devops", "crm", "dashboard", "monitoring"], desc: "The real product UI/object is the hero, large and crisp; copy small beside or below." },
  { id: "editorial", fam: ["refined", "warm"], tags: ["magazine", "blog", "consulting", "law", "health", "school", "nonprofit"], desc: "Centered headline + lead paragraph + wide image band, magazine rhythm." },
  { id: "asymmetric-collage", fam: ["bold", "warm"], tags: ["creative", "kids", "school", "music", "art", "event", "youth"], desc: "Overlapping images, shapes and type on an off-grid composition." },
  { id: "data-first", fam: ["technical", "refined", "bold"], tags: ["finance", "analytics", "energy", "climate", "monitoring", "report", "impact"], desc: "One striking number or live chart dominates the first screen." },
  { id: "index-list", fam: ["refined", "technical"], tags: ["agency", "portfolio", "architecture", "studio", "menu", "wine"], desc: "A typographic list/table of contents is the hero (projects, wines, services)." },
  { id: "manifesto", fam: ["refined", "bold", "warm"], tags: ["brand", "nonprofit", "startup", "values", "coffee"], desc: "Several sentences of large type, read like a statement; no buttons above the fold except one." },
  { id: "grid-mosaic", fam: ["warm", "refined", "bold"], tags: ["portfolio", "shop", "fashion", "photography", "real estate"], desc: "Dense grid of real work/products with varying tile sizes, no frames." },
  { id: "conversational", fam: ["warm", "technical"], tags: ["ai", "support", "insurance", "health", "bank"], desc: "Hero as a dialogue: question, answer, follow-up - the product's tone made visible." },
  { id: "place-first", fam: ["warm", "refined", "bold"], tags: ["local", "restaurant", "bar", "workshop", "werkstatt", "garage", "clinic", "school", "city"], desc: "Map, street, building or neighbourhood as the visual anchor." },
  { id: "horizontal-strip", fam: ["bold", "warm", "technical"], tags: ["timeline", "history", "process", "event", "festival"], desc: "A horizontal band (timeline, film strip, schedule) carries the story." },
  { id: "split-with-tool", fam: ["technical", "refined", "warm", "bold"], tags: ["calculator", "configurator", "law", "insurance", "booking"], desc: "Headline beside a working tool. ONLY if a tool is the main promise - this is the config's own overused default." },
];

const TYPE = [
  { id: "Source Serif 4 + Source Sans 3", mood: "calm classic", fam: "refined", cyr: true, tags: ["law", "consulting", "publishing", "health"] },
  { id: "EB Garamond + IBM Plex Sans", mood: "scholarly", fam: "refined", cyr: true, tags: ["law", "school", "consulting", "publishing"] },
  { id: "Cormorant Garamond + Commissioner", mood: "quiet luxury", fam: "refined", cyr: true, tags: ["fashion", "hotel", "real estate", "wine", "beauty"] },
  { id: "Spectral + Golos Text", mood: "refined calm", fam: "refined", cyr: true, tags: ["health", "consulting", "finance"] },
  { id: "PT Serif + PT Sans", mood: "solid civic", fam: "refined", cyr: true, tags: ["public", "nonprofit", "law"] },
  { id: "Libre Caslon Display + Libre Franklin", mood: "old-world elegant", fam: "refined", cyr: "check", tags: ["law", "wine", "hotel", "bookshop"] },
  { id: "Bodoni Moda + Albert Sans", mood: "high-contrast fashion", fam: "refined", cyr: "check", tags: ["fashion", "beauty", "jewelry", "gallery"] },
  { id: "Brygada 1918 + Karla", mood: "heritage", fam: "refined", cyr: "check", tags: ["wine", "craft", "manufactory", "family business"] },
  { id: "Newsreader + Public Sans", mood: "newspaper", fam: "refined", cyr: "check", tags: ["editorial", "magazine", "nonprofit", "report"] },
  { id: "Literata + Commissioner", mood: "bookish warm", fam: "warm", cyr: true, tags: ["blog", "education", "nonprofit", "school"] },
  { id: "Alegreya + Alegreya Sans", mood: "literary humanist", fam: "warm", cyr: true, tags: ["culture", "bookshop", "school", "café"] },
  { id: "Piazzolla + Onest", mood: "friendly serif", fam: "warm", cyr: true, tags: ["café", "bakery", "family", "local", "kids"] },
  { id: "Vollkorn + Hanken Grotesk", mood: "hearty", fam: "warm", cyr: "check", tags: ["food", "restaurant", "bar", "brewery", "wine"] },
  { id: "Young Serif + Work Sans", mood: "retro warm", fam: "warm", cyr: "check", tags: ["café", "bar", "event", "food"] },
  { id: "Gloock + Schibsted Grotesk", mood: "quirky editorial", fam: "warm", cyr: "check", tags: ["startup", "creative", "food", "agency"] },
  { id: "Petrona + Atkinson Hyperlegible", mood: "clear & kind", fam: "warm", cyr: "check", tags: ["health", "family", "care", "public", "kids"] },
  { id: "IBM Plex Sans + IBM Plex Mono", mood: "engineering", fam: "technical", cyr: true, tags: ["devops", "industrial", "monitoring", "data", "saas"] },
  { id: "Golos Text + JetBrains Mono", mood: "technical clear", fam: "technical", cyr: true, tags: ["devops", "saas", "monitoring", "developer", "crm"] },
  { id: "Onest (one family)", mood: "friendly neutral", fam: "technical", cyr: true, tags: ["app", "service", "local", "crm", "erp"] },
  { id: "Hanken Grotesk + Martian Mono", mood: "precise modern", fam: "technical", cyr: "check", tags: ["saas", "finance", "b2b", "analytics"] },
  { id: "Red Hat Display + Red Hat Mono", mood: "open tech", fam: "technical", cyr: "check", tags: ["developer", "community", "platform", "devops", "saas"] },
  { id: "Familjen Grotesk + Azeret Mono", mood: "Swiss-ish precise", fam: "technical", cyr: "check", tags: ["agency", "b2b", "architecture", "finance", "monitoring", "saas"] },
  { id: "Big Shoulders Display + Barlow", mood: "industrial loud", fam: "bold", cyr: "check", tags: ["workshop", "garage", "werkstatt", "logistics", "sport", "event"] },
  { id: "Fira Sans Extra Condensed + Fira Sans", mood: "condensed industrial", fam: "bold", cyr: true, tags: ["workshop", "garage", "werkstatt", "sport", "logistics"] },
  { id: "Russo One + Exo 2", mood: "motor/sport", fam: "bold", cyr: true, tags: ["garage", "auto", "sport", "motor"] },
  { id: "Anybody (variable width) + Chivo", mood: "expressive variable", fam: "bold", cyr: "check", tags: ["agency", "music", "event", "creative", "kids", "coding"] },
  { id: "Rubik Mono One + Rubik", mood: "chunky fun", fam: "bold", cyr: true, tags: ["kids", "games", "school"] },
  { id: "Bowlby One + Karla", mood: "playful heavy", fam: "bold", cyr: "check", tags: ["kids", "youth", "snacks", "event"] },
  { id: "League Gothic + Libre Franklin", mood: "poster condensed", fam: "bold", cyr: "check", tags: ["event", "festival", "bar", "sport", "culture"] },
  { id: "Climate Crisis + Epilogue", mood: "statement", fam: "bold", cyr: "check", tags: ["nonprofit", "climate", "activism", "manifest"] },
];

const PALETTES = [
  { id: "ink + one signal", fam: ["refined", "technical", "bold"], desc: "near-black on off-white, a single saturated signal color for action and data" },
  { id: "material-derived", fam: ["warm", "refined"], desc: "colors sampled from the subject's real materials (wood, wine, steel, paper, fabric)" },
  { id: "deep color field", fam: ["bold", "warm"], desc: "one saturated background color owns whole sections, text in ink or white" },
  { id: "duotone", fam: ["bold", "technical"], desc: "two strong hues only (plus neutrals), used for images and type alike" },
  { id: "earthy naturals", fam: ["warm", "refined"], desc: "clay, moss, sand, bark - muted but warm, high text contrast" },
  { id: "primary triad", fam: ["bold"], desc: "red, yellow, blue at controlled saturation with black and white (Bauhaus)" },
  { id: "pastel + strong ink", fam: ["warm", "bold"], desc: "soft pastel grounds, very dark ink type, no grey text" },
  { id: "photographic B/W + one color", fam: ["refined", "technical"], desc: "black-and-white imagery, one color for interaction only" },
  { id: "cool technical grey", fam: ["technical"], desc: "blue-greys with one precise accent; tabular, calm" },
  { id: "night mode native", fam: ["technical", "refined", "warm"], desc: "designed dark-first with warm off-white type and one muted accent (no neon)" },
];

const SIGNATURES = [
  "interactive toy or tool tied to the core promise",
  "one oversized number or date with meaning",
  "custom illustration system (3-5 consistent motifs)",
  "art-directed photography with consistent crop and light",
  "single orchestrated motion moment on load or scroll",
  "typographic play (variable font axis, extreme size contrast)",
  "map or place as a graphic element",
  "timeline / schedule as the backbone of the page",
  "real data visualization of the business",
  "hand-written annotations on real material",
  "physical object metaphor (ticket, label, receipt, menu card)",
  "sound-free video loop of the real product or place",
];

const recent = existsSync(HISTORY)
  ? readFileSync(HISTORY, "utf8").trim().split("\n").filter(Boolean).slice(-6).map((l) => { try { return JSON.parse(l); } catch { return {}; } })
  : [];
const usedComp = new Set(recent.map((r) => r.composition));
const usedType = new Set(recent.map((r) => r.type));
const usedPal = new Set(recent.slice(-3).map((r) => r.palette));

const fits = (item) => (item.tags || []).some((t) => brief.includes(t));
const typeOk = (t) => !needCyr || t.cyr === true;

// How well a type pairing matches the subject: number of its tags found in the brief.
const score = (t) => (t.tags || []).filter((tag) => brief.includes(tag)).length;
const maxScore = Math.max(0, ...TYPE.map(score));
// Relevance-ranked pool: best matches first, widened until there are enough options to vary.
let bestTypes = [];
for (let lvl = maxScore; lvl >= 1 && bestTypes.filter(typeOk).length < 4; lvl--) bestTypes = TYPE.filter((t) => score(t) >= lvl);
const domainFams = [...new Set(TYPE.filter((t) => score(t) === maxScore && maxScore > 0).map((t) => t.fam))];
if (bestTypes.filter(typeOk).length < 4 && domainFams.length) bestTypes = [...new Set([...bestTypes, ...TYPE.filter((t) => domainFams.includes(t.fam))])];

function concept(mode) {
  let comps = COMPOSITIONS.filter((c) => !usedComp.has(c.id) && (c.id !== "split-with-tool" || /rechner|calculator|konfigur|booking|tool|калькул/.test(brief)));
  if (mode === "fit") { const fc = comps.filter(fits); if (fc.length) comps = fc; }
  // Taste guard: every composition (wildcards too) must work with a mood that suits the subject.
  if (domainFams.length) { const ok = comps.filter((c) => c.fam.some((f) => domainFams.includes(f))); if (ok.length) comps = ok; }
  const composition = pick(comps.length ? comps : COMPOSITIONS);
  // Taste: one mood family for the whole concept, so type, palette and layout agree.
  let types = TYPE.filter((t) => !usedType.has(t.id) && typeOk(t) && composition.fam.includes(t.fam));
  // Taste guard: prefer the best-matching pairings; otherwise stay within the subject's moods
  // (no sport fonts for a law firm, no scholarly serif for a kids' school).
  const best = types.filter((t) => bestTypes.includes(t));
  if (best.length) types = best;
  else if (domainFams.length) { const inDomain = types.filter((t) => domainFams.includes(t.fam)); if (inDomain.length) types = inDomain; }
  const type = pick(types.length ? types : TYPE.filter((t) => typeOk(t) && composition.fam.includes(t.fam)).concat(TYPE.filter(typeOk)).slice(0, 40));
  let pals = PALETTES.filter((p) => !usedPal.has(p.id) && p.fam.includes(type.fam));
  if (!pals.length) pals = PALETTES.filter((p) => p.fam.includes(type.fam));
  return { mode, composition, type, palette: pick(pals), signature: pick(SIGNATURES), family: type.fam };
}

const concepts = [concept("fit"), concept("fit"), concept("wildcard")];
// make the three concepts differ in composition, type and palette
for (let i = 1; i < concepts.length; i++) {
  const clash = () => concepts.slice(0, i).some((c) => c.composition.id === concepts[i].composition.id || c.type.id === concepts[i].type.id || c.palette.id === concepts[i].palette.id);
  for (let tries = 0; tries < 40 && clash(); tries++) concepts[i] = concept(tries < 20 ? concepts[i].mode : "wildcard");
}

const BUSINESS = [["software / tech", /saas|software|app|tool|devops|monitor|api|platform|crm|erp|dashboard|(^|[^a-z])ai([^a-z]|$)|tech/], ["gaming", /game|gaming|esport/], ["place", /bar|restaurant|café|cafe|hotel|shop|store|practice|praxis|clinic|studio|werkstatt|garage|salon|school|gym|wine/], ["product", /product|device|furniture|fashion|bike|cosmetic/], ["service", /law|kanzlei|consult|agency|insurance|tax|account|service|repair/]];
const business = (BUSINESS.find(([, re]) => re.test(brief)) || ["service (default)"])[0];
console.log(`Brief: ${brief || "(none)"}${needCyr ? "  [Cyrillic needed]" : ""}`);
console.log(`Business type: ${business}${/software|gaming/.test(business) ? " - richer motion / WebGL allowed" : " - no WebGL/shader effects"}${business === "place" ? "; real photos of the place are mandatory" : ""}`);
console.log(`Recently used (avoided): ${[...usedComp].filter(Boolean).join(", ") || "-"}\n`);
concepts.forEach((c, i) => {
  console.log(`Concept ${String.fromCharCode(65 + i)} (${c.mode}, mood: ${c.family})`);
  console.log(`  composition: ${c.composition.id} - ${c.composition.desc}`);
  console.log(`  type:        ${c.type.id} (${c.type.mood}${c.type.cyr === "check" ? ", check Cyrillic" : ""})`);
  console.log(`  palette:     ${c.palette.id} - ${c.palette.desc}`);
  console.log(`  signature:   ${c.signature}\n`);
});
console.log("Pick one (or merge two), adapt it to the brief, and explain why in the design plan.");
console.log("Never swap in an overused AI default (Inter, Geist, Instrument Serif, Fraunces, Space Grotesk, DM Sans, Manrope, Poppins, Montserrat, Playfair, Satoshi ...). For a premium brand, consider a licensed foundry typeface.");
console.log(`After building, log it: node design-dice.mjs --log '{"project":"<name>","composition":"<id>","type":"<id>","palette":"<id>","signature":"<text>"}'`);
