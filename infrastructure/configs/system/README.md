# ⚖️ Cluster Scheduling: Pod Priority & Preemption Hierarchy

This directory houses the global scheduling topology for the **Athanor Cluster**. By establishing explicit weight definitions, I ensure that the Kubernetes scheduling engine (`kube-scheduler`) handles resource starvation predictably, safeguarding critical system controllers while managing volatile workloads gracefully.

---

## 🗺️ Architectural Topology Overview

The cluster utilizes a **Bucket Topology Pattern** to categorize workloads into four distinct operational tiers. Preemption loops run continuously in the background to enforce these boundaries during hardware constraints.

| Priority Class Name | Numeric Weight | Preemption Policy | Structural Scope & Evolutionary Intent |
| :--- | :--- | :--- | :--- |
| **`platform-critical`** | `1000000000` | `PreemptLowerPriority` | **Core Platform Foundation.** Core engines required to maintain cluster runtime stability, networking matrices, and GitOps state syncs. |
| **`tenant-stateful`** | `50000000` | `PreemptLowerPriority` | **Data Persistent Cores.** Essential business-logic workloads that house physical data engines, stateful graphs, or source code repositories. |
| **`tenant-stateless`** | `10000000` | `PreemptLowerPriority` | **Standard Business Logic.** Default applications providing user utility. These are completely resilient to rolling restarts or re-scheduling. |
| **`tenant-ephemeral`** | `1000000` | `Never` | **Volatile / Analytical workloads.** Non-essential applications that are completely decoupled from core operations. They wait patiently in the queue if RAM is low. |

---

## 📋 Component Attachment Tracking Matrix

Use this matrix to track which infrastructure controllers and tenant business workloads have been bound to each scheduling tier via their `priorityClassName` attribute.

| Target Priority Class | Attached Component / Controller | Workload Type | Manifest Mapping Location |
| :--- | :--- | :--- | :--- |
| `platform-critical` | `cilium-agent` & `cilium-operator` | DaemonSet / Deployment | `infrastructure/controllers/cilium/staging/values.yaml` |
| `platform-critical` | `local-path-provisioner` | Deployment | `infrastructure/controllers/local-path/base/configmap.yaml` |
| `platform-critical` | `flux-system` | Deployment | `clusters/athanor/flux-system/gotk-components.yaml` |
| `platform-critical` | `longhorn-manager` | DaemonSet | `infrastructure/controllers/longhorn/base/helm-release.yaml` |
| `platform-critical` | `velero` | Deployment | `infrastructure/controllers/velero/velero-values.yaml` |
| `tenant-stateful` | `cloudnative-pg` (PostgreSQL) | Custom Resource (Cluster) | *Pending Deployment Configuration* |
| `tenant-stateful` | `forgejo` (Git Forge Core) | StatefulSet | *Pending Deployment Configuration* |
| `tenant-stateful` | `victoriametrics` (TSDB Engine) | Custom Resource / VMDS | `infrastructure/controllers/victoriametrics/values.yaml` |
| `tenant-stateless` | `linkding` | Deployment | `apps/linkding/base/deployment.yaml` |
| `tenant-stateless` | `wallabag` | Deployment | *Pending Deployment Configuration* |
| `tenant-stateless` | `simplex-chat` | Deployment | *Pending Deployment Configuration* |
| `tenant-stateless` | `quartz-website` | Deployment | `apps/quartz-website/base/deployment.yaml` |
| `tenant-ephemeral` | *None Currently Assigned* | N/A | *Reservations for analytical scrapers / log parsers* |

---

## 🛠️ Implementation Workflow

To assign a workload to an established tier, inject the `priorityClassName` parameter directly inside the Pod template specification block:

```yaml
spec:
  template:
    spec:
      priorityClassName: tenant-stateful
      containers:
        - name: app-container
          image: forgejo/forgejo:latest
