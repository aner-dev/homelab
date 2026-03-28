# Node Maintenance & Recovery Guide

This guide covers lifecycle operations for nodes within the `athanor` cluster, specifically focused on disk replacement and node decommissioning.

## 1. Removing a Node from the Cluster
Follow these steps to safely remove a node without risking data corruption on Longhorn volumes.

### Prerequisites
- Ensure all workloads are migrated (if multi-node).
- Verify that no "Last Replicas" exist on this node if it's the only one.

### Procedure
1. **Disable Scheduling:** In the Longhorn UI (Node tab), select the node and set `Scheduling` to `Disable`.
2. **Evict Replicas:** Select `Evict Replicas` to move data to other available nodes.
3. **Detach Volumes:** Ensure all volumes on the node are in a `Detached` state.
4. **Delete via Kubernetes:**
   ```bash
   kubectl delete node <node-name>
    ```
    ```
> Note: Longhorn will automatically detect the deletion and clean up its internal registry.

## 2. Reusing a Node Name (Hardware Replacement)
- Use this procedure if you are replacing the motherboard/CPU or reinstalling Artix Linux but keeping the same hostname.

### The "Stale Disk" Issue
- Longhorn identifies disks by a unique ID.
- If you reinstall the OS or change the physical disk while keeping the same Node Name, Longhorn will see the new disk as "Unknown" or "Orphaned."

### Procedure
1. Clean the Old Metadata: Before adding the new node to the cluster, ensure the old node object is deleted from the Longhorn UI.
2. Remove Original Disks: In the Node tab, delete the entries for the "old" disks that no longer exist physically.
3. Add New Disks: Once the new node (with the same name) joins the cluster, go to Nodes > Edit Node and Disks and add the new paths (e.g., /var/lib/longhorn).
4. Rebuild Replicas: Longhorn will begin synchronizing data to the new disk from existing replicas in the cluster.

[!CAUTION]
- If you are on a single-node cluster and you replace the disk without a backup, data will be lost.
- Always verify your Longhorn Backups to external storage (S3/NFS) before performing these steps.
