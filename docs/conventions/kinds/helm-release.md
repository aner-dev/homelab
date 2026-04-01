
# Stateful/Storage Declaration in `spec.values` of `kind HelmRelease` manifests

- This table defines the 4 foundational requirements for managing persistent data within the athanor cluster.
- These fields must be declared within the `spec.values` of any `HelmRelease` that requires disk persistence.
  - provision a Persistent Volume Claim (PVC) via Longhorn.

| Target | Why it is relevant | Senior Audit Question |
| :--- | :--- | :--- |
| **`enabled: true`** | The master switch that tells Helm to render the PVC manifest. | Is the storage controller actually active, or is the app running statelessly? |
| **`storageClassName`** | Explicitly directs the request to the `longhorn` provisioner. | Is this defaulting to `local-path`, or is it correctly bound to the `longhorn` SC? |
| **`accessMode`** | Defines how the volume is mounted (usually `ReadWriteOnce`). | Does the workload require multi-node access, or is `RWO` the optimal choice? |
| **`size`** | Defines the capacity limit for the thin-provisioned volume. | Is the requested size sufficient for 12 months of data growth? |
