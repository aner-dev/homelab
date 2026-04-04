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
