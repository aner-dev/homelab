# TIL: Longhorn Manager `CreateContainerError` & Mount Propagation 
- **mount propagation issue**

## Context
During the deployment of the Longhorn storage engine on my bare-metal Artix Linux (OpenRC) host, the `longhorn-manager` DaemonSet pods were stuck in a continuous `CreateContainerError` loop. 

## Root Cause Analysis
Investigating the pod events (`kubectl describe pod`) revealed the following Kubelet error:
`Error: failed to generate spec: path "/var/lib/longhorn/" is mounted on "/" but it is not a shared mount`

The core issue stems from Linux kernel **Mount Propagation**. By default, on this Artix setup, the root filesystem (`/`) is configured with "Private" mount propagation. Longhorn, as a Container Storage Interface (CSI), dynamically creates and attaches block devices inside its containers. If the host mount is private, these virtual disks cannot propagate back to the host kernel, making them invisible to other Kubernetes pods. The Kubelet correctly blocked the container creation as a safety measure.

## Resolution
To establish the Data Plane, the host's filesystem required bidirectional mount propagation.

1. Applied the recursive shared mount flag to the root filesystem on the host:
   ```bash
   doas mount --make-rshared /
2. Ensured the Longhorn data directory existed:

```bash
doas mkdir -p /var/lib/longhorn
```

3. Deleted the failing `longhorn-manager` pods to trigger the Kubernetes reconciliation loop:
```bash
kubectl delete pod -n longhorn-system -l app=longhorn-manager
```
Upon recreation, the pods successfully generated their specs, reached the 2/2 Running state, and successfully deployed the subsequent CSI components (csi-attacher, csi-provisioner, etc.).
## Future Considerations
Because my current artix linux system utilizes `OpenRC` rather than `systemd`, this kernel mount flag **will not persist across reboots.**
A local startup script (e.g., /etc/local.d/mount-shared.start) must be implemented to execute mount --make-rshared / at boot time to prevent storage failure during host cycling.







