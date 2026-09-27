# Branch Milestone

### Flask Containerization Milestone

Progress RoastCart from a partially containerised local application to a multi-container setup:

#### Before

```
React (native) -> Flask (native) -> PostgreSQL (container)
```

#### After

```
React (native) -> Flask (container) -> PostgreSQL (container)
```

The goal of this branch was to build a custom Docker image for the Flask backend, run Flask and PostgreSQL as separate containers under Docker Compose, and verify that the existing React frontend could still retrieve product data successfully.

#### What Changed

- Added a custom backend/Dockerfile for the Flask application.
- Extended `docker-compose.yml` with a roastcart-backend service.
- Kept PostgreSQL on the official `postgres:15-alpine` image.
- Used Docker Compose to create and coordinate the Flask and PostgreSQL containers.
- Used the Compose service name postgres-db as the database hostname inside the Docker network.
- Configured SQLAlchemy to use the installed Psycopg 3 driver with:
  postgresql+psycopg://...
- Exposed Flask from container port 5000 to host port 5000.
- Kept the PostgreSQL named volume so database data survives container recreation.
- Verified the Flask API with curl.
- Verified the existing React/Vite frontend still retrieves database-backed products.

### Verification Result

```
React (npm run dev)
        |
        | HTTP
        v
Flask container :5000
        |
        | Docker internal DNS
        | postgres-db:5432
        v
PostgreSQL container
        |
        v
Persistent named volume
```

#### Verified outcomes:

- Flask container builds successfully.
- Flask container remains in the Up state.
- Flask resolves and connects to postgres-db.
- curl `http://localhost:5000/api/v1/product` returns product data.
- React retrieves and displays those products through the containerised Flask backend.

### Key Learning

This branch moves RoastCart from "using a database container" to operating a small multi-container application. The backend and database are independently packaged services, but Docker Compose gives them a shared network, service discovery, environment configuration, port publishing, persistence, startup coordination, and a single command to run the local stack.
