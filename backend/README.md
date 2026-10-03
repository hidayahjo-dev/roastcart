# RoastCart - Production Flask Backend Milestone

Branch: `feature/backend-prod-container`

## Milestone Overview

This branch productionises the RoastCart Flask backend and completes the local production-style three-tier application stack.

The backend no longer relies on Flask's built-in development server. Instead, the production container runs the Flask application behind **Gunicorn**, uses a dedicated **non-root Linux user**, and participates in Docker Compose health-based startup sequencing with PostgreSQL.

Together with the production React/Nginx frontend, RoastCart now mirrors a more realistic production runtime before deployment to Azure.

## Architecture at This Milestone

```text
Browser
  |
  | http://localhost:3000
  v
+---------------------------+
| Frontend Container        |
| Nginx :80                 |
| - serves React build      |
| - reverse proxies /api/*  |
+-------------+-------------+
              |
              | http://roastcart-backend:5000
              v
+---------------------------+
| Backend Container         |
| Gunicorn :5000            |
|   |- worker 1             |
|   `- worker 2             |
| Flask application         |
| Linux user: appuser       |
+-------------+-------------+
              |
              | DATABASE_URL
              | postgres-db:5432
              v
+---------------------------+
| PostgreSQL Container      |
| PostgreSQL 15 Alpine      |
| persistent Docker volume  |
+---------------------------+
```

## What Changed

### 1. Separate Development and Production Dockerfiles

The backend now distinguishes development and production runtime behaviour:

```text
backend/
|- Dockerfile.dev
`- Dockerfile.prod
```

Development continues to use the Flask development server:

```dockerfile
CMD ["python", "run.py"]
```

Production uses Gunicorn:

```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "run:app"]
```

`run:app` means:

```text
run    -> run.py module
app    -> Flask application object defined inside run.py
```

### 2. Production WSGI Server

Gunicorn now owns the production HTTP application process instead of `app.run()`.

When Gunicorn imports `run:app`, the following block does not execute:

```python
if __name__ == "__main__":
    app.run(...)
```

This keeps the same Flask application code usable in both development and production while changing only the runtime server.

### 3. Non-root Container User

The production image creates a restricted Linux user:

```dockerfile
RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser \
    && chown -R appuser:appgroup /app

USER appuser
```

`appuser` is the Linux identity running Gunicorn inside the backend container. It is **not** the PostgreSQL database user.

This applies the principle of least privilege: the application does not need to run as container `root` to serve requests.

### 4. Service Health Checks

PostgreSQL now exposes a Compose health check:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

The backend waits for PostgreSQL to become healthy:

```yaml
depends_on:
  postgres-db:
    condition: service_healthy
```

The Flask backend also exposes:

```text
GET /api/v1/health
```

and Compose checks it from inside the backend container using:

```text
http://localhost:5000/api/v1/health
```

Here, `localhost` correctly refers to the backend container itself.

### 5. Production-safe Python Runtime Settings

The production Dockerfile includes:

```dockerfile
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
```

- `PYTHONDONTWRITEBYTECODE=1` avoids generating `.pyc` files in the container.
- `PYTHONUNBUFFERED=1` writes application output directly to stdout/stderr, which is useful for container logging.

## Production Backend Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser \
    && chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "run:app"]
```

## Docker Compose Configuration Split

The project should now keep development and production orchestration explicit:

```text
roastcart/
|- docker-compose.dev.yml
|- docker-compose.prod.yml
|- backend/
|  |- Dockerfile.dev
|  `- Dockerfile.prod
`- frontend/
   |- Dockerfile.dev
   `- Dockerfile.prod
```

Recommended commands:

```bash
# Development stack
docker compose -f docker-compose.dev.yml up --build

# Production-style local stack
docker compose -f docker-compose.prod.yml up --build
```

## Verification

The production stack was verified successfully through all three request paths.

### Backend health

```bash
curl http://localhost:5000/api/v1/health
```

### Backend API directly

```bash
curl http://localhost:5000/api/v1/products
```

### Full request path through Nginx reverse proxy

```bash
curl http://localhost:3000/api/v1/products
```

The final request verifies:

```text
Host
  -> Nginx
  -> Docker service DNS
  -> Gunicorn
  -> Flask
  -> SQLAlchemy / Psycopg
  -> PostgreSQL
```

## Useful Operational Commands

```bash
# Validate Compose configuration without starting containers
docker compose -f docker-compose.prod.yml config

# Build and start production stack
docker compose -f docker-compose.prod.yml up --build

# Run detached
docker compose -f docker-compose.prod.yml up --build -d

# Inspect container state and health
docker compose -f docker-compose.prod.yml ps

# Inspect backend logs
docker compose -f docker-compose.prod.yml logs roastcart-backend

# Follow backend logs
docker compose -f docker-compose.prod.yml logs -f roastcart-backend

# Stop containers
docker compose -f docker-compose.prod.yml down
```

## Backend `.dockerignore`

The backend build context excludes development artefacts and sensitive local files:

```text
__pycache__/
*.pyc
*.pyo
.venv/
venv/
.env
.git/
.gitignore
.pytest_cache/
```

This keeps unnecessary files out of the build context and helps prevent `.env` secrets from being copied into image layers.

## Milestone Result

RoastCart now has a complete local production-style runtime:

- React is compiled into production static assets.
- Nginx serves the frontend and acts as the API reverse proxy.
- Flask is served by Gunicorn rather than the development server.
- Gunicorn runs as a non-root container user.
- PostgreSQL persistence is retained through a Docker volume.
- PostgreSQL startup is guarded by a health check.
- The backend exposes an application health endpoint.
- Inter-container communication uses Docker Compose service DNS.
- The complete browser-to-database request path has been verified.

## Next Milestone

The next progression is to move this production-style local architecture into the delivery layer:

```text
Production containers
        |
        v
Container image tagging
        |
        v
CI/CD pipeline
        |
        v
Container registry
        |
        v
Azure deployment
        |
        v
Secrets + monitoring + networking + IaC
```

The application remains intentionally small; the main portfolio objective is demonstrating the engineering workflow required to transform a development application into a deployable, observable, secure cloud workload.
