# Resource Naming Suffixes: FluxCD & Gateway API

To ensure high-speed CLI navigation (via `television` or `fzf`) and clear resource ownership, all manifests within the cluster must adhere to the following naming convention.

| Target | Why it is relevant | Senior Audit Question |
| :--- | :--- | :--- |
| **HelmRelease (`-hr`)** | Identifies the core application lifecycle and Helm engine. | Does the `HelmRelease` name match the `metadata.name` of the chart it deploys? |
| **HTTPRoute (`-rt`)** | Identifies Layer 7 web routing and Ingress logic. | Is the `-rt` suffix used consistently to distinguish routing from the `Service` object? |
| **GRPCRoute (`-grt`)** | Identifies high-performance binary RPC routing. | Is a `GRPCRoute` required, or can this traffic be handled by a standard `HTTPRoute`? |
| **Kustomization (`-ks`)** | Identifies a FluxCD reconciliation bucket or logical grouping. | Does this `-ks` resource manage a single app or a collection of shared infrastructure? |
| **ExternalSecret (`-es`)** | Identifies the instruction for fetching external sensitive data. | Does the `-es` name provide a clear link to its destination `-env-secrets` target? |

## Logic: Collision Avoidance
The use of unique, kind-based suffixes (`-hr` vs `-rt`) prevents naming collisions in multi-resource namespaces. This ensures that fuzzy finders isolate the correct manifest with minimal keystrokes, reducing the time to recovery during incident response.

# Resource Naming Conventions

| Target | Convention | Example |
| :--- | :--- | :--- |
| **ExternalSecret** | `<app>-es` | `linkding-es` |
| **HelmRelease** | `<app>-hr` | `linkding-hr` |
| **HTTPRoute** | `<app>-rt` | `linkding-rt` |
| **GRPCRoute** | `<app>-grt` | `linkding-grt` |
| **Kustomization** | `<app>-ks` | `linkding-ks` |
| **Target Secret** | `<app>-env-secrets` | `linkding-env-secrets` |

## Implementation Logic
Standardizing the `spec.target.name` of an `ExternalSecret` to `<app>-env-secrets` creates a predictable interface for Kubernetes Deployments. This allows for the use of `envFrom` in application templates without requiring manual inspection of unique secret names.

Target,Why it is relevant,Senior Audit Question
HelmRelease (-hr),Identifies the core application lifecycle and Helm engine.,Does the HelmRelease name match the metadata.name of the chart it deploys?
HTTPRoute (-rt),Identifies Layer 7 web routing and Ingress logic.,Is the -rt suffix used consistently to distinguish routing from the Service object?
GRPCRoute (-grt),Identifies high-performance binary RPC routing.,"Is a GRPCRoute required, or can this traffic be handled by a standard HTTPRoute?"
Kustomization (-ks),Identifies a FluxCD reconciliation bucket or logical grouping.,Does this -ks resource manage a single app or a collection of shared infrastructure?
ExternalSecret (-es),Identifies the instruction for fetching external sensitive data.,Does the -es name provide a clear link to its destination -env-secrets target?
