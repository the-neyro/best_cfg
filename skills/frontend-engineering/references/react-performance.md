# React / Next.js performance rules

Ordered by impact. Inspired by Vercel's React best-practices guide (MIT), rewritten and condensed.

## 1. Eliminate waterfalls (critical)
- Independent awaits run in parallel: `const [user, orders] = await Promise.all([getUser(id), getOrders(id)])`.
- Start promises early, await late (in route handlers and server components); move each `await` into the branch that actually needs it.
- Check cheap synchronous conditions before awaiting remote values (feature flags, permissions).
- Stream with `<Suspense>` boundaries around slow parts instead of blocking the whole page.
- Never fetch in a parent and then again in a child for related data; colocate or preload.

## 2. Bundle size (critical)
- Server Components by default; `"use client"` only on interactive leaves, never on whole pages/layouts.
- `next/dynamic` / `React.lazy` for heavy, below-the-fold or rarely used components (charts, editors, maps, modals).
- Import icons and utilities by path (`lucide-react` named imports are fine; avoid barrel files that pull whole libraries).
- Third-party scripts (analytics, chat, A/B) after hydration or on interaction (`next/script` `strategy="lazyOnload"` / `afterInteractive`).
- Preload on intent: prefetch routes/data on hover or focus of the link/button.
- Keep import paths statically analyzable (no dynamic `require(variable)`).

## 3. Server
- Authenticate and authorize inside every Server Action exactly like an API route.
- No module-level mutable state in server code (it leaks between requests/users).
- Send only the fields the client needs to client components (props are serialized into HTML).
- Use `after()` / background jobs for non-blocking work (logging, analytics, emails).
- Cache deliberately (`fetch` cache, `unstable_cache`/`"use cache"`, revalidate tags) and invalidate on mutation.

## 4. Client data
- One data layer (TanStack Query / SWR / RSC); dedupe requests; set sensible `staleTime`.
- Optimistic updates for instant feel, with rollback on error.
- Passive event listeners for scroll/touch; one shared global listener instead of one per component.
- Version and minimize anything stored in `localStorage`; validate it on read.

## 5. Re-renders
- Derive values during render - do not copy props/state into state via `useEffect`.
- Subscribe to derived booleans/selectors, not whole objects; don't subscribe to state used only inside callbacks (read it at call time).
- `useRef` for values that change often but don't affect output (timers, latest values).
- Never define components inside components; hoist static JSX.
- Functional `setState(prev => …)` when the next value depends on the previous one; lazy initial state for expensive defaults.
- Don't wrap primitives or cheap expressions in `useMemo`; memoize expensive computations and stable callbacks passed to memoized children.
- Keep inputs responsive with `useDeferredValue` / `useTransition` for expensive updates.

## 6. Rendering
- Virtualize lists with more than ~50-100 complex rows (TanStack Virtual); `content-visibility: auto` for long static sections.
- Conditional rendering with a ternary, not `count && <X/>` (renders a stray `0`).
- Avoid layout reads (`getBoundingClientRect`, `offsetHeight`) during render; batch DOM reads/writes.
- Prevent hydration flicker for client-only values (theme, locale) with an inline script or `suppressHydrationWarning` on the specific element.
- Defer non-critical work with `requestIdleCallback`.
