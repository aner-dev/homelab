# ADR 001: Repository Structure and GitOps Strategy

## Status
**Proposed** (2026-01-26)

## Context
I am building a Kubernetes-based homelab to learn cloud-native production environments. I need a way to organize manifests for both infrastructure (databases, networking, operators) and applications (e.g., Linkding) that scales as the lab grows while remaining manageable for a single operator.

## Decision
I have chosen a **Monorepo** architecture using **FluxCD** and **Kustomize**. 

The directory structure will follow this hierarchy:
* `clusters/`: Entry points for Flux, mapped to specific physical environments.
* `infrastructure/`: Shared controllers and platform tools (CNPG, MinIO, etc.).
* `apps/`: User-facing applications.
* `base/` vs `production/`: Using Kustomize overlays to separate the core application definitions from environment-specific configurations.



## Consequences

### Pros:
* **Single source of truth:** The entire lab state is captured in one repository.
* **Simplified Management:** Easier secret management and cross-resource referencing.
* **Atomic commits:** Allows updating a database and its dependent application in a single push, ensuring consistency.

### Cons:
* **Repo Size:** The repository could become large over time.
* **Complexity:** Requires strict organizational discipline to avoid "spaghetti" YAML and maintain clarity.
