# Local Path Provisioner Storage Engine

This directory maintains the declarative infrastructure assets for the local-path host-path provisioner inside the `athanor` cluster.

## Architecture Configuration Matrix

| Feature Parameter | Default Values | Purpose / Constraints | Future Action Item |
| :--- | :--- | :--- | :--- |
| **`nodePathMap`** | `/opt/local-path-provisioner` | Fallback absolute path directory for unscheduled volumes. | Expand path lists if dedicated high-speed NVMe mounts are introduced. |
| **`volumeBindingMode`** | `WaitForFirstConsumer` | Mandated storage class setting. Delays volume binding until Pod placement is scheduled. | Maintain strictly to ensure local pods bind correctly to host storage topology. |
| **`CONFIG_MOUNT_PATH`** | *Not set* | Enables automated live-reloading of the helper pod configurations. | **Todo:** Inject `- name: CONFIG_MOUNT_PATH` with value `/etc/config/` into `deployment.yaml`. |
| **`pathPattern`** | *Default Go Template* | Dictates directory naming schemes on the host operating system. | Explore parsing `{{ .PVC.Namespace }}/{{ .PVC.Name }}` for clean pathing audits on the host. |

---

## 🚀 Tracked Future Improvements

### 1. Enable Dynamic Configuration Updates
Currently, changes made to `helperPod.yaml` or setup scripts require an administrative bounce of the provisioner deployment.
- [x] Add the `CONFIG_MOUNT_PATH` environment variable patch to the primary controller spec.

### 2. Implement Stable Node Affinity Keys
If host virtual machines or bare-metal configurations undergo hostname updates during kernel updates or maintenance recycles:
- [ ] Migrate StorageClass parameters from `kubernetes.io/hostname` over to a custom stable node label (e.g., `athanor.io/stable-node-id`).
