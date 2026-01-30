# Summary
- During the initial deployment of the CloudNativePG operator, intentional over-provisioning of Stateful instances (15) led to Node resource exhaustion.
- commands: edited my `database.yaml` (CloudNativePG Cluster resource) and set: `instances: 15` Then I ran: `kubectl apply -f database.yaml`
# Root Cause
The primary failure was a *Resource Deadlock*.
By requesting 15 heavy PostgreSQL instances on a single-node homelab (K3s), the Kubernetes Scheduler entered a Pending Loop.
Because Kubernetes prioritizes data safety, the resulting Orphaned PVCs continued to reserve storage/slots even after the pod count was reduced, preventing the system from recovering automatically.

# Debugging & Troubleshooting 
- This is the part that confused me the most. Even after I changed the YAML back to `instances: 3`, the cluster stayed "broken."
- Logically, `StatefulSets` do not delete PVCs when scaling down.
- Result: I had 12 "Orphaned" PVCs (Ghost Contracts) still claiming 1Gi of disk space each.
- The Operator tried to create new Pods. But because those 15 PVCs were still "reserved" in the system's logic (even if not in use), the *scheduler* got in a *Pending Loop* or hit *storage limits*, preventing the new healthy pods from starting.
  - Each of the 15 pods was waiting for a "Physical Volume" to be available, but because I've reached my machine's storage or CPU limit, the pods stayed in `Pending`.
# Resolution (Solution & Bad Practices)
- command: `k delete cluster demo-cluster -n database`
- I delete the cluster and restarting again, which is a huge error and suboptimal approach, that only make sense in my 'young' homelab project context. Which hasn't any relevant data until now. 
- If I had real data, I would have lost everything. 
- This will be a disaster in a production environment
## Lessons Learned (what this error teach me?)
- 
- Scaling down a kind: Cluster (CNPG) reduces the Pod count but leaves PersistentVolumeClaims intact.
- This would have freed the "Resources" while keeping the data for Pods 0, 1, and 2 safe.
- At researching in k8s docs, I found that this would be a safety feature of Kubernetes to *prevent data loss*
- So, preserve PVCs is a logical and useful implementation of k8s. 
- However in this Homelab specific context, it leads to "Ghost" storage consumption.
- 
- 
### optimal troubleshooting
- Instead of deleting the whole cluster, the correct debugging and troubleshooting approach should be:
  - Scaled down to 3 instances.
  - Manually identified the specific PVCs for instances 4 through 14.
  - Deleted only those specific orphaned PVCs.
- Sequence of Steps: > 1. Scale down the Cluster resource. 2. Manually identify and delete orphaned PVCs using kubectl delete pvc <name>. 3. Verify Node resources (CPU/RAM) are back to normal before scaling back up.

## Corrective and Preventative Measures (what changes in the project this error will produce?)
- Improvements:
- Implement a Defensive Programming & Infrastructure mindset
  - Thinking about edge cases and possible gaps in my infrastructure will save much time of unnecessary troubleshooting & debugging, while improving the automation and flow of my homelab systems. 

### Tasks: (3 possible implementations)
- A. `ResourceQuotas` 
  - If I had a Quota set to 5Gi, the 15-instance command would have been rejected immediately by the API server, preventing the crash entirely.
    - tell K8s: "This namespace is only allowed to use 4Gi of RAM and 10 PVCs total." 
  - Then if I would try to ask for 15, K8s will say "Forbidden" and won't even try to start them.
  - Namespace Isolation:
    - Don't just put Quotas on the whole cluster; but rather to put them on the `database namespace.`
    - Ensuring ensures that if the database goes crazy and requests 100 disks, it doesn't break the `networking or monitoring namespaces`.


- B. LimitRanges
  - Forces every Pod to have a maximum "size." This will prevents one "hungry" Postgres pod from eating all the RAM.

- C. PVC Auto-Deletion Policy (StatefulSets) `persistentVolumeClaimRetentionPolicy`
  - What it does: Configure the StatefulSet so that when it scales down, it automatically deletes the PVC.
  - Risks & Disadvantages: Using Auto-Deletion on a database is dangerous for production but useful for a learning Homelab
    - Thus this is usually disable for databases because the data should stay even if the pod dies
