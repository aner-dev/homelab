# ADR 003: Deprecating Application-Layer mTLS in Favor of Ambient Infrastructure Security

## Status
Accepted

## Context
As the **athanor** cluster evolves toward a production-grade homelab, the locus of control for network security must be strictly defined. The `rustfs` Helm chart and various other ecosystem components provide `mtls` stanzas for application-level certificate management.

The existing deployment of **Cilium** as the CNI and the ongoing implementation of a **Service Mesh** using **SPIRE/SPIFFE** for workload identity provides a more robust alternative. 

Maintaining application-level mTLS introduces the following architectural friction:
1. **Redundancy:** Double-encrypting traffic (App-TLS + Cilium-WireGuard) creates unnecessary CPU overhead on the Ryzen 5 5600GT.
2. **Operational Complexity:** Managing `.pem` files via `existingIssuerRef` or sidecars within every HelmRelease is error-prone and leads to "Zombie Certificates."
3. **Identity Proliferation:** Managing separate identities in `cert-manager` for internal traffic and SPIRE for workload identity violates the "Single Source of Truth" principle.

## Decision
All present and future configurations of application-layer mTLS within individual service manifests (HelmReleases) are to be **aborted and eliminated**.

1. All `mtls.enabled` fields in Helm charts shall be set to `false`.
2. Mutual authentication and encryption-in-transit will be handled exclusively by the **Cilium Service Mesh**.
3. Workload identity will be managed via **SPIRE/SPIFFE**, enabling "Ambient Security" where the application remains unaware of the underlying encryption logic.

## Rationales

| Principle | Senior Justification |
| :--- | :--- |
| **Separation of Concerns** | The **Application Developer** persona focuses on business logic (storage); the **Infrastructure Provider** persona (Cilium) manages secure transport. |
| **Kernel Performance** | Cilium leverages BPF and kernel-space encryption (WireGuard/IPsec), which is significantly more efficient than user-space TLS handshakes inside a Go/Rust binary. |
| **Identity Lifecycle** | SPIRE provides short-lived, automatically rotated SVIDs, eliminating the risk of downtime due to expired manual certificates. |

## Consequences

### Positive
* **Cleaner Manifests:** HelmReleases are no longer cluttered with certificate paths and issuer references.
* **Centralized Policy:** Security posture is audited via `CiliumNetworkPolicy` rather than hunting through dozens of `values.yaml` files.
* **Developer Velocity:** New services can be deployed without the immediate requirement of configuring TLS secrets.

### Negative / Risks
* **Blind Spot:** The application binary itself communicates in plain text to the local Cilium proxy; security depends entirely on the integrity of the CNI.
* **Migration Effort:** Existing services must have their `mtls` blocks deactivated and tested for connectivity via Cilium.
