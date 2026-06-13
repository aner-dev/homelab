# Secret Management & Cross-Namespace Access
**Status:** Decided  
**Date:** 2026-03-31  
**Context:** Homelab 'Athanor' - K3s, FluxCD, Traefik (Gateway API), OpenBao, ESO.

## 1. The Synthesis (Executive Summary)

* **ESO Authority:** The External Secrets Operator (ESO) operates across all namespaces because of Kubernetes **RBAC** (ClusterRole/Binding). It is a system-level "Courier" pre-authorized by the administrator.
* **The ReferenceGrant:** This is the modern "gate" required for **cross-namespace** sensitive data access. It allows a consumer (like Traefik) to "reach across" the namespace wall without needing global permissions.
* **Undeniable TLS:** HTTPS is mandatory for secure application exposure; Traefik acts as the central point for handling these handshakes.
* **The Two-Object Reality:** An "External Secret" physically consists of **two objects**: the source entry in **OpenBao** (managed by Tofu) and the **corresponding** Kubernetes Secret copy synchronized by ESO.

---

## 2. Detailed Rationale

### A. The RBAC Logic (The Master Key)
ESO doesn't require a `ReferenceGrant` to create secrets in your application namespaces because it possesses a **ClusterRole**. 
In our "Apartment" analogy, ESO is the **Building Manager**. During installation, you gave it a master key to every mailbox. Its "nature" as an operator is to manage the lifecycle of these resources cluster-wide. It is an **active** manager of state.



### B. The Physical vs. Conceptual Secret
When we talk about a secret in this architecture, we are looking at a **Synchronized State** between two different physical databases:
1.  **Object A (OpenBao):** The encrypted entry sitting in your Vault/OpenBao database. This is your **Single Source of Truth (SSOT)**.
2.  **Object B (K8s Secret):** A Base64-encoded copy in the cluster's `etcd` store. 

ESO's job is **Reconciliation**: it constantly checks if Object B matches Object A. If they differ (State Drift), ESO updates the K8s object so the cluster **converges** to the desired state.



### C. The Namespace Wall: Cloning vs. ReferenceGrant
When Traefik (in the `traefik` namespace) needs to use a TLS certificate located in an app's namespace, we face the "Namespace Wall." 

| Strategy | Global Wildcard (Cloning) | ReferenceGrant (Gateway API) |
| :--- | :--- | :--- |
| **Mechanism** | Copies the secret into every namespace. | Traefik "reaches across" to read the original. |
| **Security** | **Higher Risk.** Requires "God-mode" tokens. | **Lower Risk.** Explicit, granular permission. |
| **Philosophy** | "Broadcasting" (Public notice). | "Gating" (Private handshake). |

The **ReferenceGrant** is the "New Way." It was built specifically to avoid the security risks of the "Old Way" (where LoadBalancers had to be able to read every secret in the cluster).



---

## 3. Implementation Logic
1.  **Tofu** creates the secret in **OpenBao**.
2.  **ESO** (using its ClusterRole) fetches it and creates a **K8s Secret** in the `<APP>` namespace.
3.  A **ReferenceGrant** is placed in the `<APP>` namespace to "open a gate" for Traefik.
4.  **Traefik** traverses that gate to retrieve the certificate and perform the TLS handshake.
5.  **The App** remains a "passive tenant"—it doesn't even know the certificate exists; it just receives the traffic.
