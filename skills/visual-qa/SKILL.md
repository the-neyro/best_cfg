---
name: visual-qa
description: Render a web page or app in a real browser, screenshot it at mobile/tablet/desktop widths in light and dark mode, collect console errors, failed requests and horizontal overflow, then review the screenshots and fix what is wrong. Use after any UI change before saying it is done, or when the user asks to check how something looks.
when_to_use: "check the UI", "screenshot", "how does it look", "visual bug", "responsive", "mobile view", after building or editing pages and components
allowed-tools: Bash(node *), Read
---

# Visual QA

Code that compiles can still look broken. This skill closes the loop: render -> look -> fix -> re-render.

## Steps
1. **Run the app.** Start the dev server in the background if it is not running (e.g. `npm run dev`), and wait until the URL responds. For a static HTML file, pass the file path directly.
2. **Shoot.** Run `scripts/shoot.mjs` from this skill's folder (installed at `~/.claude/skills/visual-qa/` for Claude Code and `~/.agents/skills/visual-qa/` for Codex and other agents). Playwright must be resolvable from the project; if it is not, install it as a dev dependency after asking:
   ```bash
   node ~/.claude/skills/visual-qa/scripts/shoot.mjs http://localhost:3000/path --out .screenshots
   # options: --widths 375,768,1280,1440  --schemes light,dark  --viewport-only  --wait 1000
   ```
   If Playwright MCP is connected, you may use it instead (`browser_resize`, `browser_navigate`, `browser_take_screenshot`, `browser_console_messages`).
3. **Read the report**: fix every console error, failed request and horizontal overflow first.
4. **Look at every screenshot** with the Read tool. Check, per viewport and theme:
   - Hierarchy: is the primary element obvious? Is the primary action visible without scrolling on mobile?
   - Alignment and spacing consistency; nothing touching the viewport edges (min 16px gutters on mobile).
   - Text: no overflow, clipping, awkward wraps, orphan words in headings, unreadable contrast (especially muted text and text over images).
   - Images and icons: correct aspect ratios, no stretching, no broken images.
   - Dark mode: no invisible text/borders, no hardcoded white surfaces, shadows not muddy.
   - Interactive states: hover/focus where relevant (take an extra screenshot after `page.hover` / `Tab` focus if needed).
5. **Fix and repeat** until the screenshots are clean. Do not stop at the first pass if you changed layout.
6. **Report**: list viewports checked, issues found and fixed, and anything remaining. Add `.screenshots/` to `.gitignore` if it is not already ignored.

## Notes
- Screenshots are for your eyes; keep `deviceScaleFactor` 1 to keep them light.
- For pages behind auth, log in once with Playwright and save `storageState`, or ask the user for a test account.
- For a deeper design critique, delegate to the `ui-reviewer` subagent with the URL.
