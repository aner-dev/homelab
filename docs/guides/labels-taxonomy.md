# Athanor Cluster: Label & Metadata Taxonomy (v2.1)

## 1. Identity Layer (Native Kustomize Engine)
*Defined in: `apps/<APP>/base/kustomization.yaml`* *Purpose: Persistent "Who am I?" labels used for core service discovery, tracking, and local workload selectors.*

| Key | Example | Logic |
| :--- | :--- | :--- |
| `app.kubernetes.io/name` | `linkding` | The primary identifier for the application stack. |
| `app.kubernetes.io/component` | `database` | Distinguishes application architectural tiers (`web`, `db`, `redis`). |
| `app.kubernetes.io/part-of` | `athanor-core` | Groups individual applications into larger logical suites. |
| `athanor.io/role` | `app` | Functional system categorization (`gateway`, `app`, `operator`, `exporter`). |

---

## 2. Governance Layer (Flux Kustomization Orchestrator)
*Defined in: `infrastructure/<APP>.yaml` or `apps/<APP>-sync.yaml` (kind: Kustomization)* *Purpose: "Where am I?" parameters applied dynamically at the cluster root level for policy enforcement and multi-tenancy tracking.*

| Key | Example | Logic |
| :--- | :--- | :--- |
| `athanor.io/environment` | `production` | Isolates environments (`production`, `staging`, `lab`). |
| `athanor.io/owner` | `aner` | Engineering accountability attribute. |
| `athanor.io/criticality` | `tier-1` | Controls alert severity escalation pathways and priority routing. |
| `app.kubernetes.io/managed-by` | `flux` | In-cluster identification for the automated pruning engine. |

---

## 3. Functional & Capability Layer (Individual Manifests)
*Defined in: `namespace.yaml`, `database.yaml`, `http-route.yaml`, etc.* *Purpose: Strict operational selectors that trigger eBPF security states, storage hooks, or monitoring engines.*

### A. Networking & Ingress (Cilium & Traefik)
| Key | Example Values | Strategic Purpose |
| :--- | :--- | :--- |
| `athanor.io/network-zone` | `ingress`, `apps`, `observability`, `secure` | Enforces your global zero-trust eBPF perimeter firewalls via Cilium. |
| `athanor.io/gateway-scope` | `public`, `private` | Mediates explicit Gateway API route attachment boundaries inside Traefik. |

### B. Storage & Lifecycle (Longhorn & CNPG)
| Key | Example Values | Strategic Purpose |
| :--- | :--- | :--- |
| `athanor.io/backup-policy` | `daily`, `weekly`, `disabled` | Hooks directly into backup automation storage crons. |

### C. Telemetry & Observability (VictoriaMetrics & Grafana Stack)
| Key | Example Values | Strategic Purpose |
| :--- | :--- | :--- |
| `athanor.io/scrape` | `"true"`, `"false"` | Global target discoverability indicator for `VMAgent`. |
| `athanor.io/scrape-port` | `"9090"` | Overrides target port definitions for non-standard exporters. |
| `athanor.io/telemetry-path` | `"/stats"` | Instructs `VMAgent` to seek alternative endpoint targets. |
| `athanor.io/log-format` | `"json"`, `"text"` | Instructs `Loki` parsing pipelines on processing formats. |
| `athanor.io/log-retention` | `"14d"` | Implements custom TTL overrides for intensive logging endpoints. |
| `grafana_dashboard` | `"1"` | Intercepted by Grafana sidecars to auto-provision JSON configmaps. |

---

# 4. Implementation Examples

## A. Snippet Configuration (Neovim/JSON)
Keep these in your local snippet manager to automate the generation of these patterns flawlessly.

```json
{
  "Flux Kustomization (Orchestrator)": {
    "prefix": "fks",
    "body": [
      "apiVersion: kustomize.toolkit.fluxcd.io/v1",
      "kind: Kustomization",
      "metadata:",
      "  name: ${1:app-name}-sync",
      "  namespace: flux-system",
      "spec:",
      "  targetNamespace: ${2:app-namespace}",
      "  interval: 1h",
      "  retryInterval: 2m",
      "  path: ./apps/${1:app-name}/production",
      "  prune: true",
      "  wait: true",
      "  sourceRef:",
      "    kind: GitRepository",
      "    name: flux-system",
      "  commonMetadata:",
      "    labels:",
      "      athanor.io/environment: ${3|production,staging,lab|}",
      "      athanor.io/owner: aner",
      "      athanor.io/criticality: ${4|tier-1,tier-2,tier-0|}",
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
      "  - namespace.yaml",
      "  - helm-repository.yaml",
      "  - helm-release.yaml",
      "  - ./networking",
      "  - ./security",
      "  - ./storage",
      "  - ./observability",
      "commonLabels:",
      "  app.kubernetes.io/name: ${1:app-name}",
      "  app.kubernetes.io/part-of: athanor-${2:core}",
      "  athanor.io/role: app"
    ],
    "description": "Native Kustomize Engine base configuration for domain-driven app structure"
  }
}
