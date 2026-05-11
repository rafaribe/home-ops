# PostgreSQL → SQLite Migration Guide

Services using the `home-ops` CNPG cluster (`home-ops-rw.database.svc.cluster.local`).

---

## Service Inventory

| Service | Namespace | SQLite Support | Notes |
|---|---|---|---|
| autobrr | downloads | ✅ Yes (default) | Was postgres, can revert |
| prowlarr | downloads | ✅ Yes (default) | SQLite is native |
| sonarr | downloads | ✅ Yes (default) | SQLite is native |
| readarr | downloads | ✅ Yes (default) | SQLite is native |
| bazarr | downloads | ✅ Yes (default) | SQLite is native |
| jellyseerr | media | ✅ Yes (default) | SQLite is native |
| gotify | observability | ✅ Yes (default) | SQLite is the default |
| mealie | services | ✅ Yes | Supports SQLite via `DB_ENGINE=sqlite` |
| n8n | services | ✅ Yes (default) | SQLite is default; postgres used for queue mode |
| tandoor | services | ✅ Yes | Django supports SQLite |
| home-assistant | home | ✅ Yes (default) | SQLite is native, recorder component |
| lubelog | services | ✅ Yes (default) | SQLite is default |
| romm | games | ❌ No | Dropped SQLite in v3.0; requires MariaDB/MySQL |
| miniflux | services | ❌ No | PostgreSQL only by design |
| authentik | security | ❌ No | PostgreSQL required |
| affine | services | ❌ No | PostgreSQL only |
| docmost | services | ❌ No | PostgreSQL only |
| immich | home | ❌ No | PostgreSQL + pgvecto.rs required (uses `immich-v4` cluster) |
| sparkyfitness | home | ❌ No | PostgreSQL required for server component |
| open-webui | ai | ⚠️ Partial | SQLite for app data, but loses vector search without pgvector |

---

## Migration Steps per Service

### General Prerequisites

```bash
# Scale down the app before migrating
kubectl scale deploy <app> -n <namespace> --replicas=0
```

---

### autobrr

autobrr defaults to SQLite. Migration is just removing the postgres config.

1. Export data from postgres:
   ```bash
   kubectl exec -n downloads deploy/autobrr -- autobrr export --config /config/config.toml > autobrr-export.json
   ```
2. Edit helmrelease: remove `AUTOBRR__DATABASE_TYPE`, `AUTOBRR__POSTGRES_*` env vars.
3. Add SQLite persistence (PVC at `/config`).
4. Redeploy — autobrr will create a fresh SQLite DB at `/config/autobrr.db`.
5. Re-add indexers/filters manually (autobrr has no import for postgres→sqlite).

> **Note:** History/stats will be lost. Filters and indexers must be reconfigured.

---

### prowlarr / sonarr / readarr / bazarr

All \*arr apps use SQLite natively. They were configured with postgres via `POSTGRES_*` env vars.

**Steps (same for all):**

1. Dump postgres DB:
   ```bash
   APP=sonarr  # change per app
   kubectl exec -n database home-ops-1 -- pg_dump -U postgres $APP > $APP.sql
   ```
2. Scale down the app:
   ```bash
   kubectl scale deploy $APP -n downloads --replicas=0
   ```
3. Remove postgres env vars from helmrelease (`POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_MAINDB`, `POSTGRES_LOGDB`).
4. Ensure PVC is mounted at `/config`.
5. Redeploy — the app will create a fresh SQLite DB.
6. Restore via the app's built-in **Backup/Restore** UI (Settings → Backup), or accept fresh state (indexers/history will be lost but media library rescans).

> **Tip:** \*arr apps store media library in SQLite separately from logs. A fresh deploy + library rescan is often faster than migrating.

---

### jellyseerr

1. Scale down:
   ```bash
   kubectl scale deploy jellyseerr -n media --replicas=0
   ```
2. Remove `DB_TYPE=postgres` and `DB_*` env vars from helmrelease.
3. Ensure PVC is mounted at `/app/config`.
4. Redeploy — jellyseerr defaults to SQLite at `/app/config/db/db.sqlite3`.
5. Re-sync with Plex/Sonarr/Radarr via Settings (request history will be lost).

---

### gotify

Gotify's **default** is SQLite. It was explicitly configured to use postgres.

1. Scale down:
   ```bash
   kubectl scale deploy gotify -n observability --replicas=0
   ```
2. Remove postgres env vars (`GOTIFY_DATABASE_DIALECT`, `GOTIFY_DATABASE_CONNECTION`) from helmrelease.
3. Ensure PVC is mounted at `/app/data`.
4. Redeploy — gotify will create `gotify.db` SQLite file automatically.
5. Recreate application tokens (clients/apps will be lost).

---

### mealie

