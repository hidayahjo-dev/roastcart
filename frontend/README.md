# feature/react-container - Learning Summary

## Milestone achieved

Containerised the React/Vite frontend and completed local Docker Compose orchestration for the full RoastCart 3-tier application:

- React + Vite frontend container
- Flask backend container
- PostgreSQL database container
- All services connected through the Docker Compose default network
- Browser accesses the frontend through `localhost:5173`
- Vite proxies `/api` requests to the Flask service using Docker DNS
- Flask connects to PostgreSQL using the Compose database service name

## Architecture before

```text
Browser
  |
  v
React/Vite (native on host)
  |
  | localhost:5000
  v
Flask container
  |
  | postgres-db:5432
  v
PostgreSQL container
```

## Architecture after

```text
Browser
  |
  | http://localhost:5173
  v
React/Vite container
  |
  | /api -> http://roastcart-backend:5000
  | Docker Compose network
  v
Flask container
  |
  | postgresql://postgres-db:5432
  | Docker Compose network
  v
PostgreSQL container
```

## Key implementation changes

### Frontend Dockerfile

The frontend now has its own build definition:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

Important points:

- `node:20-alpine` provides the Node.js runtime.
- `WORKDIR /app` provides a predictable working directory.
- Dependency files are copied before source code to improve Docker layer caching.
- `npm ci` installs dependencies deterministically from `package-lock.json`.
- Vite must listen on `0.0.0.0` so the development server is reachable through Docker port mapping.

### Frontend `.dockerignore`

```text
node_modules
dist
.git
.gitignore
Dockerfile
npm-debug.log
```

The host `node_modules` should not be copied into the Linux container. Dependencies are installed inside the image by `npm ci`.

### Vite proxy configuration

The browser continues using relative application routes such as:

```js
fetch("/api/v1/products");
```

Vite proxies `/api` requests internally to the backend Compose service:

```js
server: {
  host: "0.0.0.0",
  proxy: {
    "/api": {
      target: "http://roastcart-backend:5000",
      changeOrigin: true,
    },
  },
}
```

`roastcart-backend` is resolvable only inside the Docker network. The browser itself does not resolve this hostname.

## Docker Compose standardisation

Each custom application now uses its own build context:

```text
Backend                            Frontend

context: ./backend                 context: ./frontend
        |                                  |
WORKDIR /app                       WORKDIR /app
        |                                  |
COPY dependency file               COPY dependency file
        |                                  |
install dependencies               install dependencies
        |                                  |
COPY . .                           COPY . .
        |                                  |
python run.py                      npm run dev
```

This keeps each image build scoped to its own application files and makes `.dockerignore` behavior easier to reason about.

## Docker networking learned

Docker Compose creates a shared default network for the services. Service keys act as internal DNS hostnames:

```text
roastcart-frontend
      |
      | http://roastcart-backend:5000
      v
roastcart-backend
      |
      | postgresql://postgres-db:5432
      v
postgres-db
```

Host port mappings are mainly for access from the local machine:

```text
localhost:5173 -> frontend:5173
localhost:5000 -> backend:5000
localhost:5432 -> postgres-db:5432
```

Container-to-container traffic should use service names and container ports rather than `localhost`.

## Commands used

Build and run the complete stack from the repository root:

```bash
docker compose up --build
```

Run in detached mode after verification:

```bash
docker compose up --build -d
```

Check service state:

```bash
docker compose ps
```

Check logs:

```bash
docker compose logs roastcart-frontend
docker compose logs roastcart-backend
docker compose logs postgres-db
```

Verify backend directly:

```bash
curl http://localhost:5000/api/v1/products
```

Verify complete browser flow:

```text
http://localhost:5173
```

Stop the stack:

```bash
docker compose down
```

## Outcome

RoastCart has progressed from partial containerisation to a fully containerised local platform. The presentation, application and database tiers can now be built and started together using a single Docker Compose command, creating a repeatable local environment that is ready for later production-image, CI/CD and cloud-deployment stages.
