# RoastCart

RoastCart is a minimal e-commerce web application built as a personal **Cloud & DevOps learning project**.

The application itself is intentionally kept simple so that the main focus can remain on the infrastructure, containerisation, deployment, CI/CD, cloud architecture, monitoring, and operational practices surrounding a modern three-tier web application.

## Project Status

**In Development**

Current focus:

> Completing the fully containerised local application stack before progressing toward cloud deployment and CI/CD automation.

---

The project follows a progressive approach:

**Local development → Containers → Multi-container orchestration → Cloud deployment → CI/CD → Infrastructure automation → Monitoring**

---

## Project Objectives

The main objectives of RoastCart are to:

- Build and operate a simple three-tier web application.
- Apply Docker containerisation to individual application components.
- Understand service-to-service networking using Docker Compose.
- Deploy containerised workloads to Microsoft Azure.
- Implement CI/CD workflows for automated build and deployment.
- Explore Infrastructure as Code and cloud automation.
- Apply monitoring, logging, security, and operational practices.
- Document architectural decisions and learning milestones.

The application domain is intentionally lightweight: a coffee storefront where users can browse coffee products and filter or search the available catalogue.

---

## Architecture

RoastCart currently follows a three-tier architecture:

```text
┌─────────────────────┐
│   React Frontend    │
│       (Vite)        │
└──────────┬──────────┘
           │ HTTP / API
           ▼
┌─────────────────────┐
│    Flask Backend    │
│      REST API       │
└──────────┬──────────┘
           │ SQLAlchemy
           ▼
┌─────────────────────┐
│     PostgreSQL      │
│      Database       │
└─────────────────────┘
```

During local containerised development, Docker Compose manages the application services and provides a shared Docker network for communication between containers.

---

## Technology Stack

| Area | Technology |
|---|---|
| Frontend | React, Vite, JavaScript |
| Backend | Python, Flask |
| API | REST |
| ORM | SQLAlchemy |
| Database | PostgreSQL |
| Containerisation | Docker |
| Local orchestration | Docker Compose |
| Cloud Platform | Microsoft Azure |
| Version Control | Git, GitHub |
| CI/CD | Planned |
| Infrastructure as Code | Planned |
| Monitoring | Planned |

---

## Current Features

The current application supports a minimal coffee product catalogue.

### Product API

The Flask backend provides endpoints for managing coffee products, including:

- Retrieve products
- Create products
- Update products
- Soft-delete products

The data model is intentionally simple so that additional functionality can be introduced later, such as:

- Orders
- Reviews
- Customers
- Inventory
- Authentication

---

## Current Development Progress

### Completed

- React frontend created
- Flask REST API created
- PostgreSQL database integrated
- Product CRUD functionality implemented
- React frontend connected to Flask API
- PostgreSQL containerised
- Flask backend containerised
- Docker Compose configured
- Backend and PostgreSQL communicating through a shared Docker network
- Native React frontend successfully communicating with the containerised backend

### Current Milestone

The project is currently transitioning from a partially containerised architecture to a fully containerised local application.

```text
Current

React (Local)
      │
      ▼
Flask Container
      │
      ▼
PostgreSQL Container
```

The next immediate milestone is:

```text
React Container
      │
      ▼
Flask Container
      │
      ▼
PostgreSQL Container
```

This will allow the full application stack to run through Docker Compose.

---

## Running the Containerised Services

Start the services:

```bash
docker compose up --build
```

View running containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Stop the environment:

```bash
docker compose down
```

Remove containers and associated volumes when a full reset is required:

```bash
docker compose down -v
```

---

## Docker Networking

Docker Compose creates a shared network that allows containers to communicate using their **service names** instead of `localhost`.

For example:

```text
Flask
  │
  │ postgresql://...@postgres-db:5432/...
  ▼
postgres-db
```

Inside a container:
The Flask application connects to PostgreSQL using the database service name defined in `docker-compose.yml`.

This is one of the key learning milestones of the project: moving from host-based application communication to service-based container networking.

---

## Project Structure

The project is organised around independently manageable application components.

```text
RoastCart/
├── frontend/
│   └── React application
│
├── backend/
│   └── Flask REST API
│
├── docs/
│   └── Architecture decisions and project documentation
│
├── docker-compose.yml
├── README.md
└── .env
```

The structure is designed to allow each component to be developed, containerised, deployed, and scaled independently.

---

## Planned Cloud & DevOps Roadmap

The application will progressively move through the following stages:

```text
Application Development
        │
        ▼
Containerisation
        │
        ▼
Docker Compose
        │
        ▼
Azure Container Registry
        │
        ▼
Azure Deployment
        │
        ▼
CI/CD Pipeline
        │
        ▼
Infrastructure as Code
        │
        ▼
Monitoring & Logging
```

Future areas of exploration include:

- Azure-hosted frontend and backend
- Managed PostgreSQL
- Azure Container Registry
- GitHub Actions
- Automated container builds
- Automated deployments
- Terraform
- Application monitoring
- Logging and observability
- Secrets management
- Cloud networking
- Scaling and availability

---

## Learning Focus

RoastCart is primarily an engineering learning project rather than a feature-heavy e-commerce platform.

The focus is on understanding the complete lifecycle of an application:

```text
Code
 ↓
Build
 ↓
Containerise
 ↓
Test
 ↓
Deploy
 ↓
Monitor
 ↓
Improve
```

The project is intended to demonstrate both application-development experience and practical Cloud & DevOps knowledge through an end-to-end implementation.

---

## Author

Personal Cloud & DevOps project developed as part of continued hands-on learning in web development, containerisation, cloud infrastructure, automation, and modern application delivery.
