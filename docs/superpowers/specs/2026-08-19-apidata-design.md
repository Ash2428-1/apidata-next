# apidata — Central API & Data Hub — Design Spec

Date: 2026-08-19
Status: Approved (pending final spec review)

## 1. Purpose

`apidata` is a standalone central data hub. It owns its own database and serves
data over a REST API secured by per-site API keys. Existing and future sites
(e.g. `xtend-eco-sales`, `xtend-financial`) stop owning their shared data and
instead read/write through `apidata`. It also aggregates third-party services
(Cartrack, Flickswitch, etc.) through configurable connectors, with manual file
upload as the fallback for services without an API.

The project lives in a GitHub repo named `apidata` so it is visible and
cloneable from any machine where the owner is logged into GitHub.

## 2. Architecture (Approach 1 — approved)

One Next.js (App Router, TypeScript, Tailwind) application that is BOTH:

- the **admin dashboard** (login-protected UI), and
- the **REST API** (`/api/v1/...`) consumed by other sites.

PostgreSQL runs alongside it in Docker on a single AWS EC2 instance
(Docker Compose: `app`, `postgres`, `caddy`). A built-in scheduler (node-cron
inside the app process) runs connector syncs.

Chosen over: separate API + dashboard apps (more to maintain), and self-hosted
Supabase (heavy, and connectors/keys/dashboard still need custom code).

## 3. Dashboard features (v1)

- **Login** — single-admin email/password login (dashboard only; sites use API
  keys, never dashboard accounts).
- **API keys** — create, name, view once, revoke. One key per site
  (e.g. `xtend-eco-sales`, `xtend-financial`). Keys are stored hashed.
- **Connectors** — add a connector (name, type e.g. Cartrack/Flickswitch,
  third-party API credentials stored encrypted, sync schedule cron). A
  scheduler pulls data on schedule into hub tables. Connector runs are logged
  with success/failure and record counts. Each connector type is a small
  plugin module implementing a common interface (`fetch()` → normalized rows),
  so new services are added without touching core code.
- **Uploads** — for services with no API: upload CSV/Excel, map columns to a
  data type, preview, import into the same hub tables connectors write to.
  Original files are kept on disk for audit.
- **Request log** — every API call recorded: timestamp, API key (site),
  endpoint, method, response status, latency. Viewable/filterable in the
  dashboard.

## 4. REST API (v1)

- Base: `https://<domain>/api/v1/...`, versioned so later changes never break
  existing sites.
- Auth: `x-api-key: <key>` header on every request. Missing/invalid/revoked →
  `401`. Unknown endpoint → `404`. Errors return a consistent JSON shape:
  `{ "error": { "code": "...", "message": "..." } }`.
- Read + write: sites `GET` data and `POST` new records, keeping the hub the
  single source of truth. Writes from a site are attributed to its API key.
- Data endpoints are generic per data type (e.g. `/api/v1/contacts`,
  `/api/v1/deals`, `/api/v1/vehicles`, `/api/v1/sims`), backed by hub tables.
- Example consumer call (from `xtend-eco-sales`):

  ```ts
  const res = await fetch(`${process.env.HUB_URL}/api/v1/deals`, {
    headers: { "x-api-key": process.env.HUB_API_KEY! },
  });
  const deals = await res.json();
  ```

- Migration is gradual: a site moves one data type at a time to the hub.

## 5. Database

PostgreSQL 16 in Docker. Core tables:

- `api_keys` — id, name, hashed key, created_at, revoked_at
- `connectors` — id, name, type, credentials (encrypted), cron schedule, enabled
- `connector_runs` — connector id, started/finished, status, records imported, error
- `uploads` — id, filename, data type, row count, uploaded_at, status
- `request_logs` — timestamp, key id, method, path, status, latency_ms
- Data tables — one per data type (contacts, deals, vehicles, sims, …), with
  `source` (connector name, upload, or site key) and `external_id` for
  idempotent re-syncs.

Backups: nightly `pg_dump` cron inside the postgres container to a local
backups directory, retained 14 days.

## 6. Deployment

- GitHub repo `apidata` → GitHub Actions: on push to `main`, build and deploy
  to EC2 over SSH (docker compose pull/build + up).
- HTTPS via Caddy reverse proxy with automatic certificates on the owner's
  domain (e.g. `apidata.<domain>` — see Open decisions).
- Environment secrets (DB password, admin password, encryption key) live in
  `.env` on the EC2 host only — never in the repo.

## 7. Security

- Dashboard behind login; API behind per-site keys; keys hashed at rest.
- Third-party connector credentials encrypted at rest (app-level encryption
  key in server env).
- HTTPS only. Postgres not exposed outside the Docker network.

## 8. Phase 2 (designed for, NOT in v1)

- **Webhooks (push)** — hub notifies registered site URLs when data changes.
- **Per-key rate limiting.**
- **Auto-generated API docs page** (OpenAPI) on the hub.

v1 keeps these out deliberately, but key/registry and endpoint design must not
preclude them (e.g. API versioning already in place; request log already
captures per-key traffic).

## 9. Open decisions (resolved at implementation/deploy time, not blockers)

- Exact domain/subdomain for the hub (e.g. `apidata.<your-domain>`) — needs the
  owner's domain choice and DNS access.
- Final list of v1 data types beyond the examples (contacts, deals, vehicles,
  sims) — confirmed when the first connectors are wired up.
- EC2 instance size — decided at provisioning based on expected load.

## 10. Success criteria

- Admin can log in, create an API key, and see requests from that key in the log.
- A Cartrack connector syncs on schedule; data appears in hub tables and is
  served at `/api/v1/vehicles`.
- A CSV upload imports records served at the corresponding endpoint.
- `xtend-eco-sales` can fetch at least one data type end-to-end using only its
  API key.
- Push to `main` deploys automatically; site reachable over HTTPS.
