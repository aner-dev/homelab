# ADR 006: Hybrid Secret Management Approach

## Status
Proposed / Accepted

## Context
We need a way to manage secrets for both human users (passwords, MFA) and machine identities (Kubernetes workloads, External Secrets Operator). 
Initial research suggested using Vaultwarden for everything, but technical constraints emerged regarding API compatibility with production-grade tools.

## Decision
We will implement a **Hybrid Model**:
1. **Vaultwarden** will be used for personal/human secret storage.
2. **HashiCorp Vault** will be deployed in-cluster as the "Source of Truth" for all Kubernetes machine secrets.

## Rationale
- **Protocol Standard:** HashiCorp Vault is the industry standard API for Secret Management. Learning it provides direct "Production Knowledge" transferable to EKS/GKE environments.
- **Integration:** The External Secrets Operator (ESO) has native, robust support for the Vault API without requiring sidecars or third-party bridges.
- **Security Isolation:** Separating human passwords from infrastructure secrets limits the "Blast Radius" if one service is compromised.
- **Learning Path:** Implementing HashiCorp Vault involves managing StatefulSets and the Unseal process, which are critical DevOps skills.

## Consequences
- **Positive:** Standardized workflow for all future apps (Linkding, Grafana, Quartz).
- **Negative:** Higher resource usage in the homelab (two secret managers instead of one).
- **Management:** Requires manual "Unsealing" of the Vault pod upon cluster restart.
