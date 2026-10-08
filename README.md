# RoastCart - CI + Azure Container Registry Milestone

## Milestone Summary

RoastCart now has an automated Continuous Integration (CI) workflow that validates production container builds before changes reach `main`, then publishes immutable, traceable container images to Azure Container Registry (ACR) after a successful merge.

This milestone moves RoastCart from **manual local Docker builds** to a **repeatable cloud artifact pipeline**.

## Architecture

```text
Feature Branch
    |
    v
Pull Request -> main
    |
    v
GitHub Actions
    |
    +-- Verify backend production image
    +-- Verify frontend production image
    |
    v
Merge to main
    |
    v
GitHub Actions
    |
    +-- Verify again
    +-- Authenticate to Azure with OIDC
    +-- Authenticate Docker to ACR
    +-- Build production images
    +-- Tag images with Git commit SHA
    +-- Push images to ACR
              |
              v
     acrroastcart26.azurecr.io
       |-- roastcart-backend:<git-sha>
       `-- roastcart-frontend:<git-sha>
```

## What This Milestone Demonstrates

- GitHub Actions CI triggered by Pull Requests into `main`
- Production Docker image verification on clean GitHub-hosted runners
- Separate verification and publishing jobs
- Job dependency using `needs: verify`
- Publishing restricted to `push` events on `main`
- Passwordless GitHub-to-Azure authentication using OpenID Connect (OIDC)
- Microsoft Entra application and service principal identity
- Least-privilege `AcrPush` authorization scoped to ACR
- Temporary ACR access-token authentication
- Immutable container image tagging using `${{ github.sha }}`
- Container image storage in Azure Container Registry Basic SKU
- Source-to-artifact traceability

## CI Behaviour

### Pull Request into `main`

```text
feature branch
    |
    v
Pull Request
    |
    v
Verify Production Builds
    |-- backend/Dockerfile.prod
    `-- frontend/Dockerfile.prod
```

The PR verifies that both production images can be built successfully. Images are not published from a feature branch.

### Merge / Push to `main`

```text
main updated
    |
    v
verify
    |
    v
publish
    |
    +-- Azure OIDC login
    +-- ACR login
    +-- backend image:<git-sha>
    `-- frontend image:<git-sha>
```

Only `main` creates persistent release artifacts.

## Why PostgreSQL Is Not Built in CI

The RoastCart PostgreSQL service uses the official pre-built image:

```yaml
image: postgres:15-alpine
```

RoastCart owns and builds only:

- `backend/Dockerfile.prod`
- `frontend/Dockerfile.prod`

PostgreSQL can later be pulled and started during integration testing, but it does not require a custom `docker build` step.

## ACR

Registry:

```text
<ACR_NAME>.azurecr.io
```

SKU:

```text
Basic
```

Region:

```text
Malaysia West
```

Repositories:

```text
roastcart-backend
roastcart-frontend
```

Images are tagged with the full Git commit SHA rather than only `latest`.

Example:

```text
<ACR_NAME>.azurecr.io/roastcart-backend:<git-sha>
<ACR_NAME>.azurecr.io/roastcart-frontend:<git-sha>
```

## Verification Commands

List repositories:

```bash
az acr repository list \
  --name <ACR_NAME> \
  --output table
```

Show backend tags:

```bash
az acr repository show-tags \
  --name <ACR_NAME> \
  --repository roastcart-backend \
  --output table
```

Show frontend tags:

```bash
az acr repository show-tags \
  --name <ACR_NAME> \
  --repository roastcart-frontend \
  --output table
```

Compare the current local `main` SHA:

```bash
git checkout main
git pull origin main
git rev-parse HEAD
```

The resulting SHA should match the ACR image tag created by the corresponding GitHub Actions run.

## Key Learning Outcome

The workflow evolved from:

```text
docker build -t ...
docker images
```

performed manually on a developer machine, into:

```text
Pull Request -> automated verification -> merge -> reproducible build -> immutable artifact -> ACR
```

This establishes the artifact pipeline that future RoastCart deployment stages can consume without rebuilding source code on the destination platform.

## Next Milestone

Provision RoastCart cloud infrastructure as code and deploy the SHA-tagged ACR images to Azure, while keeping Azure Student subscription cost and regional policy constraints in mind.
