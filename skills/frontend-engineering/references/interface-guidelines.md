# Interface guidelines - the details that make an app feel expensive

Inspired by Vercel's Web Interface Guidelines (MIT), rewritten and condensed. Check every item that applies.

## Forms
- [ ] Never block paste; never clear input on error; drafts survive navigation (autosave or warn before leaving).
- [ ] Labels always visible (placeholders are examples, not labels, and end with "…": „z. B. max@firma.de…“).
- [ ] Correct `type`, `inputmode`, `autocomplete` (`email`, `tel`, `one-time-code`, `street-address`…); `autocomplete="off"` only where suggestions make no sense.
- [ ] Submit button stays enabled until the request starts, then shows a spinner and blocks double-submit.
- [ ] On failed submit, focus the first invalid field; errors next to the field, explaining the fix.
- [ ] Checkbox/radio and their label form one click target; Enter submits single-field forms.

## Focus and keyboard
- [ ] `:focus-visible` rings on every interactive element; `:focus-within` for compound controls.
- [ ] Logical tab order, no traps; Esc closes overlays and returns focus to the trigger.
- [ ] Sticky headers don't cover focused elements or anchor targets (`scroll-margin-top`).
- [ ] Skip link to main content; every action reachable by keyboard; drag/swipe/pinch have button alternatives.

## Accessibility
- [ ] Async messages (toasts, validation, saved state) announced via `aria-live="polite"`.
- [ ] Decorative icons `aria-hidden="true"`; icon-only buttons have `aria-label`.
- [ ] Hit targets >= 24px (44px on touch), even when the visual is smaller.

## Navigation and state
- [ ] URL reflects filters, tabs, pagination, search, open panels - shareable and back-button safe.
- [ ] Links are real `<a href>` (Cmd/middle-click, open in new tab work); buttons are `<button>`.
- [ ] Destructive actions need confirmation or offer undo.

## Animation
- [ ] Never `transition: all`; list the properties. Animate `transform`/`opacity` only.
- [ ] Correct `transform-origin` (menus grow from their trigger); SVG transforms on a `<g>` with `transform-box: fill-box`.
- [ ] Animations are interruptible; autoplaying motion > 5s can be paused; everything respects `prefers-reduced-motion`.

## Touch and scrolling
- [ ] `overscroll-behavior: contain` in modals, drawers and scroll panels; `touch-action: manipulation` to remove tap delay.
- [ ] During drag: disable text selection, make the rest `inert`.

## Typography and content
- [ ] Real ellipsis "…", proper quotes („…“ DE, «…» RU, “…” EN), non-breaking space in "10 MB", "⌘ K", "5 €".
- [ ] Loading states end with "…" ("Wird gespeichert…"); numbers in tables `tabular-nums`.
- [ ] Long text truncates gracefully (`min-w-0` on flex children, `truncate`/line-clamp with full text in a tooltip).
- [ ] Buttons say what they do ("API-Schlüssel speichern", not "Weiter"); errors say how to fix.

## Images and media
- [ ] Explicit `width`/`height` or aspect ratio; `loading="lazy"` below the fold; `fetchpriority="high"` for the LCP image.
- [ ] Muted looping `<video autoplay muted loop playsinline>` instead of GIFs.

## Dark mode and theming
- [ ] `color-scheme` set on `<html>`; `<meta name="theme-color">` matches the background.
- [ ] Native controls (`<select>`, scrollbars) explicitly styled for dark mode (Windows renders them light otherwise).

## i18n
- [ ] Dates, numbers, currencies via `Intl.*` with the user's locale; never hardcoded formats.
- [ ] Language from `navigator.languages` / `Accept-Language`, never from IP; user can switch.
- [ ] `translate="no"` on brand names and code; layouts survive 30 % longer German strings.

## Performance hygiene
- [ ] No layout reads in render; lists > 50 items virtualized; uncontrolled inputs where possible.
- [ ] `preconnect` to critical third-party origins; fonts preloaded and self-hosted.
