# Mobile apps and PWAs

## Choose the platform
- **PWA** (installable web app): fastest to ship, one codebase, works for most business apps (booking, CRM, field service). Limits: iOS push needs the app installed to the home screen; restricted background tasks; no app-store presence.
- **React Native + Expo**: when you need app-store presence, reliable push, camera/Bluetooth/NFC, background location or offline-first at scale. Use Expo Router, EAS Build/Update, and share types/validation with the web app.
- Native (Swift/Kotlin) only for heavy device or performance needs.

## PWA essentials
- Web app manifest (name, short_name, icons 192/512 + maskable, `display: standalone`, theme/background colors, `start_url`, `scope`).
- Service worker (Workbox / `next-pwa`/Serwist): cache the app shell, network-first for API data, offline fallback page; version caches and clean old ones.
- Offline data: IndexedDB (e.g. Dexie) with a sync queue for mutations; show sync state; resolve conflicts explicitly.
- iOS specifics: `apple-touch-icon`, safe areas (`env(safe-area-inset-*)`, `viewport-fit=cover`), no 100vh bugs (use `dvh`), inputs >= 16px to avoid zoom.

## Mobile UX (both)
- Thumb zone: primary actions at the bottom; touch targets >= 44px; bottom navigation for 3-5 sections.
- Native-feeling feedback: pressed states, haptics (RN), pull-to-refresh where users expect it, skeletons instead of spinners.
- Forms: correct keyboard types (`inputmode`), autofill, one column, sticky submit button above the keyboard.
- Respect system settings: dark mode, dynamic type/font scaling, reduced motion.
- Performance budget on a mid-range Android phone, not your laptop: < 2.5 s to interactive on 4G.

## Store release (React Native)
- App icons/splash per platform, privacy manifest (iOS) and data safety form (Android), store screenshots in DE/EN, crash reporting (Sentry), OTA updates only for JS changes allowed by store rules.
