# RoastCart — Milestone: Azure PostgreSQL Migration

**Branch:** `feature/azure-postgres`  
**Status:** Completed — database restored and hybrid connectivity verified  
**Focus:** Azure managed database, PostgreSQL migration, networking, configuration, and operational cost control

### Cloud Networking and Secure Database Connectivity

- Transitioned Flask database communication from Docker's internal service-name DNS (`postgres-db`) to the Azure PostgreSQL managed service endpoint.
- Established outbound PostgreSQL connectivity over TCP port `5432` from a locally running Flask container to Azure.
- Used Azure PostgreSQL public networking with firewall-controlled access for hybrid integration testing.
- Configured TLS-encrypted PostgreSQL connections using `sslmode=require`.
- Externalized the database connection string using Docker Compose environment-variable interpolation, allowing the same application image to connect to different database environments.
- Verified cloud connectivity and application functionality through SQL queries, Flask API endpoints, and Nginx reverse-proxy requests.

**Scope:** This milestone demonstrates public endpoint connectivity, database access controls, DNS resolution, and TLS encryption. Azure VNet integration, private endpoints, and more advanced network security configurations are reserved for subsequent deployment milestones.

## Objective

Migrate RoastCart's existing PostgreSQL database from a Docker-managed local container and named volume into **Azure Database for PostgreSQL Flexible Server**, while continuing to run the production-built React/Nginx and Flask/Gunicorn containers locally. Validate the full application path before deploying the application itself to Azure Container Apps (ACA).

## Architecture

```mermaid
flowchart TB
  subgraph Local[MacBook — Docker Compose hybrid test]
    Browser[Browser / curl] --> FE[React static build + Nginx\nlocalhost:3000]
    FE -->|/api reverse proxy| BE[Flask + Gunicorn\nlocalhost:5000]
  end
  BE -->|PostgreSQL over TLS :5432| DB[(Azure Database for PostgreSQL\nFlexible Server: roastcart / products)]
  ACR[Azure Container Registry\nGit-SHA-tagged frontend/backend images] -.->|Next milestone: ACA| ACA[Azure Container Apps]
  ACA -.-> DB
```

**Before:** Docker Compose runs frontend + backend + `postgres-db`; a named volume preserves live PostgreSQL data.  
**After:** `docker-compose.azure-test.yml` runs frontend + backend locally; PostgreSQL is hosted in Azure. The original fully local Compose setup is retained for isolated development and regression tests.

## What was implemented

- Provisioned Azure Database for PostgreSQL Flexible Server and created a `roastcart` application database.
- Exported the existing local database using `pg_dump` from the running `postgres:15-alpine` container; restored schema and product records with `pg_restore`.
- Connected to Azure using a **temporary PostgreSQL client container**, avoiding a native PostgreSQL installation on macOS.
- Used the Azure server hostname and TLS-enabled SQLAlchemy/psycopg connection string in a separate Git-ignored `.env.azure` file.
- Added an isolated `docker-compose.azure-test.yml` containing **only** the React/Nginx and Flask/Gunicorn services (no local PostgreSQL service, volume, or DB `depends_on`).
- Confirmed local Nginx-to-Flask communication still works over the Compose network while Flask queries Azure PostgreSQL.
- Stopped the hybrid containers and Azure PostgreSQL server after testing to limit compute usage.

## Verification evidence

Commands completed successfully:

```bash
docker compose -f docker-compose.azure-test.yml ps
curl http://localhost:5000/api/v1/health
curl http://localhost:5000/api/v1/products
curl http://localhost:3000/api/v1/products

docker exec roastcart_flask_backend python -c \
  'import os; from sqlalchemy.engine import make_url; print(make_url(os.environ["DATABASE_URL"]).host)'
```

**Observed:** Only the frontend and backend local containers were running; API requests returned the expected restored coffee products; the backend's active `DATABASE_URL` hostname matched the new Azure PostgreSQL endpoint. A passing `/health` check validates only what that endpoint checks; the product endpoint is the database-dependent test.

## Key learning points

| Concept                      | Understanding demonstrated                                                                                                                                                       |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Docker named volume          | Persists **live** database files across container recreation; `docker compose down` preserves named volumes unless removed explicitly.                                           |
| Logical backup               | `pg_dump -Fc` produces a point-in-time, portable archive; it is **not** a live volume or continuous synchronization.                                                             |
| Database vs. table           | `CREATE DATABASE roastcart` creates the database; `pg_restore` reconstructs its tables, indexes, constraints, and records.                                                       |
| PostgreSQL client vs. server | `docker run postgres:15-alpine psql ...` runs an ephemeral **client**, not another database server.                                                                              |
| Hybrid cloud testing         | Local production-built app containers validate connectivity to an external managed database before full ACA deployment.                                                          |
| Configuration injection      | `--env-file .env.azure` provides **Compose interpolation** values; `environment: DATABASE_URL: ${DATABASE_URL:?...}` injects the chosen value into Flask.                        |
| Health and readiness         | Application responsiveness does not automatically prove database availability.                                                                                                   |
| Cost control                 | Stopping Flexible Server stops compute charges; provisioned storage and applicable backup charges can remain. Azure can automatically restart a stopped server after seven days. |

## Run the hybrid test again

Store your actual connection string **outside Git** in `.env.azure`:

```dotenv
DATABASE_URL='postgresql+psycopg://APP_USER:URL_ENCODED_PASSWORD@YOUR_SERVER.postgres.database.azure.com:5432/roastcart?sslmode=require'
```

```bash
# Start the Azure PostgreSQL server first (replace placeholders).
az postgres flexible-server start -g YOUR_RESOURCE_GROUP -n YOUR_SERVER

# From the RoastCart repo root; stop any overlapping local stack first.
docker compose -f docker-compose.prod.yml down   # if it is running; do NOT add -v

docker compose --env-file .env.azure -f docker-compose.azure-test.yml config --quiet
docker compose --env-file .env.azure -f docker-compose.azure-test.yml up -d --build
curl http://localhost:5000/api/v1/products
curl http://localhost:3000/api/v1/products

# Shut down test containers and cloud DB when finished.
docker compose -f docker-compose.azure-test.yml down
az postgres flexible-server stop -g YOUR_RESOURCE_GROUP -n YOUR_SERVER
```

> **Security:** Do not commit `.env.azure`, `.env`, database dumps, or real credentials. Use restricted firewall rules and TLS for the hybrid stage. Production ACA will use environment settings/secrets and preferably a least-privileged application DB role; `sslmode=verify-full` with certificate validation is the stronger production TLS posture.

## Scope and next milestone

This milestone validates the initial one-time database migration and hybrid connectivity. It does **not** provision or deploy ACA, configure Key Vault/managed identity, or introduce automatic schema evolution. Future table/column changes should use versioned migrations (e.g., Alembic), not overwriting Azure with another local dump.

**Next:** `feature/azure-container-apps` — run the existing SHA-tagged production images from ACR on ACA, configure ingress/upstream routing, secure the database connection, and automate deployment after manual verification.
