# ADR 003: Standardized Naming and Scoping for ExternalSecrets

## Status
Proposed (2026-04-30)

## Context
As the number of applications in the **athanor** cluster increases, maintaining consistency in secret management is vital for observability, automated remediation, and developer cognitive load. I need a predictable pattern for naming and locating `ExternalSecret` resources that pull from OpenBao.

I weighed the following options for naming:
1. **Functional Granularity:** Naming by specific use (e.g., `rustfs-s3-creds`).
2. **Predictable Uniformity:** Naming after the application (e.g., `rustfs-secrets`).

I weighed the following options for scoping:
1. **Centralized Namespace:** Placing all `ExternalSecrets` in a dedicated `external-secrets` namespace.
2. **Distributed App-Namespace Scoping:** Placing the `ExternalSecret` within the same namespace as the workload.

## Decision
I will adopt **Predictable Uniformity** for naming and **App-Namespace Scoping** for resource location.

### Implementation Rules:
*   **Naming (Singleton Pattern):** If an application has a single logical set of credentials, the manifest `metadata.name` and the target K8s secret MUST be named `<app>-secrets`.
*   **Naming (Hybrid Exception):** If an application requires multiple secret sources with distinct security postures (e.g., different `SecretStores`), the convention will evolve to `<app>-<backend>-secrets`.
*   **Namespace Scoping:** `ExternalSecret` resources MUST reside in the same namespace as the application they serve to maintain strict RBAC boundaries and functional encapsulation.

## Consequences
*   **Positive:** Simplified `HelmRelease` configurations and predictable cross-referencing.
*   **Positive:** Enhanced Security Posture; secrets are isolated by namespace, reducing the blast radius of a potential breach.
*   **Positive:** Faster navigation and refactoring within Neovim using fuzzy finders.
*   **Neutral:** Requires internal keys (e.g., `S3_KEY`) to be the primary method of distinguishing credential types within the single secret object.
*   **Negative:** Increased initial manifest count across namespaces compared to a single centralized list.

## References
*   [YAGNI Principle](https://en.wikipedia.org/wiki/You_ain't_gonna_need_it)
*   Athanor Security Pillar: ESO Integration
