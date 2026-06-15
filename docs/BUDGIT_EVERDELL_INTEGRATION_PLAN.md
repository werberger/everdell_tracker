> **Source of truth:** budgit `docs/BUDGIT_EVERDELL_INTEGRATION_PLAN.md` @ `main` (post path-migration commit, June 2026).  
> Re-copy when phases or architecture change.

# Budgit + Everdell Tracker — Integration Plan

> **Status:** Living document — updated June 2026 after Phase 2a/2b (Flutter) + budget www redirect fix.  
> **API contract (authoritative for endpoints):** `docs/budgit-api/EVERDELL_PHASE1_API.md`, `docs/budgit-api/EVERDELL_PLAYER_ACCOUNTS.md`  
> **Everdell Flutter repo:** `everdell_tracker` — client UI; Budgit owns auth, API, DB, deploy orchestration.

---

## Executive summary (current)

- **Everdell Tracker** is at **https://www.budgit.lol/everdell/** — same domain as Budgit, different path. No Budgit nav link to Everdell (separate apps, accessed independently).
- Scorebooks are scoped by **Everdell group**, not Budgit budget tenant — John (tenant A) and Julia (tenant B or no tenant) can share a group.
- **Budgit backend:** Django app `everdell`, PostgreSQL schema `everdell`, routes under `/api/everdell/`.
- **Phase 0 + Phase 1 API:** ✅ shipped on `main` (groups, games, players, linking, nicknames, display prefs, `/api/everdell/me/`).
- **Phase 2a/2b (Flutter):** ✅ shipped on `everdell_tracker` `main` (`a7ad6f1`) — Everdell login, group picker, API game/roster sync.
| 2 UX/hosting - path migration, PWA, nav | done | budgit integration plan + this doc |
- **Phase 2c (Flutter):** 🔲 next — offline pending sync queue (holiday use case).
- **Server is source of truth** for online mode: fetch on open, write-through on save; 409 on stale game updates.
- **Budget mobile PWA:** apex `budgit.lol` bookmarks fixed by canonical www redirect (`7392762`). Both PWAs open as standalone (no browser chrome).
- **Path migration:** Everdell moved from `everdell.budgit.lol` to `www.budgit.lol/everdell/` — frees Render custom domain slot, eliminates cross-origin CORS complexity.

---

## Phase delivery (summary)

| Phase | Status | Doc |
|-------|--------|-----|
| 0 — groups API | ✅ | budgit `EVERDELL_PHASE0_TESTING.md` |
| 1 — games/players API | ✅ | budgit `EVERDELL_PHASE1_SMOKE.md` |
| 2a — Flutter login/groups | ✅ | `EVERDELL_TRACKER_PHASE2.md` |
| 2b — Flutter games/roster | ✅ | `EVERDELL_TRACKER_PHASE2.md` + `EVERDELL_TRACKER_PHASE2_TESTING.md` |
| 2c — offline queue | 🔲 next | `EVERDELL_TRACKER_PHASE2.md` |
| 3 — polish | 🔲 | integration plan Phase 3 section in budgit copy |

**Full architecture, API tables, and security notes:** see source-of-truth file in budgit repo (re-copy when it changes).

---

## Self-service registration (this repo)

- **Screen:** `lib/screens/registration_screen.dart`, linked from `LoginScreen` ("New here? Create an account").
- **Provider:** `AuthProvider.register()` → `EverdellApiService.register()` → `POST /api/everdell/register/`.
- **Behaviour:** creates an Everdell-only account (no budget access), auto-logs-in, proceeds to group picker. User then joins a household scorebook with an invite code.
- **No email verification.** Anti-abuse handled server-side: 5 registrations/day per IP, 30 invite-code attempts/day per user. See budgit copy for full reasoning.

---

## Flutter implementation (this repo)

- **URL:** `https://www.budgit.lol/everdell/` (path on Budgit Django service, built by `scripts/build.sh`).
- **PWA:** `web/manifest.json` — `start_url: "/everdell/"`, `scope: "/everdell/"`, `display: "standalone"`. Adds to home screen as chrome-free app.
- **Flow:** `AppGateScreen` → login → group picker → `ScorebookLoaderScreen` → home.
- **API:** `lib/services/everdell_api/everdell_api_service.dart` → `https://www.budgit.lol`
- **Online state:** `GameProvider`, `PlayerProvider` (roster UUIDs in payloads).
- **Local storage:** retained for export/import + future 2c offline queue only.

See **`docs/EVERDELL_TRACKER_PHASE2.md`** for implementation notes, departures from plan, and reasoning.

---

*Mirror of budgit integration plan v3.1 (post path-migration) — read budgit copy for full detail.*
