# Budgit + Everdell Tracker — Agent Handoff (Phase 0+)

> **Audience:** Agent working in the **Budgit** Django codebase.  
> **Everdell Flutter repo:** Separate GitHub repo (`everdell_tracker`) — do not merge codebases.  
> **Integration plan (full):** See `BUDGIT_EVERDELL_INTEGRATION_PLAN.md` in Everdell repo (copy alongside this file).

---

## 1. Product intent

- Users log into **https://budgit.lol** (existing Django app).
- From the Budgit menu, open **Everdell Tracker** at **https://everdell.budgit.lol** (Flutter web static site on Render).
- **Everdell data is shared by group**, not by Budgit budget tenant:
  - John (budget tenant A) and Julia (budget tenant B, or no budget) can share one scorebook if they join the same **Everdell group**.
- **Server is source of truth** for games (v1): no offline sync; Flutter will call API after Phase 0+.
- Julia may never use budget features; she only needs Budgit **login** + Everdell group membership.

---

## 2. Architecture (locked decisions)

```
┌─────────────────────────────────────────────────────────────────┐
│ Render project: budgit                                          │
├─────────────────────────────────────────────────────────────────┤
│ budgit (Python 3 / Django)     → budgit.lol, www.budgit.lol     │
│ budgit-online-db (Postgres 16) → shared DB, everdell schema     │
│ everdell_tracker-web (Static)  → everdell.budgit.lol            │
└─────────────────────────────────────────────────────────────────┘

GitHub repos (SEPARATE):
  • budgit repo      → Django API, auth, migrations, menu link
  • everdell_tracker → Flutter UI only (later: API client)
```

| Concern | Decision |
|---------|----------|
| Merge repos? | **No** |
| Second Postgres? | **No** — use `budgit-online-db` |
| Everdell scope key | `everdell_group_id`, **not** `tenant_id` |
| Budget data isolation | Unchanged — tenant-scoped as today |
| iPhone | Flutter PWA at `everdell.budgit.lol` (done on Render) |
| Multiple scorebooks | Yes — user can be in many groups; UI switcher later |

---

## 3. Render / infra — COMPLETED (do not redo)

| Item | Status |
|------|--------|
| `DATABASE_URL` on `budgit` service | ✅ Set (`postgresql://…/budgit_online_db`) |
| Custom domains on Django service | ✅ `budgit.lol`, `www.budgit.lol` |
| `everdell_tracker-web` in **budgit** project | ✅ Moved from ungrouped |
| Custom domain on Everdell static | ✅ `everdell.budgit.lol` (Crazy Domains CNAME) |
| Everdell static redeploy | ✅ Latest `main` deployed |
| DNS | ✅ Propagated; site loads |

**Django start command on Render:** `./render_start.sh`  
**Stack:** Django + PostgreSQL 16 (Singapore).

---

## 4. What the Budgit agent must discover in-repo

Before coding, read and document:

| Item | Where to look |
|------|----------------|
| User model | `AUTH_USER_MODEL`, custom user if any |
| Tenant / household model | How budget isolation works today |
| Auth | Session vs JWT; login URL; middleware |
| `render_start.sh` | Does it run `migrate`? Gunicorn? Collectstatic? |
| URL routing | Root `urls.py`, API patterns |
| Existing API style | DRF? Plain Django views? |
| CORS / CSRF | Settings for trusted origins |
| Session cookie settings | `SESSION_COOKIE_DOMAIN`, `CSRF_TRUSTED_ORIGINS`, `ALLOWED_HOSTS` |

**Missing info (agent fills in during exploration):**

- Exact tenant model name and fields
- Whether `www.budgit.lol` and `budgit.lol` both set session cookies correctly today
- Current menu/nav template location for adding “Everdell Tracker” link

---

## 5. Django / database — migrations

### Schema namespace

Create PostgreSQL schema: **`everdell`** (keeps tables separate from Budgit `public` budget tables).

Alternatively use table prefix `everdell_` in `public` if project avoids multi-schema — **prefer `everdell` schema** if team is comfortable.

### Phase 0 tables (minimum)

**`everdell.groups`**

- `id` UUID PK
- `name` VARCHAR
- `invite_code` VARCHAR UNIQUE (nullable until generated)
- `created_by_id` FK → User
- `created_at`, `updated_at`

**`everdell.group_members`**

- `group_id` FK
- `user_id` FK
- `role` VARCHAR (`owner`, `member`) — optional v1
- `joined_at`
- Unique (`group_id`, `user_id`)

### Django implementation options

1. **New Django app** `everdell` with `models.py`, `Meta.db_table` or `db_table` in schema via `Meta.db_table = '"everdell"."groups"'` OR use `django.contrib.postgres` and `db_table` / custom router.
2. Simpler v1: app `everdell` with models `EverdellGroup`, `EverdellGroupMember` and migrations that run `RunSQL('CREATE SCHEMA IF NOT EXISTS everdell')` in first migration.

### Running migrations on Render

Inspect `./render_start.sh`:

- If it already runs `python manage.py migrate` → new migrations deploy automatically on push.
- If **not**, add `python manage.py migrate --noinput` before starting Gunicorn, **or** use Render **Release Command**: `python manage.py migrate --noinput`.

**Never assume** push alone migrates if `render_start.sh` skips migrate.

---

## 6. Phase 0 — API (implement in Budgit only)

Base path suggestion: **`/api/everdell/`** (match existing Budgit API conventions if different).

All endpoints require **authenticated user** (`@login_required` or DRF `IsAuthenticated`).

