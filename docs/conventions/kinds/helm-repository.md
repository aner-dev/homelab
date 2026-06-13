# Standards: Helm Repository & Release Naming Conventions

## 1. The Core Principle: "The Store vs. The Product"
In our GitOps workflow, we maintain a strict logical separation between the **Source** (where code comes from) and the **Instance** (the actual running application).

### The Source (`HelmRepository`)
* **Naming Pattern:** `[provider-name]` or `[provider-name]-charts`
* **Rationale:** A repository is a "Store." It often contains multiple different applications. Naming a repository after a specific app (e.g., `linkding`) creates **tight coupling** and makes the infrastructure confusing when adding a second app from the same provider.
* **Senior Goal:** **Reusability.**

### The Instance (`HelmRelease`)
* **Naming Pattern:** `[app-name]`
* **Rationale:** This represents the "Product" you bought from the store. It is specific to the functional deployment.

---

## 2. Comparison: Junior vs. Senior Patterns

| Feature | Suboptimal (Junior) | Standard (Senior) |
| :--- | :--- | :--- |
| **Repo Name** | `linkding` | `pascaliske` |
| **Scalability** | **Low.** If the provider adds a new tool, the name is lying. | **High.** Can host any chart from that provider. |
| **Clarity** | Confusing. Is it the app or the source? | Clear. It defines the "Upstream" source. |
| **Maintenance** | High. Multiple repos for one provider. | Low. One source, many releases. |

---

## 3. Reference Implementation

### The HelmRepository (The Store)
```yaml
# infrastructure/sources/pascaliske.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: pascaliske 
  namespace: flux-system
spec:
  interval: 2h
  url: [https://charts.pascaliske.dev](https://charts.pascaliske.dev)
```

### The HelmRelease (The Product)
```yaml 
# infrastructure/apps/linkding/base/release.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkding
  namespace: linkding
spec:
  chart:
    spec:
      chart: linkding
      sourceRef:
        kind: HelmRepository
        name: pascaliske # Points to the provider, not itself
        namespace: flux-system
```
## 4. Protocol Selection: Standard vs. OCI

Choosing the correct `spec.type` is critical for successful Flux reconciliation. Use the following logic based on the repository URL:

### Standard Helm Repository (HTTP/HTTPS)
* **URL Format:** `https://charts.example.com`
* **Flux Configuration:** Leave `spec.type` empty (default) or explicitly set it to `default`.
* **Mechanism:** Flux looks for an `index.yaml` file to discover chart versions.

### OCI Repository (Open Container Initiative)
* **URL Format:** `oci://ghcr.io/owner/charts` or `oci://harbor.local/library`
* **Flux Configuration:** Must set `spec.type: oci`.
* **Mechanism:** Flux treats the chart like a container image stored in a registry.

> **Warning:** Do not mix these. An `https://` URL will fail if `type: oci` is enabled, and an `oci://` URL requires the `oci` type to function.
