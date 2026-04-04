# Athanor Cluster: Traefik Dashboard Security & Observability

## 1. Architectural Strategy: The "Internal Observer" Model
This document defines the production-grade deployment of the Traefik Dashboard (the Management UI) within the `athanor` cluster.

### 1.1 Decision: Internal-Only Binding
The Traefik Dashboard is an **internal-facing** tool. It is strictly attached to the `internal-gateway` to prevent public exposure.

| Attribute | Configuration Value | Reason |
| :--- | :--- | :--- |
| **Gateway Reference** | `internal-gateway` | Keeps the dashboard off the Public/External IPv4. |
| **IP Pool** | `home-lan-lb-pool` | Binds the entrypoint to the 192.168.1.192/29 subnet. |
| **Hostname** | `traefik.athanor.local` | Only resolvable via the local Blocky DNS. |

### 1.2 The "Global View" Rationale
Because the Traefik process manages the entire **Control Plane**, the dashboard provides a **100% scope-view** of the cluster's networking state, even when accessed through an internal-only gateway.

* **Metric Aggregation:** The UI displays traffic, health, and routes for both `internal` and `external` gateways.
* **Security Isolation:** Attackers scanning the external gateway see only public-facing services (e.g., Forgejo). They cannot "see" the `/dashboard` endpoint.

### 1.3 Data Plane vs. Control Plane Independence
It is critical to distinguish between the **access path** and the **observation scope**:

* **The Data Plane (Traffic):** Consists of the `internal` and `external` Gateways. These are the "ears" listening for specific packets on specific IPs.
* **The Control Plane (The Brain):** The single Traefik binary that processes all logic. The Dashboard is a direct window into this Brain.

**Rationale for Independence:**
- The Dashboard does not "belong" to the Gateway it is attached to.
- Attaching the `HTTPRoute` to the `internal-gateway` is merely a **Security Filter**.
- It restricts *who* can see the Brain, but it does not restrict *what* the Brain sees.
  - Even if a service is only exposed via the `external-gateway`, it will be 100% visible and manageable from the internal UI.
---

## 2. GitOps Directory Placement
To follow the **Separation of Concerns**, the `HTTPRoute` for the UI lives at the `production/` level, wrapping the specific gateway configurations.

```text
./production
├── kustomization.yaml (Parent: includes internal/, external/, and UI)
├── httproute-ui.yaml  (The Global Observer)
├── internal/          (Private services: internal-gateway, gateway-class)
└── external/          (Public services: external-gateway)
