# ADR 001: Transition of FluxCD Decryption Engine from GPG to Age

* **Status**: Accepted
* **Date**: 2026-04-28
* **Cluster**: `athanor`
* **Author**: Aner

## Context
Our current GitOps workflow uses **SOPS** to encrypt Kubernetes secrets in the `athanor` repository. Historically, this has been managed using **GPG (GNU Privacy Guard)** as the cryptographic backend. While functional, GPG introduces significant administrative overhead (keyrings, trust management, and long-form keys) that complicates the automation required for a modern FluxCD-driven homelab.

We are currently managing:
1. **Personal GPG Key**: Used for Identity (Git Commit Signing).
2. **Flux GPG Key**: Used as a 'Decryption Engine' (Service Key) for cluster-side secrets.

## Decision
We will migrate the SOPS decryption engine from **GPG** to **Age** (Specifically using the Rust implementation, `rage`). 

* We will decommission the `flux-operator-athanor` GPG key.
* We will implement a dedicated **Age Service Key** (`flux-operator-athanor`) for cluster-side decryption.
* We will retain the **Personal GPG Key** exclusively for **Commit Signing** to maintain a verified identity on Codeberg/GitHub.

## Rationale: The "Service Key" & "Engine" Paradigm

### 1. Distinction between Identity and Mechanism
We recognize that the "Service Key" is the **Identity** (the "Who") and the decryption provider is the **Engine** (the "How"). 
- **The Identity**: `flux-operator-athanor`.
- **The Engine**: Age.

By switching the engine to Age, we achieve a more lightweight and performant "Mechanism" while maintaining the "Service Key" role.

### 2. Elimination of Redundancy
Maintaining both GPG and Age for the same functional purpose (decryption) creates an "Architectural Paradox" and increases the attack surface. Removing the Flux GPG key ensures a **Comprehensive** audit trail by narrowing down the tools required to manage the cluster's lifecycle.

### 3. Operational Efficiency
Age keys are small, easy to manage as text strings, and highly compatible with Artix/OpenRC environments where simplicity and speed are prioritized.

## Implementation Details

### Per-Domain Configuration
To prevent "Configuration Bloat," we will deploy `.sops.yaml` files granularly at the domain level:
- `infrastructure/configs/network/.sops.yaml`
- `infrastructure/configs/observability/.sops.yaml`
- `infrastructure/configs/storage/.sops.yaml`

These will all leverage the **Age Engine** while targeting the same unified `flux-operator-athanor` public key.

## Consequences
- **Positive**: Simplified key management; faster reconciliation times; reduced configuration drift.
- **Negative**: Existing GPG-encrypted secrets must be re-encrypted using the Age public key.
- **Neutral**: The Flux `Kustomization` must be updated to reference a `sops-age` secret rather than `sops-gpg`.

---

## Technical Appendix: The Decryption Pipeline

| Phase | Responsibility | Tool |
| :--- | :--- | :--- |
| **Transport** | Fetching code from Codeberg | SSH Key |
| **Identity** | Proving authorship of changes | Personal GPG Key |
| **Engine** | Unlocking secret payloads | Age (Rage) |
| **Orchestration** | Managing the reconciliation | FluxCD |

