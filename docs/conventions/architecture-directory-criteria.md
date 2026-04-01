# question: put `postgres/` in `infrastructure/configs` or in `infrastructure/applications`??
I will distinguish between Volatiles (Apps) and Statefuls (Databases).

Lifecycle Mismatch: You might update your linkding app five times a day. You might update your Postgres version once every six months. Keeping them in the same layer creates unnecessary risk for your data during app deployments.

Dependency Hierarchy: Multiple apps might eventually need to talk to the same Postgres instance (Shared Service). If Postgres is tucked inside the linkding/ folder, it’s logically "owned" by Linkding, making it awkward for other apps to use.

Backup & Recovery: By grouping Postgres, OpenBao, and Longhorn in the 03 layer, you can apply specific Flux postBuild substitutions or backup policies to that entire layer, ensuring your "Data Crown Jewels" are protected separately from your "Web Frontends."
# Repository Governance: Controllers vs. Configurations

The maintenance of a scalable, stable, and predictable cluster requires a strict separation between the **installation of engines** and the **implementation of logic**. This architecture ensures that the lifecycle of a tool remains decoupled from its specific functional application.

---

## 1. The Controller Layer (`infrastructure/controllers/`)

* **Purpose:** Lifecycle management and installation of the Operator/Controller binary.
* **Contents:** `HelmRepository`, `HelmRelease`, and any `base` Kustomizations required for functional operation.
* **Functional Logic:** Removal of a directory within this layer results in the uninstallation of the corresponding tool from the cluster API.
* **Architectural Role:** This layer is responsible for the availability of **CRDs** (Custom Resource Definitions) and the controller runtime.

## 2. The Configuration Layer (`infrastructure/configs/`)

* **Purpose:** Global, cluster-scoped, or shared logic that **instantiates** the installed controllers.
* **Contents:** CRD instantiations such as `ClusterSecretStore`, `ClusterExternalSecret`, `ClusterIssuer`, or global `NetworkPolicies`.
* **Functional Logic:** These manifests define the **capabilities** and security posture of the infrastructure.
* **Dependency:** Resource validity depends on the operational status of the Controllers and the presence of their respective CRDs.

---

## Architecture Logic: Dependency Flow

The separation of these concerns mitigates **Race Conditions** during cluster bootstrapping. Isolation of the "Engine" (Controller) from the "Fuel" (Configuration) ensures that Flux reconciles the operator layer first. This sequence allows the Kubernetes API to recognize and validate the custom objects defined within the `configs/` directory before they are processed.

| Layer | Responsibility | Analogy |
| :--- | :--- | :--- |
| **Controller** | Binary / Operator / CRD | The Engine |
| **Configuration** | Settings / Rules / Logic | The Fuel |
