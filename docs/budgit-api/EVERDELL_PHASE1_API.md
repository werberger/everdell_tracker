> **Source of truth:** [budgit](https://github.com/werberger/budgit) repo `docs/EVERDELL_PHASE1_API.md` @ `main` commit `e26e15b` (or later).  
> Do not edit API behaviour here — update Budgit docs, then re-copy this file.

# Everdell Phase 1 — Games & players API

> **Base URL (production):** `https://www.budgit.lol` — use `www` for cross-origin calls from `everdell.budgit.lol`.  
> **Auth:** Everdell-scoped JWT only — `POST /api/everdell/token/cookie/` sets `everdell_access_token` (not budget cookies). Use `credentials: 'include'` or Bearer with `token_scope: everdell`.

### Everdell login (separate from Budgit budget login)

| Method | Path | Notes |
|--------|------|--------|
| POST | `/api/everdell/token/cookie/` | Body: `username`, `password` — sets Everdell cookies |
| POST | `/api/everdell/token/refresh/cookie/` | Refresh Everdell access token |
| POST | `/api/everdell/logout/` | Clears Everdell cookies |

Budget `access_token` cookies are **rejected** on Everdell routes (and vice versa).

## Endpoints

All routes require authentication and **group membership** (non-members get **404**).

### Account profile (Everdell)

| Method | Path | Body |
|--------|------|------|
| GET/PATCH | `/api/everdell/me/` | `display_name`, `profile_picture` (multipart) |

See **`EVERDELL_PLAYER_ACCOUNTS.md`** for how account vs group display preferences work.

### Players (group roster)

Each player is a **globally unique UUID** (`id`). Names may repeat within a group. See **`EVERDELL_PLAYER_ACCOUNTS.md`** for linking, nicknames, avatars, and display sources.

| Method | Path | Body |
|--------|------|------|
| GET | `/api/everdell/players/mine/` | — (all roster rows linked to you) |
| GET | `/api/everdell/groups/<group_id>/players/` | — |
| POST | `/api/everdell/groups/<group_id>/players/` | See below |
| GET/PATCH | `/api/everdell/groups/<group_id>/players/<player_id>/` | PATCH: profile fields |
| POST | `/api/everdell/groups/<group_id>/players/<player_id>/link/` | Claim row → your account |

**Create player:**

```json
{
  "name": "Julia",
  "nickname": "Jules",
  "link_to_me": false,
  "display_name_source": "player",
  "display_avatar_source": "player",
  "email": "julia@example.com",
  "phone": "",
  "date_of_birth": "1990-01-15",
  "first_played_at": "2025-06-01T18:00:00Z",
  "is_board_gamer": true,
  "profile_extra": { "notes": "optional stats blob" }
}
```

If `nickname` is omitted, it defaults to `name`. Response includes `display_name` and `display_avatar_url`.

Every POST creates a **new** player row (new UUID). `first_played_at` defaults to now if omitted.

**409 on create/link** when you already have a linked player in that group (`user_already_linked_in_group`).

### Games

| Method | Path | Body |
|--------|------|------|
| GET | `/api/everdell/groups/<group_id>/games/` | — |
| POST | `/api/everdell/groups/<group_id>/games/` | See below |
| GET | `/api/everdell/groups/<group_id>/games/<game_id>/` | — |
| PUT | `/api/everdell/groups/<group_id>/games/<game_id>/` | Requires `updated_at` |
| DELETE | `/api/everdell/groups/<group_id>/games/<game_id>/` | — |

### Create game body

`payload` mirrors Everdell `Game.toJson()` from `everdell_tracker` (`id`, `dateTime`, `expansionsUsed`, `players`, `notes`, `winnerIds`).

```json
{
  "id": "optional-client-uuid",
  "payload": {
    "id": "11111111-1111-1111-1111-111111111111",
    "dateTime": "2025-06-01T18:00:00.000Z",
    "expansionsUsed": ["base"],
    "players": [],
    "notes": "Friday game",
    "winnerIds": []
  }
}
```

`played_at`, `notes`, and `expansion_flags` can be sent explicitly; otherwise they are taken from `payload` (`dateTime`, `notes`, `expansionsUsed`).

### Update game (optimistic concurrency)

```json
{
  "updated_at": "2026-06-04T21:00:00.123456Z",
  "notes": "Updated notes",
  "payload": { }
}
```

`updated_at` must match the value from the last GET. If another user saved first, the API returns **409**:

```json
{
  "detail": "This game was updated by someone else. Refresh to see the latest version.",
  "current": { }
}
```

## Local testing

```powershell
cd c:\Users\kiero\Code\budgit
python manage.py migrate_schemas --shared --settings=budgit.settings_dev
python manage.py test everdell --settings=budgit.settings_dev
```

## Deploy

1. Merge `feature/everdell-phase1-api` → `main` (or deploy branch).
2. Confirm Render logs: `Applying everdell.0004_...` and `accounts.0004_...`
3. Smoke: see **`EVERDELL_PHASE1_SMOKE.md`** (or checklist below in PR).

## Next (Phase 2 — everdell_tracker repo)

- `EverdellApiService` using `www.budgit.lol`
- Login gate, group picker, replace local game storage for online mode
- Use `display_name` / `display_avatar_url` in roster UI

