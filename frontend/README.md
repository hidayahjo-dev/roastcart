# RoastCart - Production Frontend Container Milestone

Branch: `feature/react-prod-container`

## Milestone Summary

This branch productionises the React/Vite frontend container for RoastCart.

Previously, the frontend container ran the Vite development server on port `5173`. That setup was useful for local development because it provided hot reload and fast code validation, but it was not intended to be the final runtime for a production-style deployment.

The frontend now uses a **multi-stage Docker build**:

1. **Build stage - Node + Vite**
   - Installs frontend dependencies with `npm ci`.
   - Runs `npm run build`.
   - Produces optimised static files in `/app/dist`.

2. **Runtime stage - Nginx**
   - Starts from a clean `nginx:alpine` image.
   - Copies only the built `dist` artifacts into Nginx's web root.
   - Serves the frontend on container port `80`.
   - Proxies `/api/*` requests to the Flask backend through the Docker Compose network.

Node, npm and Vite are therefore **build-time dependencies only** and are not required in the final frontend runtime image.

## Updated Frontend Architecture

```text
Browser
   |
   | http://localhost:3000
   v
Nginx frontend container :80
   |
   |-- /, assets, client routes --> static React/Vite build
   |
   `-- /api/* ------------------> roastcart-backend:5000
                                      |
                                      v
                                 Flask API
                                      |
                                      v
                                 postgres-db:5432
```

All three application tiers continue to run on the shared Docker Compose network.

## Key Files

- `frontend/Dockerfile.dev` - local development frontend using the Vite dev server.
- `frontend/Dockerfile.prod` - production multi-stage frontend image.
- `frontend/nginx.conf` - Nginx routing, SPA fallback and reverse-proxy configuration.
- `docker-compose.yml` - orchestrates PostgreSQL, Flask and the production frontend container.

## Production Frontend Build

The production Dockerfile uses two stages:

```text
React source
   |
   v
Node + Vite build stage
   |
   | npm run build
   v
/dist build artifacts
   |
   | COPY --from=build
   v
Nginx runtime image
```

Only the runtime stage becomes the final frontend image.

## Nginx Responsibilities

The custom Nginx configuration `nginx.conf` now acts as the browser-facing entry point for the application.

- Serves compiled HTML, CSS, JavaScript and static assets.
- Uses `index.html` as the fallback for frontend routes.
- Matches `/api/` requests and reverse-proxies them to `roastcart-backend:5000`.
- Preserves common proxy headers for the Flask service.

This allows frontend code to make requests such as:

```javascript
fetch("/api/v1/products");
```

without exposing Docker service names to browser-side JavaScript.

## Docker Compose Change

The frontend Compose service changed from the development image and Vite port:

```yaml
dockerfile: Dockerfile.dev
ports:
  - "5173:5173"
```

to the production image and Nginx port:

```yaml
dockerfile: Dockerfile.prod
ports:
  - "3000:80"
```

The browser now reaches the application at `http://localhost:3000`.

## Verification

Build the services separately:

```bash
docker compose build roastcart-frontend
docker compose build roastcart-backend
```

Start the stack:

```bash
docker compose up
```

Check running services:

```bash
docker compose ps
```

Verify the backend directly:

```bash
curl http://localhost:5000/api/v1/products
```

Verify the same API through the Nginx reverse proxy:

```bash
curl http://localhost:3000/api/v1/products
```

Open the production frontend:

```text
http://localhost:3000
```

### Verified Outcome

- Production frontend image builds successfully.
- Nginx serves the compiled React/Vite frontend.
- Products load correctly in the browser.
- Flask remains reachable directly on port `5000` for development/testing.
- Requests to `localhost:3000/api/...` are successfully proxied by Nginx to Flask.
- Flask continues communicating with PostgreSQL using Docker service discovery.

## Key Learning

This milestone changes the frontend from a **development server container** into a **production-style web container**.

```text
Development: Node + Vite stay running
Production:  Node + Vite build once -> Nginx stays running
```

It also introduces Nginx as a reverse proxy, giving the application a single browser-facing entry point while internal services continue communicating using Docker's private network.