| Method | Path | Behavior |
|--------|------|----------|
| GET | `/api/everdell/groups/` | List groups current user belongs to |
| POST | `/api/everdell/groups/` | Create group; user becomes owner; generate `invite_code` |
| POST | `/api/everdell/groups/join/` | Body: `{ "invite_code": "..." }` → add membership |
| GET | `/api/everdell/groups/<uuid>/` | Group detail (404 if not member) |

Response shape (example):

```json
{
  "id": "uuid",
  "name": "Family games",
  "invite_code": "ABC123",
  "member_count": 2
}
```

**Authorization rule (critical):** For any future game endpoints, always check `user ∈ group.members` before returning data. Never authorize Everdell routes with `tenant_id` alone.

**Errors:** Return **404** for non-member access to avoid leaking resource existence.

---

## 7. Phase 0 — Session / cookies (required for subdomain login)

Everdell is on **`everdell.budgit.lol`**, Budgit on **`budgit.lol`**.

In Django `settings.py` (production), set:

```python
SESSION_COOKIE_DOMAIN = ".budgit.lol"
CSRF_COOKIE_DOMAIN = ".budgit.lol"  # if using cookie-based CSRF
CSRF_TRUSTED_ORIGINS = [
    "https://budgit.lol",
    "https://www.budgit.lol",
    "https://everdell.budgit.lol",
]
ALLOWED_HOSTS  # must include budgit.lol, www, everdell.budgit.lol as needed
```

Also configure **CORS** if Flutter uses `fetch(..., credentials: 'include')` from `everdell.budgit.lol` to `budgit.lol`:

- Allow origin `https://everdell.budgit.lol`
- `Access-Control-Allow-Credentials: true`

**Phase 0 proof test:**

1. Log in on `https://budgit.lol`
2. Open `https://everdell.budgit.lol` (or a test page) that calls `GET /api/everdell/groups/` with credentials
3. Should return 200 + JSON, not 401/403

---

## 8. Phase 0 — Budgit UI

- Add nav/menu item: **Everdell Tracker** → `https://everdell.budgit.lol` (new tab or same tab).
- Optional v1.1: simple **Manage Everdell groups** page on Budgit (create group, show invite link). Can defer if API tested via Django admin or curl first.

---

## 9. Phase 0 — Proof-of-concept exit criteria

- [ ] Migration applied on production Postgres (`everdell` schema + tables).
- [ ] User A creates group via API or UI.
- [ ] User A gets invite code.
- [ ] User B (different Budgit account, different or no budget tenant) joins via invite.
- [ ] Both users see same group in `GET /api/everdell/groups/`.
- [ ] Session works cross-subdomain (login budgit.lol → API works from everdell.budgit.lol).
- [ ] Budget features still work for existing users (regression smoke test).

---

## 10. Phase 1+ (after Phase 0 — do not block POC)

### Phase 1 — Games API

Tables (schema `everdell`):

- `players` (per group roster)
- `games` — include `group_id`, `payload` JSONB (mirror Everdell export), `updated_at`, `created_by`, `updated_by`

Endpoints under `/api/everdell/groups/<group_id>/games/` CRUD.

**Concurrency:** PUT requires matching `updated_at` or return **409 Conflict**.

### Phase 2 — Flutter (`everdell_tracker` repo, separate agent)

- Login gate → redirect to Budgit login with `?next=https://everdell.budgit.lol/...`
- `EverdellApiService` replacing local-only storage for games
- Group switcher
- Keep JSON export as backup

Reference Everdell export shape: `everdell_tracker/lib/services/data_export_service.dart`.

### Phase 3 — Polish

- Group management UI on Budgit
- Separate PWA manifest on Everdell subdomain (already possible)
- Import legacy local JSON into a group

---

## 11. Security checklist (Budgit agent)

- [ ] Everdell queries always filter by `group_id` + membership
- [ ] No budget SQL joined into Everdell list endpoints
- [ ] Invite codes unguessable (e.g. 8+ char random)
- [ ] Rate-limit group create / join (basic throttling)
- [ ] Do not expose internal DB hostnames in API responses

---

## 12. Everdell Flutter repo — current state (for context)

- Version ~2.3.0; scoring + visual card selection implemented.
- Storage: **local only** (Hive / web localStorage) via `PlatformStorageService`.
- Deploy: Render static `everdell_tracker-web` → `everdell.budgit.lol`.
- **No Budgit API integration yet** — waits on Phase 0/1 from Budgit.

---

## 13. Suggested agent task prompt (copy-paste)

```
Implement Everdell integration Phase 0 in this Django Budgit repo.

Read BUDGIT_AGENT_HANDOFF.md (and BUDGIT_EVERDELL_INTEGRATION_PLAN.md if present).

Goals:
1. New Django app `everdell` with models EverdellGroup, EverdellGroupMember in PostgreSQL schema `everdell`.
2. Migrations; ensure render_start.sh or Render release runs `manage.py migrate`.
3. REST or JSON API: list/create groups, join by invite_code — authenticated only.
4. Set SESSION_COOKIE_DOMAIN=.budgit.lol and CSRF_TRUSTED_ORIGINS for everdell.budgit.lol.
5. CORS for everdell.budgit.lol if needed for credentialed API calls.
6. Add menu link to https://everdell.budgit.lol
7. Do NOT change budget/tenant authorization logic except adding the menu link.
8. Document how to test with two users.

Stop after Phase 0 exit criteria; do not implement games API until Phase 0 is verified.
```

---

## 14. What NOT to do

- Do not merge Everdell Flutter code into Budgit repo.
- Do not create a second Render Postgres instance for v1.
- Do not scope Everdell games by Budgit `tenant_id`.
- Do not rely on Render to auto-create tables without `migrate`.

---

*Handoff version 1.1 — Render + DNS complete; Django migrate via `render_start.sh` TBD by agent.*
