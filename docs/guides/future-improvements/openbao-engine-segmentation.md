# OpenBao Secret Engine Segmentation Strategy

## 1. Current State (Homelab Context)
Currently, the cluster utilizes a single Key-Value (KV) V2 secret engine mounted at the default path: `secret/`. 

- **Mechanism:** A global `ClusterSecretStore` is "pinned" to this mount point.
- **Consumption:** All `ExternalSecret` resources must use this prefix (e.g., `secret/data/cert-manager/desec`).
- **Hardware Context:** Running on a single Ryzen 5 5600GT node with NVMe storage. High performance is available, but logical isolation is currently "flat."

## 2. The Production "Senior" Reasoning
In a high-compliance or multi-team production environment, using a single `secret/` mount is considered a "Security Smell." 

### Blast Radius Reduction
If the `external-secrets` ServiceAccount is compromised and has a policy allowing `path "secret/*"`, the attacker can see everything from infrastructure tokens to application database passwords.

### Multi-Tenancy
In professional environments, different "Engines" are mounted for different security tiers:
- `infra/`: For cert-manager, cilium, and system-level secrets.
- `apps/`: For user-facing applications (Forgejo, Gitea).
- `production/`: For highly sensitive production-only data.

## 3. Proposed Improvement: Segmented Mount Points

Instead of one global store, the architecture should move toward **Scoped SecretStores**.

### Evolution Steps:
1. **Engine Re-mounting:** Move infrastructure secrets to an `infra/` mount point in OpenBao.
2. **Policy Tightening:** Update the OpenBao policies so that the `cert-manager` ServiceAccount can *only* see `infra/data/cert-manager/*`.
3. **Specific SecretStores:** Create a `SecretStore` (namespaced) for `cert-manager` that points specifically to the `infra/` engine.

| Attribute | Flat (Current) | Segmented (Target) |
| :--- | :--- | :--- |
| **Complexity** | Low | Medium |
| **Security** | Minimal (Logical only) | High (Engine-level isolation) |
| **Scalability** | Becomes messy over time | Clean, role-based separation |

## 4. Implementation Reference
When implementing, the `ClusterSecretStore` or `SecretStore` must update the `path` field:

```yaml
spec:
  provider:
    vault:
      path: "infra" # Instead of "secret"
      version: "v2"
```

