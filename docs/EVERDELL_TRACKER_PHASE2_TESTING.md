# Everdell Tracker — Phase 2 testing checklist

Production base URL: **`https://www.budgit.lol`** (API)  
PWA URL: **`https://www.budgit.lol/everdell/`** (served by Django `serve_everdell` since path migration)

Commits: Phase 2a `43c2516`, Phase 2b `a7ad6f1`, path migration (post)

---

## Prerequisites

- Budgit user account (budget tenant **not** required for Everdell).
- At least one Everdell group, or ability to create/join via invite code.
- Two browsers or devices for 409 testing (optional).

---

## Phase 2a — login and groups

| # | Test | Expected | Status |
|---|------|----------|--------|
| 1 | Open PWA logged out | Login screen shown (not blank home) | ✅ |
| 2 | Wrong password | Error message, stay on login | ✅ |
| 3 | Valid login | Group picker or home (if saved group) | ✅ |
| 4 | `GET /api/everdell/me/` after login | 200 with `display_name` | ✅ |
| 5 | List groups | Existing groups appear | ✅ |
| 6 | Create group | New group selected, proceeds to loader | ✅ |
| 7 | Join via invite code | Joined group selected | ✅ |
| 8 | Settings → change scorebook | Returns to group picker | ✅ |
| 9 | Settings → sign out | Returns to login; no stale data flash | ✅ |
| 10 | Refresh page while logged in | Session restored via cookies | ✅ |

---

## Phase 2b — games and roster

| # | Test | Expected | Status |
|---|------|----------|--------|
| 11 | Select scorebook | Loader then home; game count from server | ⬜ verify post-deploy |
| 12 | New game — existing player from autocomplete | `display_name` suggested; save succeeds | ⬜ |
| 13 | New game — brand-new player name | Roster row created on save; UUID in payload | ⬜ |
| 14 | Game appears in history after save | Persists after refresh | ⬜ |
| 15 | Edit game scores | `PUT` succeeds; changes visible after refresh | ⬜ |
| 16 | Delete game (detail or swipe) | Removed from server and list | ⬜ |
| 17 | Home quick stats | Reflect loaded games | ⬜ |
| 18 | Stats screen | Player stats from API games | ⬜ |
| 19 | Export history | JSON export still works | ⬜ |
| 20 | Import JSON | Games uploaded; player names mapped to roster UUIDs | ⬜ |

---

## Phase 2b — 409 conflict

| # | Test | Expected | Status |
|---|------|----------|--------|
| 21 | User A opens game edit | — | ⬜ |
| 22 | User B saves same game first | — | ⬜ |
| 23 | User A saves | 409 dialog; Refresh loads server copy | ⬜ |

---


## Path migration + PWA checks

| # | Test | Expected | Status |
|---|------|----------|--------|
| 26 | www.budgit.lol/everdell/ in browser | Everdell login screen loads | open after Render build |
| 27 | All Everdell PWA routes (e.g. /everdell/anything) | index.html served (Flutter router handles) | open |
| 28 | Add www.budgit.lol/everdell/ to home screen | Opens chrome-free (standalone) | open |
| 29 | Everdell PWA - login + view games | Same as Phase 2a/2b tests above | open |
| 30 | everdell.budgit.lol (old URL) | Not reachable (custom domain removed from Render) | open |
| 31 | Everdell static file (e.g. /everdell/main.dart.js) | Served with correct mime type | open |

---

## Regression — Budgit budget (separate app)

Not Everdell scope, but related after scoped JWT + www redirect (`7392762`):

| # | Test | Expected | Status |
|---|------|----------|--------|
| 24 | Phone PWA from `www.budgit.lol` | Bills/data load after login | ✅ (re-add shortcut from www) |
| 25 | Apex `budgit.lol` in browser | Redirects to `www`; data loads | ⬜ after Budgit deploy |
| 34 | Budgit home screen icon | Opens chrome-free; budget data loads | open - re-add shortcut from www |
| 35 | No Everdell Tracker link in Budgit nav | Link absent from mobile + desktop nav | open after frontend deploy |

---

## Access control flags — admin-controlled per-user access

Tests for `has_budget_access` and `has_everdell_access` on `CustomUser` (set via `/admin/`):

| # | Test | Expected | Status |
|---|------|----------|--------|
| 36 | Disable `has_everdell_access` on a user, then attempt Everdell login | 403 with message "Everdell Tracker access is not enabled" | open |
| 37 | Disable `has_budget_access` on a user, then attempt budget login | 403 with message "Budget access is not enabled" | open |
| 38 | Re-enable flag, then login | Login succeeds normally | open |
| 39 | User with only `has_everdell_access=True` (`has_budget_access=False`) | Can use Everdell; cannot log into budget | open |
| 40 | User with only `has_budget_access=True` (`has_everdell_access=False`) | Can use Budgit budget; cannot log into Everdell | open |
| 41 | Admin user list — both flag columns visible and filterable | Flags appear in Django admin user list | open after deploy |

---

## Known limitations (not bugs — Phase 2c / 3)

- **No offline queue:** aeroplane / no signal → cannot create games (or may show loader error).
- **No roster avatars** in Flutter UI yet.
- **Game list N+1:** one detail request per game (fine for small scorebooks).
- **Everdell login ≠ Budgit budget login** — logging into Everdell does not open budget data.

---

## Local dev (optional)

```powershell
cd c:\Users\kiero\Code\everdell_tracker
flutter run -d chrome
# API must point at dev or prod Budgit; web uses cookie auth to www.budgit.lol
```

Budgit API tests:

```powershell
cd c:\Users\kiero\Code\budgit
python manage.py test everdell --settings=budgit.settings_dev
```
