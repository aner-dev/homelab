# Routing Strategy: Decentralization vs. Centralization

This document outlines the architectural rationale for decentralizing `HTTPRoute` manifests within the `athanor` cluster, specifically focusing on why the Kubernetes Gateway API approach favors app-local routing over global centralization.

| Concept | Centralized (Old Ingress Style) | Decentralized (Gateway API Style) |
| :--- | :--- | :--- |
| **Location** | `infrastructure/gateways/routes/` | `apps/<app-name>/base/` |
| **Ownership** | Platform/Infrastructure Team | Application Team / App Folder |
| **Blast Radius** | **High**: One typo can affect all cluster ingress. | **Low**: Affects only the specific application. |
| **Security** | Requires many `ReferenceGrants`. | **Implicit**: No cross-namespace grants needed. |

---

## The "Role-Oriented" Design Rationale

The Gateway API was designed to solve the "Mega-Ingress" problem. In older systems, the Infrastructure team had to manage every single path for every single app. This created a **bottleneck**.

### 1. Separation of Concerns
The Gateway API splits the configuration into three distinct personas:
1. **Infrastructure Provider:** Manages the `GatewayClass` (Cilium/Traefik installation).
2. **Cluster Operator:** Manages the `Gateway` (The IP, Ports, and Wildcard TLS Certificates).
3. **App Developer:** Manages the `HTTPRoute` (The Hostname and Backend Service).

### 2. The "ReferenceGrant" Tax
If we centralize routes in a single namespace (e.g., `traefik`), every route would need to "reach into" the application namespace to find its `Service`. 
* **The Penalty:** You would have to create a `ReferenceGrant` for every app.
* **The Benefit of Decentralization:** By placing the `HTTPRoute` inside the app's namespace, it "attaches" to the Gateway without needing a security handshake, because the route and service share the same trust boundary.

### 3. GitOps Lifecycle Alignment
By keeping the `linkding-rt.yaml` inside the `linkding` directory:
* **Atomic Deletions:** Deleting the app folder automatically cleans up the external entry point.
* **Self-Documentation:** A developer looking at the app folder instantly sees how the app is exposed to the internet.

## Senior Audit Question
> "Does my app folder contain everything it needs to exist and be reached?"
> 
> **Answer:** Yes. By including the `HTTPRoute` in the app base, the deployment is a self-contained unit of infrastructure.

---

## Neovim / CLI Workflow
Because we use a "Search-First" naming convention (`<app>-rt.yaml`), we maintain high velocity:
* **Fuzzy Find:** `<leader>ff` -> `link rt` (Instantly find Linkding routes).
* **Television (CLI):** `tv -e yaml linkding` (List all manifests for the app).
