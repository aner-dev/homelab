# ADR 022: Zero-Trust Network Isolation via 2-Layer Cilium Identity Matching

**Date:** 2026-05-26  
**Status:** Accepted  

## 1. Context and Problem Statement

The GitOps-driven single-node cluster (**athanor**) uses **FluxCD** for declarative application delivery and **Cilium** as the eBPF-native CNI. To achieve a comprehensive zero-trust posture, network traffic between applications and the ingress routing layers (Traefik) must be strictly isolated and controlled.

A friction point arises when deploying third-party Helm charts (e.g., `linkding` or `cert-manager`). Many upstream charts do not expose native values for injecting custom metadata labels directly into the underlying `PodTemplateSpec`. While the FluxCD v2 API provides an escape hatch through `spec.postRenderers` Kustomize patches to inject these tags post-compilation, writing these multi-line JSON/YAML patches for every third-party application introduces significant configuration verbosity, increased maintenance overhead, and syntactic fragility inside the GitOps repository.

I need a maintainable, clean, and highly secure method to enforce explicit boundary parameters between the Traefik gateways and targeted applications without modifying or patching upstream application deployment manifests.

## 2. Decision Drivers

* **Maintainability:** Eliminate the requirement for verbose Kustomize `postRenderers` structures across application definitions.
* **Zero-Trust Posture:** Enforce the Principle of Least Privilege by blocking unauthorized lateral network movement between pods.
* **GitOps Elegance:** Keep the `HelmRelease` manifests clean, predictable, and aligned with standard upstream values schemas.
* **Performance:** Utilize Cilium's native eBPF-compiled Security Identity mechanics instead of relying on heavy runtime evaluation layers.

## 3. Considered Options

* **Option 1: Upstream Value Injection & Kustomize Post-Rendering Patches:** Rely strictly on chart parameters where available, and mandate an explicit Kustomize `postRenderers` JSON patch block inside the `HelmRelease` when custom pod label fields are absent.
* **Option 4: Pure Namespace-Level Isolation:** Target ingress rules using only the automatically injected namespace label (`k8s:io.kubernetes.pod.namespace: traefik`). 
* **Option 3: 2-Layer Label Combination Matching (Selected):** Create a multi-dimensional intersection rule inside a decoupled `CiliumNetworkPolicy`. This combines the auto-injected Kubernetes namespace metadata with the concrete binary identity label of the ingress controller container (`app.kubernetes.io/name: traefik`).

## 4. Decision Outcome

I will implement **Option 3: 2-Layer Label Combination Matching**.

By designing my `CiliumNetworkPolicy` manifests to match a strict logical **AND** condition combining the namespace name and the application descriptor tag, I eliminate the need to patch third-party application templates entirely. Security boundaries are managed through completely independent policy abstractions.

### Technical Implementation Details

* **Macro Perimeter Layer:** The policy establishes a catch-all security posture for the local namespace via an open `endpointSelector: {}` block.
* **Micro Identity Constraint:** The ingress array mandates that the source traffic must match both the namespace origin label *and* the application workload token simultaneously.

This forces Cilium to hash these metadata coordinates into a unique, high-performance runtime **Cilium Security Identity**. If an auxiliary pod inside the `traefik` namespace is compromised, it will fail this intersection check and remain entirely isolated from my application data backends.

### Example Policy Blueprint
```yaml
spec:
  endpointSelector: {}
  ingress:
    - fromEndpoints:
        - matchLabels:
            "k8s:io.kubernetes.pod.namespace": "traefik"
            "app.kubernetes.io/name": "traefik"
``` 

## 5. Consequences

- **Positive:** The GitOps repository remains clean and free of redundant Kustomize patching configurations.
    
- **Positive:** Complete network observability is retained inside Hubble, as endpoints are tracked as distinct cryptographic units down to the Linux kernel socket.
    
- **Negative:** Security logic requires strict adherence to uniform naming conventions for the gateway namespaces and application keys cluster-wide.
