# CloudNativePG (CNPG) Architectural Rationale

This document serves as the "Source of Truth" for the design decisions and operational logic of the PostgreSQL clusters within the **Athanor** infrastructure.

## 1. Core Hierarchy: Operator vs. Cluster
A common misconception is treating `Kind: Cluster` as a K8s-wide template. In reality:
* **The Operator:** The global "Manager" (Binary/Controller).
* **The Cluster:** A dedicated **High Availability (HA) Group** or **Instance**.
* **The Database:** Logical containers inside the Instance.

**Decision:** We utilize **Option B (Isolated Model)**. Each application (Forgejo, Linkding, etc.) receives its own `Kind: Cluster`. 
* **Rationale:** Reduces "Blast Radius" and "Noisy Neighbor" effects. Given the Ryzen 5 5600GT (32GB RAM), the ~60Mi memory overhead per instance manager is negligible compared to the stability gains.

---

## 2. Resource Management & Determinism
To prevent RAM crashes and ensure "Sane Defaults," we explicitly define resource boundaries.

### Image Pinning (FQIN)
We avoid mutable tags. We use the **Fully Qualified Image Name (FQIN)** including the "system" flavor for full feature support (backups/monitoring).
* **Target:** `ghcr.io/cloudnative-pg/postgresql:17.9-202603230821-system-trixie`
* **Tooling:** Use `skopeo` or `crane` (Go-based/Daemonless) to inspect digests and labels without pulling images.

### Memory Allocation Rule-of-Thumb
PostgreSQL performance relies on the OS cache. 
* **Calculation:** Set `postgresql.parameters.shared_buffers` to **25%** of the `resources.limits.memory`.
* **Example:** For a 1Gi limit, `shared_buffers` = 256MB.

---

## 3. Bootstrap Logic ("living document")
The `spec.bootstrap` section is **not** a menu; it is an **Exclusive Choice** representing the current lifecycle state.

| Method | Context (Use Case) | GitOps Action |
| :--- | :--- | :--- |
| `initdb` | **Day Zero:** New project/Cold start. | Default state in manifest. |
| `recovery` | **Disaster Recovery:** Restore from S3. | Pivot manifest when Longhorn volume is lost. |
| `pg_basebackup` | **Migration:** Cloning from external source. | Temporary pivot for data ingestion. |

### Flux Disaster Recovery Strategy
In the event of a total volume loss:
1. Hardware/CSI is restored.
2. The Git manifest is updated: remove `initdb`, add `recovery` pointing to **Garage (S3)**.
3. Flux reconciles the change.
4. The Operator detects "No Data + Recovery Intent" and rebuilds the instance.

---

## 4. Backup Integration (Garage S3)
Backups are handled by **Barman** (integrated into CNPG).
* **Storage:** Dedicated Rust-based **Garage** S3 deployment.
* **Connectivity:** Requires explicit `endpointURL` in the `barmanObjectStore` configuration to bypass standard AWS routing.

## 5. Metadata Inheritance
I use `spec.inheritedMetadata` to ensure that labels are propagated to all generated resources (Pods, PVCs, Jobs).
* **Rationale:** I need consistency across my cluster. Without this, my Pods would lack the identifiers required for my **Cilium Network Policies** to function correctly.
* **Standard:** I always include `app.kubernetes.io/name` to identify the database's purpose within the global stack.

## 6. Directory Structure & Ownership
I follow the **App-Centric Pattern** for resource placement:
* **Placement:** All `Kind: Cluster` manifests reside within their respective `apps/<APP>/` directories.
* **Rationale:** This ensures that the database lifecycle is strictly tied to the application it serves. 
* **Infrastructure Role:** My `infra/configs/` directory is reserved for the CNPG Operator itself and global platform configurations (StorageClasses, Monitoring CRDs), not individual database instances.

## 7. The "One App, One Instance" Rule
I have standardized on a **1:1 Mapping** between applications and PostgreSQL clusters.
* **Implementation:** Each application namespace contains its own `Kind: Cluster`.
* **Rationale:** I prioritize **Lifecycle Decoupling**. I want the ability to upgrade or delete an application and its data as a single unit without impacting the rest of my Athanor infrastructure.
* **Resource Impact:** I accept the minor memory overhead (~100Mi per instance) as a trade-off for the security and maintenance benefits of total isolation.