1. Scale down:
   ```bash
   kubectl scale deploy mealie -n services --replicas=0
   ```
2. Export recipes via Mealie UI: **Admin → Backups → Create Backup** (downloads a zip).
3. Remove postgres env vars, add `DB_ENGINE: sqlite` to helmrelease.
4. Ensure PVC at `/app/data`.
5. Redeploy.
6. Import backup via UI: **Admin → Backups → Upload & Restore**.

---

### n8n

n8n defaults to SQLite. It was configured with postgres for reliability.

1. Export all workflows and credentials:
   ```bash
   kubectl exec -n services deploy/n8n -- n8n export:workflow --all --output=/home/node/workflows.json
   kubectl exec -n services deploy/n8n -- n8n export:credentials --all --output=/home/node/credentials.json
   kubectl cp services/$(kubectl get pod -n services -l app.kubernetes.io/name=n8n -o name | head -1 | cut -d/ -f2):/home/node/workflows.json ./n8n-workflows.json
   kubectl cp services/$(kubectl get pod -n services -l app.kubernetes.io/name=n8n -o name | head -1 | cut -d/ -f2):/home/node/credentials.json ./n8n-credentials.json
   ```
2. Scale down:
   ```bash
   kubectl scale deploy n8n -n services --replicas=0
   ```
3. Remove `DB_TYPE`, `DB_POSTGRESDB_*` env vars from helmrelease.
4. Ensure PVC at `/home/node/.n8n`.
5. Redeploy.
6. Import:
   ```bash
   kubectl exec -n services deploy/n8n -- n8n import:workflow --input=/home/node/workflows.json
   kubectl exec -n services deploy/n8n -- n8n import:credentials --input=/home/node/credentials.json
   ```

> ⚠️ **Important:** Keep `N8N_ENCRYPTION_KEY` identical — credentials are encrypted with it.

---

### tandoor

Tandoor is Django-based and supports SQLite.

1. Export data:
   ```bash
   kubectl exec -n services deploy/tandoor -- python manage.py dumpdata --natural-foreign --natural-primary -e contenttypes -e auth.Permission > tandoor-dump.json
   ```
2. Scale down.
3. Remove `DB_ENGINE=django.db.backends.postgresql` and `POSTGRES_*` vars. Set `DB_ENGINE=django.db.backends.sqlite3`.
4. Ensure PVC at `/opt/recipes/mediafiles` (or wherever `/opt/recipes` is mounted).
5. Redeploy — Django will create `db.sqlite3`.
6. Run migrations and import:
   ```bash
   kubectl exec -n services deploy/tandoor -- python manage.py migrate
   kubectl exec -n services deploy/tandoor -- python manage.py loaddata /path/to/tandoor-dump.json
   ```

---

### home-assistant

Home Assistant uses SQLite by default for the recorder. If you configured an external postgres recorder:

1. Remove the `recorder:` postgres config from `configuration.yaml`.
2. HA will automatically use SQLite at `/config/home-assistant_v2.db`.
3. History prior to migration will be lost (or you can use `db_url: sqlite:////config/home-assistant_v2.db` explicitly).

> History data is generally not worth migrating — HA history is large and the schema differs.

---

### lubelog

Lubelog defaults to SQLite. Remove any postgres connection string env var and it will use its built-in SQLite.

1. Scale down.
2. Remove `POSTGRES_CONNECTION` env var from helmrelease.
3. Ensure PVC at `/app/data`.
4. Redeploy.

---

## Services That Cannot Migrate to SQLite

| Service | Reason | Alternative |
|---|---|---|
| **miniflux** | PostgreSQL-only by design (author's explicit choice) | Keep on CNPG or use a lightweight managed postgres like [PGlite](https://pglite.dev/) sidecar |
| **authentik** | Requires PostgreSQL + Redis | Keep on CNPG |
| **affine** | PostgreSQL is the only supported DB | Keep on CNPG |
| **docmost** | PostgreSQL only | Keep on CNPG |
| **romm** | Dropped SQLite in v3.0; requires MariaDB/MySQL | Migrate to MariaDB (separate from CNPG) |
| **immich** | Requires pgvecto.rs extension for ML vector search | Keep on dedicated `immich-v4` CNPG cluster |
| **sparkyfitness** | PostgreSQL required for server | Keep on CNPG |
| **open-webui** | Can use SQLite but loses vector/RAG features | Keep on CNPG if using RAG |

---

## Summary

After migration, the only services that **must** stay on PostgreSQL are:
- `miniflux`, `authentik`, `affine`, `docmost`, `sparkyfitness` → keep on `home-ops` CNPG cluster
- `immich` → keep on `immich-v4` CNPG cluster
- `romm` → needs MariaDB (not postgres, not sqlite)

This would reduce the `home-ops` cluster load significantly and eliminate postgres as a dependency for ~10 services.
