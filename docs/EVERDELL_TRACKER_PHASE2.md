# Everdell Tracker — Phase 2 (Flutter) plan

This document lives only in `everdell_tracker` and is intended to guide Flutter implementation.

## Read first (contracts / source of truth)

- `docs/budgit-api/EVERDELL_PHASE1_API.md` (copied from Budgit; endpoints + 409 semantics)
- `docs/budgit-api/EVERDELL_PLAYER_ACCOUNTS.md` (copied from Budgit; UUID identity + display fields)
- `docs/BUDGIT_EVERDELL_INTEGRATION_PLAN.md` (phase status + architecture)

## Goals (Phase 2)

- Add an **online mode** backed by Budgit’s Everdell API at `https://www.budgit.lol`.
- Gate online mode behind Everdell-scoped login (`POST /api/everdell/token/cookie/`).
- Replace local-only persistence for online sessions with server fetch + write-through.

## Non-goals / constraints

- **Do not change Budgit backend** from this repo (Phase 2 scope is Flutter-only).
- Keep endpoint behaviour/spec changes in Budgit docs, then re-copy into `docs/budgit-api/`.

## Implementation outline

### Login gate (web/PWA)

- **Everdell uses its own auth** — not Budgit budget cookies (see scoped JWT in Budgit docs).
- Base URL: `https://www.budgit.lol`
- Login: `POST /api/everdell/token/cookie/` with `credentials: 'include'` → sets `everdell_access_token`.
- Session check: `GET /api/everdell/me/` (401 → show Everdell login screen on the PWA).
- The PWA hosts its own login form (username/password → Everdell token endpoint). Users do **not** need a Budgit budget tenant.

### Online-first with offline queue (holiday use case)

- **Default:** online mode — games load from and save to the API.
- **Offline:** when no network, allow creating/editing games in a local **pending sync** queue only.
- **Conflict rule:** once a game exists on the server, the client must not edit it offline (read-only locally; refresh from server). Only unsynced local games are editable offline.
- On reconnect: upload pending games via `POST`; do not overwrite server games edited by others (server wins for synced ids).

### `EverdellApiService`

Create a service responsible for all Budgit API communication:

- Base: `https://www.budgit.lol`
- Responsibilities:
  - `getMe()` / `patchMe()`
  - `listGroups()` / `createGroup()` / `joinGroup()`
  - `listPlayers(groupId)` / `createPlayer(groupId, ...)` / `patchPlayer(groupId, playerId, ...)`
  - `listMyPlayers()`
  - `listGames(groupId)` / `getGame(groupId, gameId)` / `createGame(groupId, payload)` / `updateGame(groupId, gameId, updatedAt, payload)` / `deleteGame(groupId, gameId)`
- Error handling:
  - Map **409** responses into a domain error for the UI to handle (see below).
  - Preserve server-provided `detail` and `current` body where supplied.

### Group picker / active group

- Add a group selection screen / modal:
  - Load groups via `GET /api/everdell/groups/`.
  - Provide create + join flows (per existing Budgit Phase 0 endpoints).
- Store last-selected group locally for convenience (until a server preference API exists).

### Roster integration

- Roster UI should display:
  - `display_name` (not raw `name` when linked)
  - `display_avatar_url` (not raw avatar fields)
- Internally, treat **player UUID (`id`) as identity** everywhere.

### Game list + save wiring

- On opening an online group:
  - Fetch games: `GET /api/everdell/groups/<group_id>/games/`.
- On save:
  - Create: `POST /api/everdell/groups/<group_id>/games/`.
  - Update: `PUT /api/everdell/groups/<group_id>/games/<game_id>/` with required `updated_at`.
- Ensure game payload references player UUIDs from the API.

### 409 handling (optimistic concurrency)

- When updating a game, if API returns **409**:
  - Show a clear message (“Someone else saved first — refresh to load latest”).
  - Offer:
    - Refresh (replace local state with `current` or re-GET),
    - Retry save after reloading, if appropriate.

## Implemented (Phase 2a)

- [x] `EverdellApiService` (login, logout, me, groups create/join/list)
- [x] Login screen + session restore
- [x] Group picker (create, join, select)
- [x] Settings: sign out, change scorebook

## Implemented (Phase 2b)

- [x] `EverdellApiService` games + roster (`listGames`, `getGame`, `createGame`, `updateGame`, `deleteGame`, `listPlayers`, `createPlayer`)
- [x] `GameProvider` / `PlayerProvider` backed by API for active scorebook
- [x] `ScorebookLoaderScreen` — loads games + roster after group select
- [x] Roster autocomplete uses `display_name`; game payloads store player UUIDs
- [x] New players auto-created on save via `POST .../players/`
- [x] 409 conflict dialog with refresh from server `current` body
- [ ] Offline pending queue (Phase 2c)

## Implemented (Phase 2 UX / hosting)

- [x] **Path migration:** Everdell moved from `everdell.budgit.lol` to `www.budgit.lol/everdell/`. No Flutter code changes needed — base URL stays `https://www.budgit.lol`. Same-domain means no CORS complexity.
- [x] **PWA manifest:** `web/manifest.json` updated — `start_url: "/everdell/"`, `scope: "/everdell/"`, `display: "standalone"`. Flutter must be built with `--base-href=/everdell/` (handled by `scripts/build.sh` in budgit repo).
- [x] **Separate app:** No Budgit nav link to Everdell. Each app accessed independently.
- [x] **Build process:** `budgit/scripts/build.sh` installs Flutter, clones this repo, builds web with `--base-href=/everdell/`, copies output to `budgit/everdell_static/`.

## Implementation notes (as built)

### Auth (Phase 2a) — deliberate departures from original outline

