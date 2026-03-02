# error: longhorn-manager in `CrashLoopBackOff`
The logs shows that the `csi-provisioner` is crashing, which is the specific "Worker" that watches for new PVCs (requests) and creates PVs (physical assets).
Since it is crashing, the AdGuard PVCs will stay Pending forever.
# 4 possible causes
Missing Dependencies: Longhorn requires open-iscsi (iscsiadm) or multipathd to be installed on the Host OS (The node's kernel).

Resource Exhaustion: Rancher Desktop might not have enough CPU/RAM. Longhorn components are "heavy" sidecars.

Mount Issues: Longhorn is trying to find a disk path (like /var/lib/longhorn) that doesn't exist or is read-only on the virtual node.

Environment Incompatibility: (New) If using WSL2, the kernel might lack the specific iscsi_tcp modules required for the handshake.
# debug & troubleshooting commands
```bash 
kubectl logs -n longhorn-system -l app=longhorn-manager --tail=50
# Pick one of the crashing provisioner pods
kubectl logs -n longhorn-system csi-provisioner-6c859d7bbf-h8zlc
```
# root cause 
Dependency Mismatch (Binary Missing):
The `longhorn-manager` failed to initialize because it could not find the `iscsiadm binary` on the Host OS (Rancher Desktop VM).
The manager requires this host-level utility to map block devices to the Kubernetes nodes.
AI analogy: Without the "hands" (iSCSI), the "brain" (Manager) exits with a fatal error.

# longhorn architecture and design learning
Longhorn is a "Software-Defined Storage" layer.
It doesn't have its own "fingers" to touch the physical hard drive; it uses the Host OS kernel as its fingers.
If the Host OS is missing the iscsi library, Longhorn is like a brain without hands—it can think about storage, but it can't grab it.

