# Athanor Cluster: Label & Metadata Taxonomy (v2.0)

## 1. Identity Layer (Native Kustomize)
*Defined in: `<APP>/base/kustomization.yaml`*
*Purpose: Persistent "Who am I?" labels used for Selectors and Services.*

| Key | Example | Logic |
| :--- | :--- | :--- |
| `app.kubernetes.io/name` | `linkding` | The primary identifier for the stack. |
| `app.kubernetes.io/component` | `database` | Distinguishes tiers (web, db, redis). |
| `app.kubernetes.io/part-of` | `athanor-core` | Groups apps into larger functional suites. |

---

## 2. Governance Layer (Flux Kustomization API)
*Defined in: `infrastructure/<APP>.yaml` (kind: Kustomization)*
*Purpose: "Where am I?" labels applied at the cluster level for all app resources.*

| Key | Example | Logic |
| :--- | :--- | :--- |
| `athanor.io/environment` | `production` | Separates prod/staging logic. |
| `athanor.io/owner` | `aner` | Identifies the person/team responsible. |
| `athanor.io/criticality` | `tier-1` | Used for alert routing and priority. |
| `app.kubernetes.io/managed-by` | `flux` | Global indicator of the GitOps controller. |

---

## 3. Functional/Granular Layer (Individual Manifests)
*Defined in: `database.yaml`, `ingress.yaml`, etc.*
*Purpose: Specific triggers for Cilium, Longhorn, or external controllers.*

| Key | Example | Logic |
| :--- | :--- | :--- |
| `athanor.io/network-zone` | `internal` | Used by Cilium Network Policies. |
| `athanor.io/backup-policy` | `daily` | Triggers Longhorn/CNPG backup schedules. |
|**`athanor.io/scrape`**|`true`|**Metrics:** Global trigger for `VMAgent` scrape.|
|**`athanor.io/log-format`**|`json`|**Logs:** Instruction for `Loki` parsing.|
|**`grafana_dashboard`**|`1`|**Dashboards:** Sidecar trigger for JSON import.|
|**`athanor.io/scrape-port`**|`9090`|**Metrics:** Tells VM exactly which port to hit if it's non-standard.|
|**`athanor.io/telemetry-path`**|`/metrics`|**Metrics:** If an app uses a non-standard path (like `/stats`).|
|**`athanor.io/network-zone`**|`observability`|**Networking:** Identifies monitoring components in Cilium.|

# 4. Implementation Examples
## A. Snippet Configuration (Neovim/JSON)
- Use these snippets to automate the "Identity vs. Governance" split.
  - Notice how the Identity labels are baked into the Kustomize Native engine, while Governance is enforced by the Flux Orchestrator.

```JSON
{
  "Flux Kustomization (Orchestrator)": {
    "prefix": "fks",
    "body": [
      "apiVersion: kustomize.toolkit.fluxcd.io/v1",
      "kind: Kustomization",
      "metadata:",
      "  name: ${1:app-name}",
      "  namespace: flux-system",
      "spec:",
      "  targetNamespace: ${2:app-namespace}",
      "  interval: 1h",
      "  retryInterval: 2m",
      "  path: ${3:./apps/app-name/production}",
      "  prune: true",
      "  wait: true",
      "  sourceRef:",
      "    kind: GitRepository",
      "    name: flux-system",
      "  commonMetadata:",
      "    labels:",
      "      athanor.io/environment: ${4|production,staging,lab|}",
      "      athanor.io/owner: aner",
      "      athanor.io/criticality: ${5|tier-1,tier-2,tier-0|}",
      "      app.kubernetes.io/managed-by: flux"
    ],
    "description": "FluxCD Kustomization for Cluster Governance"
  },
  "Kustomize Native (Engine)": {
    "prefix": "kust",
    "body": [
      "apiVersion: kustomize.config.k8s.io/v1beta1",
      "kind: Kustomization",
      "resources:",
      "  - ${1:base.yaml}",
      "commonLabels:",
      "  app.kubernetes.io/name: ${2:app-name}",
      "  app.kubernetes.io/part-of: athanor-core"
    ],
    "description": "Native Kustomize for Application Identity"
  }
}
```
## B. Case Study: Linkding Deployment (YAML)
This example demonstrates the Hybrid Metadata Approach in action for the Linkding stack.

```yaml
# 1. ORCHESTRATOR: infrastructure/linkding.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: linkding
  namespace: flux-system
spec:
  path: "./apps/linkding/production"
  targetNamespace: linkding
  commonMetadata:
    labels:
      athanor.io/environment: production   # Governance
      athanor.io/owner: aner               # Governance
      athanor.io/criticality: tier-1       # Governance
      app.kubernetes.io/managed-by: flux   # Governance

---
# 2. ENGINE: apps/linkding/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - database.yaml
  - helm-release.yaml
commonLabels:
  app.kubernetes.io/name: linkding         # Identity
  app.kubernetes.io/part-of: athanor-core  # Identity

---
# 3. GRANULAR: apps/linkding/base/database.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: linkding-db
spec:
  inheritedMetadata:
    labels:
      app.kubernetes.io/component: database # Specific Component
      athanor.io/network-zone: internal     # Functional (Cilium)
      athanor.io/backup-policy: daily       # Functional (CNPG)
```

# observability layer labels 
|**Key**|**Example**|**Logic**|
|---|---|---|
|`athanor.io/log-retention`|`14d`|**Logs:** Overrides default TTL for specific high-volume apps.|
|`grafana_dashboard`|`1`|**Dashboards:** Sidecar trigger to import JSON from ConfigMaps.|

