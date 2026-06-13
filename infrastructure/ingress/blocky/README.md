# Architectural Decision: DNS Security & Hardening Strategy

**Status:** Proposed / Pending Implementation
**System:** Athanor (Single-node k3s on Artix)
**Component:** Blocky (DNS Provider)

## 1. Context
As the cluster moves toward "Zero Trust," we must address the security of DNS queries (Layer 4) when accessing the homelab from external networks (e.g., mobile devices, remote Artix laptops).

## 2. Identified Vulnerabilities (The 3 Gaps)
Without encryption, standard DNS (UDP 53) suffers from:
1. **Eavesdropping:** Plain-text queries allow ISPs or local network actors to log visited domains.
2. **Manipulation (Spoofing):** Lack of authenticity allows "Man-in-the-Middle" (MitM) attacks to redirect traffic to malicious IPs.
3. **ISP Tracking:** Metadata harvesting by providers for behavioral profiling.

## 3. Comparison of Mitigation Strategies

| Strategy | Mechanism | Security Scope | Complexity |
| :--- | :--- | :--- | :--- |
| **Standard DNS** | UDP 53 | None (Internal only) | Low |
| **DoH / DoT** | DNS over TLS/HTTPS | DNS Queries Only | High (Needs TLS Certs) |
| **WireGuard VPN** | Encrypted Tunnel | **Total Traffic (DNS + L7)** | Medium (Highest ROI) |

## 4. Decision: The "VPN-First" Approach
For the **Athanor** cluster, we prioritize a **WireGuard VPN** as the primary hardening layer for remote access.

### Rationale:
- **Reduced Attack Surface:** Only one UDP port is exposed to the internet.
- **Native Security:** DNS queries travel inside the encrypted tunnel, negating the immediate need for complex DoH/DoT setups within Blocky.
- **Simplified Access:** Once connected to the VPN, internal services like `grafana.athanor.io` are reachable via `ClusterIP` without exposing Traefik to the public internet.

## 5. Future Hardening (Tier 2)
Once the VPN is stable, Blocky will be further hardened using an **Internal CA (OpenBao/Vault)** to provide DoT for local LAN devices, ensuring "Zero Trust" even within the home network.

# Learning Trace: Service vs. Gateway API Integration

## 1. The Scenario
While configuring L7 access (HTTP) for the Blocky dashboard using the Gateway API (`HTTPRoute`), I faced a dilemma regarding the `HelmRelease` configuration. Since I was defining a dedicated `HTTPRoute` to handle the web traffic, I questioned whether the `http` port definition inside the `Service` values was still necessary.
```
      service:
        ...

       ports:
        ...
          http:
            enabled: true
            port: 4000
```
## 2. Initial Misconception
I initially thought that keeping the `http` port in the `spec.values.service` block was redundant. My mental model suggested that the `HTTPRoute` would "step on" or bypass the Service's L4 configuration to talk directly to the pods, or that the Route itself provided the necessary port mapping. I was tempted to eliminate the field to keep the `HelmRelease` "clean."

## 3. The Self-Correction
After reviewing the interaction between the Gateway Controller and the Kubernetes Service resource, I realized my logic was missing a critical link: **The Backend Contract.**

* **The Registry Role:** The `Service` acts as the cluster's internal directory. Even if traffic arrives via a sophisticated L7 Gateway, the Gateway still needs a "target room" to deliver that traffic to.
* **The Dependency:** An `HTTPRoute` points to a `Service`. If that Service doesn't explicitly declare the port (e.g., `4000`), the Gateway cannot resolve the reference. 
* **The Failure State:** Removing the port from the Service doesn't just make it "internal"; it makes the backend **unreachable** for the Gateway, resulting in a `503 Service Unavailable` or `BackendNotFound` error.

## 4. Final Conclusion
In the **Athanor** architecture, the `Service` is the foundational layer that must expose every port intended for use, regardless of whether it's accessed via L4 (LoadBalancer) or L7 (HTTPRoute).

* **L4 (DNS):** Handled by the `Service` (Type: `LoadBalancer`) on port `53`.
* **L7 (Web):** Handled by the `HTTPRoute` pointing to the `Service` on port `4000`.
* **Key Rule:** Never prune a port from the `Service` if an `HTTPRoute` or `Ingress` depends on it. The Service is the "bridge" that connects the Gateway to the Pods.
