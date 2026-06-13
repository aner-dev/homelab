# ADR 004: Metadata Lifecycle Governance and Label Abstraction Strategy

## Status
Accepted

## Context & Problem Statement
In my GitOps workflow for the `athanor` cluster, configuring Kubernetes manifests creates a natural tension between keeping code DRY (Don't Repeat Yourself) and ensuring correct resource linking. Standard metadata tags (like `app.kubernetes.io/part-of`) were previously scattered across multiple files (`helm-release.yaml`, `configmap.yaml`, `database.yaml`, `cnp.yaml`), creating a high risk of configuration drift. 

However, trying to eliminate duplication entirely by centralizing *all* label references into a single file or a `HelmRelease` values map is architecturally impossible. Kubernetes controllers and eBPF primitives (like Cilium network policies) rely on hardcoded label selectors to establish functional boundaries, firewall edges, and traffic routing targets.

I need a clear architectural boundary that separates global organizational metadata from structural, localized selector wiring.

## Decision Drivers
* **Maintainability:** Standardize cross-resource categorization tags without copy-pasting strings across files.
* **Schema Integrity:** Avoid breaking Kubernetes controller routing mechanics (Cilium, CloudNativePG, Gateway API) by blindly trying to abstract functional references.
* **Velocity:** Ensure that inspecting, tracing, or refactoring connectivity paths inside my Neovim and CLI-toolkit workspace remains fast and reliable.

## Considered Options
1. **The Distributed Approach (Status Quo):** Hardcode all identity labels and selectors manually in every single manifest.
2. **The Helm-Centric Approach:** Use the `HelmRelease` `podLabels` map as the single source of truth for the entire app suite. (Rejected: Helm cannot inject labels into external manifests like standalone CNPs or separate operators).
3. **The Hybrid Identity/Selector Abstraction Engine (Kustomize SSOT):** Split the metadata layer into two strict functional classes: centralized identity tags and localized structural pointers.

## Decision Outcome
I will implement Option 3 as my absolute cluster standard. 

### Identity Metadata Standard
I will treat standard organizational metadata (the Kubernetes recommended labels) as an environmental infrastructure concern. The root `base/kustomization.yaml` file for each application will act as my absolute Single Source of Truth (SSOT). I will strip individual app manifests (`configmap.yaml`, `helm-release.yaml`) bare of these tags and let Kustomize inject them dynamically at compile time across the entire target resource tree:

```yaml
# base/kustomization.yaml
labels:
  - includeSelectors: true
    pairs:
      app.kubernetes.io/name: linkding
      app.kubernetes.io/part-of: athanor-core
      app.kubernetes.io/managed-by: flux
```
### Structural Selector Standard
- I will deliberately keep functional target selectors (like matchLabels inside CiliumNetworkPolicy or operator backend declarations) hardcoded inside their respective configuration files.
  - I accept this duplication as a strict requirement of the Kubernetes control plane model, acting as structural "glue" or explicit variable bindings between distinct infrastructure components.

### Inspection and Auditing Protocols (CLI)
- Because selectors act as strict compile-time dependencies, I will manage and audit them using my native terminal toolkit.

- To trace, audit, or mass-modify structural selector dependencies across an application directory, I will use line-grepping tools like ripgrep or fuzzy finders (television).
- To audit live runtime label attachments on live pods or endpoints, I will query the cluster control plane directly using kubectl.

## Consequences
Positive: Drastically reduced manifest sizes and a single, predictable clearinghouse (kustomization.yaml) for app metadata.

Positive: Clean decoupling of infrastructure-level firewalling/storage mechanics from raw application values.

Negative/Neutral: Requires intentional awareness when editing files; I must remember that some labels are injected dynamically by Kustomize while others are hardcoded as operational pointers.
