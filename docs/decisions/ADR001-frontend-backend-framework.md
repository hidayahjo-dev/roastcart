## Context

RoastCart requires a storefront and an API, but frontend development should not dominate the project.

## Decision

Use:

React/Vite for the storefront
Flask for the REST API
A monorepo containing separate frontend and backend directories

## Alternatives
Entire application built with Flask templates
Next.js full-stack application
Django
Separate repositories

## Why

This reduces product-development time while preserving a realistic separation between frontend and backend deployments.