# Athanor Cluster: Label & Metadata Taxonomy

This document serves as the **Source of Truth** for all metadata applied across the `athanor` cluster.
All manifests MUST adhere to these conventions to ensure consistent networking (Cilium), storage (Longhorn), and GitOps (FluxCD) behavior.

## 1. Standard Kubernetes Labels (Identity)
These MUST be applied to every `Deployment`, `StatefulSet`, and `Service`. 
Reference: [Kubernetes Common Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)

| Key | Purpose | Example |
| :--- | :--- | :--- |
| `app.kubernetes.io/name` | The name of the application. | `linkding` |
| `app.kubernetes.io/instance` | Unique name for the specific deploy. | `linkding-db` |
| `app.kubernetes.io/part-of` | The high-level project/suite. | `athanor-core` |
| `app.kubernetes.io/component` | The tier within the app. | `database` |
| `app.kubernetes.io/managed-by` | The controller (usually Flux). | `flux` |

---

## 2. Infrastructure & Automation (Functional)
These labels trigger specific cluster behaviors. **Warning:** Modifying these may change traffic flow or backup status.

### A. Networking (Cilium)
| Key | Value | Logic |
| :--- | :--- | :--- |
| `io.cilium/l2-announced` | `"true"` | Triggers L2 Announcement for LoadBalancer IPs. |
| `athanor.io/network-zone` | `dmz`, `internal`, `trusted` | Used by `CiliumClusterwideNetworkPolicy` to filter traffic. |

### B. Storage & Backups (Longhorn / CNPG)
| Key | Value | Logic |
| :--- | :--- | :--- |
| `athanor.io/backup-policy` | `daily`, `weekly`, `disabled` | Determines retention in Longhorn/CNPG schedules. |
| `athanor.io/storage-tier` | `nvme`, `hdd` | (Future) To be used with Node Affinity for PV placement. |

---

## 3. Governance & Metadata (Informational)
Used for filtering with `kubectl`, `rg`, or `television`.

| Key | Description |
| :--- | :--- |
| `athanor.io/owner` | The person/team responsible for the service. |
| `athanor.io/environment` | `production`, `staging`, `lab`. |
| `athanor.io/criticality` | `tier-0` (Core), `tier-1` (User apps), `tier-2` (Testing). |

---

## 4. Selection Best Practices (The "Selector" Rule)
> **CRITICAL:** `matchLabels` used in `Services` or `NetworkPolicies` should rely on **Identity** labels (`app.kubernetes.io/name`) to ensure stability. Never use informational labels for selectors.
