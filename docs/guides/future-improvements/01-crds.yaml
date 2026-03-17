# GitOps Decision Log: Flux Kustomization `force` Usage

## Context
In FluxCD, the `.spec.force` field determines how the controller reacts when a "Patch" operation fails due to **immutable field changes** in the Kubernetes API.

## Decision
**Current Status:** `force: false` (Default)

We will maintain `force: false` as the global standard for the cluster, specifically for Application layers, to prioritize **availability over automated recovery**.

## Technical Rationale

### 1. The Risk of `force: true` (Downtime)
When `force` is enabled, Flux performs a **Delete-and-Recreate** operation if a standard Patch fails. 
- **Consequence:** For `Deployments`, `StatefulSets`, or `DaemonSets`, this results in immediate pod termination.
- **Impact:** Temporary service interruption (Downtime) while new pods are scheduled and initialized.

### 2. The "Immutable Field" Conflict
Kubernetes prevents certain fields from being changed after an object is created (e.g., `spec.selector` in a Deployment). 
- Without `force`, Flux will stall and report an `ImmutableFieldChange` error.
- This is a "Safety Break" that forces a human engineer to review the change before causing potential downtime.



## Exceptions & Workarounds

### Infrastructure & CRD Layers
For `layer-01-crds`, the risk of downtime is minimal because CRDs are API definitions, not running processes. However, to follow best practices, we use the **Targeted Force** approach.

### The "Targeted Force" Pattern (Recommended)
Instead of enabling `force` globally in the `Kustomization` manifest, we apply it only to the specific resource causing the conflict via annotations:

```yaml
metadata:
  annotations:
    kustomize.toolkit.fluxcd.io/force: enabled
