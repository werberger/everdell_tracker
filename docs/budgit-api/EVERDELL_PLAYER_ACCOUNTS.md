> **Source of truth:** [budgit](https://github.com/werberger/budgit) repo `docs/EVERDELL_PLAYER_ACCOUNTS.md` @ `main` commit `e26e15b` (or later).  
> Do not edit API behaviour here — update Budgit docs, then re-copy this file.

# Everdell player identities & account linking

## Concepts

| Term | Meaning |
|------|--------|
| **Group member** | Budgit account with access to a scorebook (`EverdellGroupMember`) |
| **Player (roster row)** | A person on the score sheet in one group — globally unique **`id` (UUID)** |
| **Linked player** | Roster row with optional `linked_user_id` → Budgit account |

**Auto roster on membership (June 2026):** Every group member automatically gets a linked roster row when they create or join a group (`everdell/services.py` → `ensure_roster_player_for_user`, called from `add_member`). Migration `everdell.0006_backfill_roster_players_for_members` backfills existing members who joined before this behaviour existed. **Reasoning:** members with Everdell access should appear in the player database without a manual “add yourself” step; game autocomplete and UUID payloads stay consistent.

- **Identity is the player UUID**, not the display name.
- The same human can have **multiple player rows** (different groups, different spellings, different UUIDs).
- **At most one linked player per user per group** (you cannot link two roster rows to yourself in the same group).
- Guest / child players stay **unlinked** (`linked_user_id: null`).

## Display name & avatar

Each player has a **group-local profile** (`name`, `nickname`, `avatar`) and may optionally link to a **Budgit account profile** (`display_name`, `profile_picture` via `/api/everdell/me/`).

When linked, the member chooses per group how they appear:

| Field | Values | Effect |
|-------|--------|--------|
| `display_name_source` | `"player"` (default) or `"user"` | Use group `nickname` or account display name |
| `display_avatar_source` | `"player"` (default) or `"user"` | Use group `avatar` or account profile picture |

**Resolved fields** (read-only in API responses):

- `display_name` — what UIs should show for this player in this group
- `display_avatar_url` — absolute URL for the resolved avatar (or `null`)
- `user_display_name`, `user_avatar_url` — account profile values when linked (for settings UI)

Only the **linked account** can change `display_name_source` / `display_avatar_source` (403 for other group members).

### Nickname

- `nickname` defaults to `name` on create if omitted or blank.
- Use `nickname` for how someone is known **in this group** (e.g. "Jules" vs legal name on the sheet).
- `name` remains the roster / sheet label; clients may show `display_name` instead.

## Player fields

| Field | Required | Notes |
|-------|----------|--------|
| `id` | (server) | UUID, globally unique |
| `group_id` | (from URL on create) | Which scorebook |
| `name` | Yes | Roster / sheet name |
| `nickname` | No | Defaults to `name`; group-local display name |
| `avatar` | No | Group-local image (multipart PATCH) |
| `avatar_url` | (read) | URL for group avatar |
| `linked_user_id` | No | Budgit user when claimed |
| `is_linked_to_me` | (read) | True when linked to the current user |
| `display_name_source` | No | `"player"` or `"user"` (linked only) |
| `display_avatar_source` | No | `"player"` or `"user"` (linked only) |
| `display_name` | (read) | Resolved name for UI |
| `display_avatar_url` | (read) | Resolved avatar URL |
| `user_display_name` | (read) | Account name when linked |
| `user_avatar_url` | (read) | Account avatar when linked |
| `email`, `phone` | No | Optional contact |
| `date_of_birth` | No | ISO date |
| `first_played_at` | No | Defaults to create time if omitted |
| `is_board_gamer` | No | `true` / `false` / `null` |
| `profile_extra` | No | JSON object for future stats |
| `created_at`, `updated_at` | (server) | Audit |

Duplicate **names in the same group are allowed** (different UUIDs).

**Disambiguation in UI (Flutter, June 2026):** When multiple roster rows share the same resolved `display_name`, autocomplete shows `Name · AB12` (last four characters of the player UUID). Settings allows each linked member to set a per-group **nickname** via `PATCH .../players/<id>/` with `display_name_source: "player"`.

## Account profile (`/api/everdell/me/`)

Shared Budgit account fields used across Everdell groups:

| Field | Notes |
|-------|--------|
| `display_name` | Everdell-facing name; falls back to full name or username when empty |
| `profile_picture` | Account avatar (multipart PATCH) |
| `profile_picture_url` | (read) Absolute URL |

When a linked player sets `display_name_source: "user"`, `display_name` uses this account value.

## API (Budgit)

Base: `https://www.budgit.lol`

| Method | Path | Purpose |
|--------|------|---------|
| GET/PATCH | `/api/everdell/me/` | Account display name + profile picture |
| GET | `/api/everdell/players/mine/` | All roster rows linked to you, all groups |
| GET/POST | `/api/everdell/groups/{group_id}/players/` | List / create |
| GET/PATCH | `/api/everdell/groups/{group_id}/players/{player_id}/` | Detail / update profile |
| POST | `/api/everdell/groups/{group_id}/players/{player_id}/link/` | Claim row → your account |

### Create with nickname and link

```json
{
  "name": "Julia",
  "nickname": "Jules",
  "link_to_me": true,
  "display_name_source": "player",
  "display_avatar_source": "player",
  "email": "julia@example.com",
  "is_board_gamer": true
}
```

### Switch to account display name (linked player only)

```json
PATCH /api/everdell/groups/{group_id}/players/{player_id}/
{
  "display_name_source": "user",
  "display_avatar_source": "user"
}
```

### Update account profile

```json
PATCH /api/everdell/me/
{
  "display_name": "Kieron"
}
```

Avatar uploads: `multipart/form-data` with `profile_picture` or player `avatar` on PATCH.

### Claim existing row (after you have an account)

```http
POST /api/everdell/groups/{group_id}/players/{player_id}/link/
```

Empty body. **409** if row already linked to someone else, or you already linked another row in that group.

## Multi-group example

User links players in Group A and Group B:

- Group A: `nickname: "Captain"`, `display_name_source: "player"` → shows "Captain"
- Group B: `nickname: "Kieron"`, `display_name_source: "user"` → shows account `display_name`

Each group can have its own nickname and avatar while sharing one Budgit login.

## Future UX (not implemented yet)

Provisioning only today — product can choose among:

1. **Self-claim** — After login, show unlinked players in groups you belong to; user taps “This is me” → `POST .../link/`.
2. **Email hint** — Suggest rows where `player.email` matches account email (user still confirms).
3. **Invite at group join** — When User B joins via invite code, prompt: “Link yourself as an existing player?” with list of unlinked names.

**“My games” (Phase 2+):** Games should reference **player UUIDs** in payload (not only names). Then:

`GET /api/everdell/games/mine/` → games in member groups where payload includes a linked player id.

## Flutter / everdell_tracker

- Store and send **`player.id`** (UUID) in game payloads when online.
- On login, call `GET /api/everdell/players/mine/` and `GET /api/everdell/me/` for identity.
- Show **`display_name`** and **`display_avatar_url`** in roster UI (not raw `name` when linked).
- Roster autocomplete: `GET .../groups/{active_group_id}/players/`.

