# RoastCart - CI/CD Artifact Pipeline with Azure Container Registry

## Milestone Summary

RoastCart now has an automated **Continuous Integration (CI) + Continuous Delivery (CD)** artifact pipeline using GitHub Actions and Azure Container Registry (ACR).

This milestone moves RoastCart from manually building production containers on a developer machine to automatically:

1. verifying production Docker builds on Pull Requests into `main`;
2. rebuilding approved production images after changes reach `main`;
3. tagging those images with the exact Git commit SHA; and
4. publishing the immutable images to Azure Container Registry.

> In this milestone, **CD means Continuous Delivery**, not Continuous Deployment. The images are delivered to ACR and are ready for deployment, but they are not yet automatically deployed to a runtime such as Azure Container Apps.

---

## CI vs Continuous Delivery

### Continuous Integration

The CI portion answers:

> Can this code change safely produce valid production container images?

For Pull Requests into `main`:

```text
feature branch
    |
    v
Pull Request -> main
    |
    v
GitHub Actions
    |
    +-- Build backend production image
    `-- Build frontend production image
```

The build runs on a clean GitHub-hosted Ubuntu runner.

No production artifact is published from the feature branch.

### Continuous Delivery

The Continuous Delivery portion answers:

> After a change is accepted into `main`, can I automatically produce a versioned artifact that is ready to deploy?

```text
merge / push -> main
        |
        v
      verify
        |
        v
      publish
        |
        +-- GitHub OIDC authentication
        +-- Azure / ACR authentication
        +-- Build backend image
        +-- Build frontend image
        +-- Tag with Git commit SHA
        `-- Push to ACR
```

Result:

```text
acrroastcart26.azurecr.io/
├── roastcart-backend:<git-sha>
└── roastcart-frontend:<git-sha>
```

This is **Continuous Delivery** because deployable artifacts are automatically produced and stored after approved code reaches `main`.

It is **not yet Continuous Deployment** because nothing automatically rolls those images out to a running Azure environment.

---

## Architecture

```text
Developer
    |
    v
Feature Branch
    |
    v
Pull Request -> main
    |
    v
GitHub Actions
    |
    +-------------------------------+
    | Continuous Integration       |
    | - checkout source             |
    | - build backend image         |
    | - build frontend image        |
    | - fail PR if build fails      |
    +---------------+---------------+
                    |
                 merge
                    |
                    v
                  main
                    |
                    v
GitHub Actions
    |
    +-------------------------------+
    | Continuous Delivery          |
    | - verify again                |
    | - authenticate with OIDC      |
    | - login to ACR                |
    | - build production images     |
    | - tag with github.sha         |
    | - push images to ACR          |
    +---------------+---------------+
                    |
                    v
          Azure Container Registry
                  Basic
                    |
          +---------+---------+
          |                   |
          v                   v
roastcart-backend:<sha>  roastcart-frontend:<sha>
```

---

## What This Milestone Demonstrates

- GitHub Actions workflow triggers
- Pull Request based CI verification
- Separate `verify` and `publish` jobs
- Sequential job dependency using `needs: verify`
- GitHub-hosted clean build runners
- Production Docker image verification
- Continuous Delivery of deployable container artifacts
- GitHub OIDC authentication to Microsoft Entra ID
- Entra application and service principal identity
- Federated credential trust
- Least-privilege Azure RBAC
- `AcrPush` scoped to the registry
- Temporary ACR access tokens
- Docker login to a private container registry
- Git SHA image versioning
- Source-to-artifact traceability
- Azure Container Registry Basic SKU
- Azure Student region-policy awareness

---

## Current GitHub Actions Behaviour

### Pull Request into `main`

```text
pull_request
    |
    v
verify
    |
    +-- backend/Dockerfile.prod
    `-- frontend/Dockerfile.prod
    |
    v
PASS / FAIL
```

`publish` is skipped.

### Push / Merge into `main`

```text
push -> main
    |
    v
verify
    |
    v
publish
    |
    +-- Azure login through OIDC
    +-- temporary ACR token
    +-- Docker login
    +-- backend:<github.sha>
    `-- frontend:<github.sha>
```

---

## Why Git SHA Tags Are Used

Instead of relying only on:

```text
latest
```

RoastCart publishes:

```text
roastcart-backend:<git-sha>
roastcart-frontend:<git-sha>
```

This provides:

- exact source traceability;
- immutable deployment references;
- simpler rollback;
- reproducible release identification.

A normal merge may create a new merge commit on `main`, so the ACR tag can be the `main` merge commit SHA rather than the final feature-branch SHA.

---

## Why PostgreSQL Is Not Built or Published

RoastCart uses the official PostgreSQL image:

```yaml
image: postgres:15-alpine
```

Therefore:

```text
backend   -> custom Dockerfile -> build -> publish to ACR
frontend  -> custom Dockerfile -> build -> publish to ACR
postgres  -> official image    -> pull when needed
```

PostgreSQL can later participate in integration testing or be replaced by Azure Database for PostgreSQL, but RoastCart does not own a PostgreSQL image that needs to be built.

---

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

Compare the `main` source SHA:

```bash
git checkout main
git pull origin main
git rev-parse HEAD
```

---

## Milestone Outcome

RoastCart now has a working **CI/CD artifact pipeline**:

```text
Source
  |
  v
CI verification
  |
  v
Approved main commit
  |
  v
Continuous Delivery
  |
  v
Immutable SHA-tagged container artifacts
  |
  v
Azure Container Registry
```

The application is not yet continuously deployed.

---

## Next Milestone

The next pain point is:

> The production images now exist in ACR, but the Azure infrastructure that will run them still needs to be created reproducibly.

The next recommended milestone is therefore **Infrastructure as Code with Terraform**, followed by deploying the existing SHA-tagged images to a cost-conscious Azure runtime.
