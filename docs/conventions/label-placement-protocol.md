# Athanor Cluster: Metadata Placement & Labeling Protocol (v2.1)

## 1. Rationale: The "Metadata Backbone"
In a production-grade GitOps environment, labels are not just "tags"; they are the mechanical joints that connect networking (Cilium), storage (Longhorn), and orchestration (Flux). This protocol ensures that every resource carries the correct identity based on its scope.

## 2. Placement Hierarchy (The Senior Model)
Labels must reside on the object they describe. We use a layered approach to avoid manual repetition (DRY).

| Layer | Defining Manifest | Target Resource | Primary Use Case |
| :--- | :--- | :--- | :--- |
| **Governance** | `infrastructure/<app>.yaml` | `Kustomization` / `Namespace` | Flux tracking, ownership, and cluster-wide auditing. |
| **Identity** | `<app>/base/kustomization.yaml` | `Service`, `Deployment`, `Secret` | Core K8s selectors and tool-agnostic identification. |
| **Functional** | `<app>/base/helm-release.yaml` | **Pods (Endpoints)** | **Cilium NetworkPolicies**, backup triggers, and probe logic. |

---

## 3. Standardized Taxonomy

### 3.1 Orchestration (Governance)
*Applied via Flux `commonMetadata`.*

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `app.kubernetes.io/managed-by` | `flux` | Standard indicator of the controller. |
| `athanor.io/owner` | `aner` | Responsible maintainer. |
| `athanor.io/criticality` | `tier-1` | Incident response priority. |

### 3.2 Application Identity (Recommended K8s)
*Applied via Kustomize `commonLabels`.*

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `app.kubernetes.io/name` | `linkding` | The primary stack identifier. |
| `app.kubernetes.io/part-of` | `athanor-core` | The logical grouping/suite. |
| `app.kubernetes.io/instance` | `linkding-prod` | Unique instance ID (useful for multi-tenancy). |

### 3.3 Security & Functional (Granular)
*Applied via `podLabels` in Helm or `metadata.labels` in raw Pod templates.*

| Key | Example Value | Logic |
| :--- | :--- | :--- |
| **`athanor.io/network-zone`** | `internal` | **Mandatory** for Cilium Policy matching. |
| `app.kubernetes.io/component` | `web` | Distinguishes tiers for policy-level granularity. |
| `athanor.io/backup-policy` | `daily` | Triggers for Longhorn or CNPG snapshotting. |

---

## 4. Implementation Rules

1.  **Cilium Rule:** Any label used in a `matchLabels` block of a `CiliumNetworkPolicy` **must** be defined in the `podLabels` of the `HelmRelease`. Policies target Pods, not Namespaces or Deployments.
2.  **The Standard 6:** We treat the [Kubernetes Recommended Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/) as mandatory.
3.  **No Ghost Labels:** Do not apply labels at the Namespace level if you intend to use them for Pod-to-Pod communication logic. Labels do not "inherit" downward across resource types naturally.
