# Architectural Decision Record (ADR): Observability Strategy

## Context
A centralized `VMServiceScrape` template (`athanor-autoscrape`) was initially considered to provide cluster-wide monitoring by targeting services with a specific label (`athanor.io/scrape: "true"`). This was intended to reduce boilerplate and standardize scrape configurations across the Athanor cluster.

## Decision
The centralized "autoscrape" manifest is decommissioned. The cluster transitions to a **distributed monitoring model** where each application carries its own `VMServiceScrape` configuration within its local directory structure (e.g., `apps/<app>/base/observability/scrape.yaml`). 

Bespoke or inconsistent collector naming schemas (`metrics-agent`, `athanor-agent`) are abandoned in favor of a unified, intent-based component identity.

## Rationale

### 1. Application Self-Containment
Distributed configurations ensure that an application is a complete, portable unit. The lifecycle of the monitoring logic is now tied directly to the application. Deleting the application directory automatically removes its associated monitoring resources, preventing "stale" targets in the observability stack.

### 2. Granularity and Specialization
Scraping requirements vary significantly between services. A centralized template enforces a "lowest common denominator" approach (fixed intervals, specific port names, fixed paths). Distributed configurations allow for application-specific parameters, such as:
* Custom scrape intervals (e.g., 10s for high-resolution metrics vs. 60s for background tasks).
* Unique metric paths (e.g., `/metrics` vs. `/prometheus`).
* Specific port identification without enforcing a cluster-wide naming convention.

### 3. Reduced Blast Radius
Errors in a centralized manifest can disrupt monitoring for the entire cluster. By isolating scrape logic to individual application folders, a configuration error only impacts the specific service being modified, increasing overall cluster stability.

### 4. GitOps Compliance
This model follows GitOps best practices by maintaining a clear 1:1 relationship between the service deployment and its operational metadata. It avoids "Namespace Boundary Violations" by keeping resources within their respective namespaces or clearly linked via local Kustomizations. Cross-namespace target discovery is safely handled by the `vmagent` controller's RBAC `ClusterRoleBinding`, eliminating the necessity to create standalone `ReferenceGrant` objects for ingestion.

## Implementation Notes
* Remove `infrastructure/observability/athanor-autoscrape.yaml`.
* Update `infrastructure/observability/kustomization.yaml` to reflect the removal.
* Ensure each application in `apps/` includes a `VMServiceScrape` manifest if metrics are required.
* **Ingestion Filter Constraint:** Every distributed `VMServiceScrape` or `VMPodScrape` resource must include the mandatory tracking selector label: `metrics.athanor.local/agent: vmagent`.
