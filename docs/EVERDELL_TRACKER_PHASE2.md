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
- [ ] Game list/save to API (Phase 2b)
- [ ] Roster UUIDs in payloads (Phase 2b)
- [ ] Offline pending queue (Phase 2c)

## Testing checklist (Flutter)

- Logged out:
  - Opening online mode triggers login gate (no silent failures).
- Logged in:
  - Group list loads.
  - Create/join group works.
  - Players list loads; UI shows `display_name` + `display_avatar_url`.
  - Games list loads; create works; update works.
  - 409 flow shows correct UI and refresh behaviour.

