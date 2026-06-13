# pending apps
- postgrest (REST api for postgres)
- restic 
- volsync (storage management)
# Storage Logic Audit: Concise vs. Verbose

| Feature | Status | Why? |
| :--- | :--- | :--- |
| **Dynamic Provisioning** | **Active** | Longhorn creates the PV automatically based on your PVC size/class. |
| **Access Modes** | **RWO** | Best for performance in a single-node k3s setup. |
| **Volume Mode** | **Default** | Filesystem mode is the standard for web apps like linkding. |
| **Class Binding** | **Explicit** | By naming `longhorn`, you avoid the "Retroactive Default" complexity. |

# Access Mode Standards 

| Target | Convention | Senior Audit Question |
| :--- | :--- | :--- |
| **Application Data** | `ReadWriteOnce` (RWO) | Is the workload distributed across nodes, or is a block-level mount sufficient? |
| **Shared Assets** | `ReadWriteMany` (RWX) | Does the app strictly require concurrent writes from multiple nodes? |
| **Database (CNPG)** | `ReadWriteOnce` (RWO) | am I ensuring the lowest latency possible by avoiding network-filesystem overhead? |

# Linkding: Stateful Decoupling & Persistence Strategy

- This directory manages the `linkding` bookmark manager. The deployment follows a **Stateful Decoupling** pattern to ensure data integrity and backup reliability. 
  - Decoupled `pvc.yaml` from the `HelmRelease`, manually defining the storage rather than delegating its lifecycle and creation to Helm.

## 1. Core Rationale: Independent Lifecycles

In this infrastructure, **Compute** (Pods/Deployments) is treated as "Cattle" (disposable) while **Data** (PVCs/PVs) is treated as "Pets" (precious). Manually creating the PVC and referencing it via `existingPersistentVolumeClaim` decouples the data lifecycle from the application lifecycle.

| Feature | Helm-Managed PVC | Decoupled (Manual) PVC |
| :--- | :--- | :--- |
| **Ownership** | Owned by the Helm Chart. | Owned by the Namespace/Admin. |
| **Deletion Risk** | `flux delete` = **Data Loss**. | `flux delete` = **Data Persistent**. |
| **Naming** | Dynamic/Generated. | **Deterministic** (Fixed). |
| **Snapshots** | Inconsistent targets. | **Predictable** Longhorn target. |

## 2. Practical Advantages

### A. Predictability for Backups
Longhorn `VolumeSnapshot` manifests require a static `persistentVolumeClaimName`. 
- **Risk:** Automatic Helm generation (e.g., `linkding-123-pvc`) may change during chart updates, leading to broken snapshot references.
- **Solution:** A decoupled PVC ensures the name remains `linkding-data-pvc` indefinitely, rendering the backup logic immutable.

### B. Disaster Recovery 
In the event of a corrupted `HelmRelease` or deployment:
- **Decoupled Approach:** The `HelmRelease` can be deleted without impacting the underlying data. Upon re-application, the application re-attaches to the existing PVC, facilitating recovery in seconds rather than minutes or hours required for an S3 restore.

### C. Migration & Upgrades
Decoupling allows for a transition between different Helm charts or raw Kubernetes manifests without requiring data migrations. The "Compute" layer is simply pointed at the pre-existing "State" layer.

## 3. Definition of Decoupling
Decoupling ensures that two system components exist and function independently:
1. **The Application:** Subject to updates, deletions, or replacements.
2. **The State:** Remains persistent on the NVMe regardless of the application's lifecycle status.

# Resources Management
For a Python/Django application like Linkding, memory management is key. Python processes can have "spiky" memory usage during heavy indexing.

# observability
## tips for metric relabeling
- **Metric relabeling** can be debugged on the `http://vmagent:8429/metric-relabel-debug` page. 
- All labels that start with the __ prefix are automatically removed from metrics after relabeling.
  - It is common practice to store temporary labels with names starting with __ during metrics relabeling.
- All target-level labels are automatically added to all metrics scraped from targets, making them available during metrics relabeling.
- If too many labels are removed, different metrics might look the same — this can lead to duplicate time series with conflicting values, which is usually a problem.

