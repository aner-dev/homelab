# Post-Mortem: Cluster Network Egress & DNS Black Hole

## Incident Metadata
* **Status:** Resolved
* **Environment:** Bare-Metal K3s (Artix Linux / OpenRC)
* **Architecture:** `base-production-staging` 
* **Impact:** Total loss of external network egress and internal Service IP routing for all pods. FluxCD synchronization halted.

## 1. Executive Summary
The cluster experienced a complete inability to resolve external domains or route traffic outside the Pod network (`10.42.0.0/16`). The incident was caused by a combination of a stale DNS configuration (NextDNS zombie provider), OS-level firewall contention (`firewalld` blocking CNI traffic), and the subsequent corruption of `iptables` rules during initial troubleshooting. 

## 2. Root Cause Analysis (RCA)

| Component | Failure Mechanism | Resolution |
| :--- | :--- | :--- |
| **DHCP / resolv.conf** | `dhcpcd` was injecting deprecated NextDNS IPs into `/etc/resolv.conf`, effectively breaking host DNS resolution. | Updated `/etc/dhcpcd.conf` with `static domain_name_servers=1.1.1.1 8.8.8.8` to enforce upstream stability. |
| **OS Firewall** | `firewalld` enforced an implicit `DROP` policy on the `FORWARD` chain, discarding traffic traversing from `cni0` to `eth0`. | Disabled OS firewall: `rc-service firewalld stop` & `rc-update del firewalld default`. |
| **CoreDNS** | Inherited the "zombie" `/etc/resolv.conf` upon pod startup. | Decoupled CoreDNS from host by editing the ConfigMap to statically forward to `1.1.1.1`. |
| **K3s Service Routing** | Manual `iptables` flushes destroyed the internal `KUBE-SERVICES` NAT chains, breaking Pod-to-Service communication. | Wiped state using `k3s-killall.sh` followed by a hard reboot to trigger idempotent reconciliation. |

## 3. Step-by-Step Remediation Sequence

**Step 1: Host Network Stabilization**
```bash
# Prevent dhcpcd from injecting bad DNS
sudo nano /etc/dhcpcd.conf # Add static domain_name_servers
sudo rc-service dhcpcd restart