| Original plan | Actual implementation | Reasoning |
|---------------|----------------------|-----------|
| Redirect to Budgit budget login | Everdell PWA has its own login screen | Scoped JWT: budget and Everdell cookies are separate. Everdell users may have no budget tenant. |
| Shared `.budgit.lol` session | `POST /api/everdell/token/cookie/` only | Security hardening on Budgit (`b699107`); Everdell must not use budget `access_token`. |

**Key files:** `lib/screens/login_screen.dart`, `lib/providers/auth_provider.dart`, `lib/services/everdell_api/everdell_http_client_web.dart` (`withCredentials: true`).

### Group + scorebook load (Phase 2a/2b)

- Flow: `AppGateScreen` → login → `GroupPickerScreen` → `ScorebookLoaderScreen` → `HomeScreen`.
- Active group persisted in `EverdellTokenStorage` (local only until server preferences API exists).
- `ScorebookLoaderScreen` fetches games and roster in parallel; shows retry UI on failure.

### Games API (Phase 2b)

| Decision | Reasoning |
|----------|-----------|
| List games via `GET .../games/` then parallel `GET .../games/<id>/` for each | List endpoint returns summary fields only (no `payload`). Detail fetch is required for player names/scores in `GameCard`. Acceptable for household-scale scorebooks; optimise later if needed. |
| `GameProvider` stores server `updated_at` per game id | Required for optimistic concurrency on `PUT`. |
| `EverdellConflictException` → dialog → `applyRemoteGame(current)` → pop edit screen | Matches API 409 contract; avoids overwriting with stale form state. |
| Import remaps player UUIDs via `ensurePlayer(name)` | Legacy JSON export used local random UUIDs; server expects roster UUIDs. |

**Key files:** `lib/providers/game_provider.dart`, `lib/models/everdell_game_record.dart`, `lib/screens/new_game_screen.dart`, `lib/screens/history_screen.dart`.

### Roster (Phase 2b + June 2026 polish)

| Decision | Reasoning |
|----------|-----------|
| Autocomplete shows `display_name` from API | Per `EVERDELL_PLAYER_ACCOUNTS.md`; linked players may differ from raw `name`. |
| When names collide, show `Name · AB12` in autocomplete | Last 4 chars of player UUID — subtle disambiguator; full UUID only in Settings as “ID AB12”. |
| `ensurePlayer` on save creates `POST .../players/` if name not in roster | Keeps game payloads aligned with server UUIDs without a separate “add player” screen. |
| Auto-linked roster row on group create/join (server) | Budgit `add_member()` calls `ensure_roster_player_for_user()`; migration `0006` backfills existing members. |
| Settings nickname + `patchPlayer()` | Per-group nickname via `PATCH .../players/<id>/` with `display_name_source: player`; avoids changing account display name. |
| `display_avatar_url` not shown yet | Deferred to Phase 3 polish; names only in `PlayerInputCard` for now. |
| `_PlayerEntry.rowId` vs `playerId` | UI winner selection uses stable row id during edit; `playerId` becomes roster UUID before save. |

**Key files:** `lib/providers/player_provider.dart`, `lib/models/everdell_player.dart`, `lib/widgets/player_input_card.dart`, `lib/screens/settings_screen.dart`.

### Group picker (June 2026)

| Decision | Reasoning |
|----------|-----------|
| Scorebook list is the primary UI | Most sessions start by picking an existing household scorebook. |
| Invite code + Join always visible | Joining via invite is the common path for new members. |
| “Create a new scorebook” collapsed at bottom | Creating a group is rare; reduces clutter on the landing screen. |

**Key file:** `lib/screens/group_picker_screen.dart`.

### Local storage

- `PlatformStorageService` / Hive paths **not removed** — still used by export JSON shape and future Phase 2c offline queue.
- Online session does not read/write games or roster to local storage.

### Path migration + PWA (Phase 2 UX)

| Decision | Reasoning |
|----------|-----------|
| `www.budgit.lol/everdell/` path (not subdomain) | Frees one Render custom domain slot. Same-origin removes CORS/blocked-origin complexity. |
| Build via `budgit/scripts/build.sh` — `--base-href=/everdell/` | Required for Flutter to load assets from the correct path prefix. Handled outside this repo; no Flutter code changes. |
| `start_url: "/everdell/"` + `scope: "/everdell/"` in manifest | Correct PWA scoping so the installed shortcut opens `/everdell/` and the browser scope doesn't bleed into Budgit routes. |
| `display: "standalone"` in manifest | Opens chrome-free when added to home screen on iOS/Android. Same for Budgit at `/`. |
| No nav link in Budgit | Budgit and Everdell Tracker are separate apps; linking would imply one is part of the other. |

### Not implemented (Phase 2 scope gaps → Phase 3)

- `patchMe()`, `listMyPlayers()`
- Roster avatars in UI
- Server-side last-active-group preference
- `GET /api/everdell/games/mine/`

(`patchPlayer()` implemented June 2026 for nickname edits in Settings.)

## Testing

See **`docs/EVERDELL_TRACKER_PHASE2_TESTING.md`** for the full checklist and pass/fail log.

Quick status (June 2026):

| Area | Status |
|------|--------|
| Phase 2a login + groups | ✅ user verified |
| Phase 2b create/edit games | ✅ shipped; verify after deploy |
| Phase 2b delete | ✅ wired to API |
| Phase 2b import | ✅ wired; remap UUIDs |
| 409 two-browser conflict | ⬜ recommended manual test |
| `display_avatar_url` in UI | ⬜ deferred Phase 3 |
| Offline / no network | ⬜ Phase 2c — fails or empty today |

