# Homelab Network Architecture

## Subnet Overview
* **Primary Subnet:** `192.168.1.0/24`
* **Netmask:** `255.255.255.0`
* **Gateway (Router):** `192.168.1.1`
* **Broadcast:** `192.168.1.255`

## IP Address Management (IPAM)
| Range Segment | Start IP | End IP | Usage / Authority |
| :--- | :--- | :--- | :--- |
| **Network/Gateway** | `192.168.1.0` | `192.168.1.1` | Reserved (Network/Router) |
| **DHCP Pool** | `192.168.1.2` | `192.168.1.190` | Managed by Router (Mobile, IoT, PCs) |
| **K8s LoadBalancer** | `192.168.1.192` | `192.168.1.199` | **Cilium L2 Announcements (/29)** |
| **Static Reserved** | `192.168.1.200` | `192.168.1.254` | Manual Static IPs (Servers/Nodes) |

## Kubernetes CIDR Details
### Cilium LoadBalancer Pool (`/29`)
* **CIDR:** `192.168.1.192/29`
* **Allocated Services:**
  * `192.168.1.192`: Traefik Gateway (Ingress Controller)
  * `192.168.1.193`: Blocky (DNS)
  * `192.168.1.194`: *Reserved for Forgejo/Forge*

## Router Configuration (Manual)
* **Status:** Modified 2026-03-01
* **Action:** Shrink DHCP scope to end at `.190` to prevent L2 IP collisions with Cilium LoadBalancer services.
* **Backup:** Configuration binary stored in `infrastructure/backups/router/` (Encrypted with OpenBao/SOPS).
