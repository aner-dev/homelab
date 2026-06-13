# Incident Report: Cilium CNI Mount Propagation Failure

## Status: Resolved
**Date:** 2026-03-26
**Environment:** Artix Linux (OpenRC) | K3s | Cilium (eBPF)

## 1. Executive Summary
During the implementation of Cilium, the cluster experienced a total loss of **DNS Resolution**. The root cause was identified as a mismatch between Cilium's requirement for `shared` mount propagation and OpenRC's default `private` mount behavior for the `/run` and `/sys/fs/bpf` filesystems.

## 2. Technical Root Cause
In **OpenRC**, the init system does not automatically set mount propagation to `shared`. 
* **The Conflict:** Cilium needs to share its BPF maps and socket files from the host into the pods. 
* **The Failure:** When mount propagation is changed at **Runtime** (after the services have started), the change does not propagate into the existing container namespaces. This prevents the Cilium agent from attaching eBPF programs to the internal pod interfaces, resulting in a network "black hole" for DNS traffic.

## 3. Comparison: Systemd vs. OpenRC
| Feature | Systemd | OpenRC (Unix Philosophy) |
| :--- | :--- | :--- |
| **Mount Default** | `shared` (Container-friendly) | `private` (Isolation-focused) |
| **Philosophy** | Integrated "All-in-one" | Minimalist / Decoupled |
| **K8s Impact** | "Just works" | Requires manual propagation init |

## 4. Resolution
To avoid the instability of runtime changes, a **custom init script** was implemented to handle mount propagation at the **Boot Level** (before the K3s service initializes).

### Commands Applied:
```bash
# Ensuring shared propagation before K3s starts
mount --make-rshared /
mount --make-shared /run
```
## 5. Lessons Learned
- Linux Mounting: Foundations of linux mounting, namespaces & containerization 
  - Cgroups, network & mount namespaces, isolation, resource management, etc. 
- Visibility: Standard kubectl logs are insufficient when the data plane (eBPF) is broken; node-level dmesg or cilium-bugtool are required.
- Init Systems: When using non-Systemd distros (Artix/Gentoo), the engineer must manually reconcile the host's filesystem state with OCI (Open Container Initiative) requirements.
