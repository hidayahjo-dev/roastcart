# Branch Milestone

### Database Containerization Milestone

This branch introduces a containerized PostgreSQL database for RoastCart while keeping the React frontend and Flask backend running natively on the host machine for easier development and troubleshooting.
PostgreSQL now runs from the official `postgres:15-alpine` image through Docker Compose. The Compose configuration creates the database service, publishes PostgreSQL on port `5432`, injects database credentials from the root `.env` file, and stores database files in a named Docker volume so data survives container restarts and recreation.
Flask connects from the host machine to the PostgreSQL container through `localhost:5432` using a `DATABASE_URL` loaded from environment variables. SQLAlchemy and Psycopg are used as the application database layer and PostgreSQL driver. The products table has been created and seeded successfully with six coffee products.

### Current development flow

```
React (host)
     │
     ▼
Flask (host)
     │
     │ localhost:5432
     ▼
PostgreSQL (Docker container)
     │
     ▼
Persistent Docker volume
```

This stage keeps application development simple while introducing containerized infrastructure, secret management, persistent storage, and a reproducible database environment before the Flask and React applications are containerized later.
