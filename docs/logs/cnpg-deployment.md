# Infrastructure/controllers/cnpg-controller
this architecture decouples the "Management Logic" from the "Data."
Operator: Infrastructure level (lives in cnpg-system).

Postgres Pods: Application level (lives in linkding).
# cnpg-controller troubleshooting 
#1. The Annotation Overflow (The 256KB Limit)
The Cause: kubectl apply stores the entire last-applied YAML in an annotation (kubectl.kubernetes.io/last-applied-configuration).

The Error: Large objects (like the CNPG Pooler CRD) exceed the 256KB metadata limit.

The "Senior" Fix: Use Server-Side Apply (--server-side). This offloads the "diff" logic to the cluster and stops using the bulky client-side annotation.

#2. The Partial-State Dilemma
The Concept: kubectl apply is not "all or nothing."

The Discovery: Your command successfully updated 23 objects (Webhooks, Roles, CRDs) but failed on 1 (The Deployment).

The Lesson: Never assume a command "worked" just because you see some "unchanged/configured" lines. Always check the exit code ($?) and verify the specific high-value resource.

#3. Metadata vs. Immutable Selectors
The Concept: Kustomize commonLabels usually tries to inject labels into both Metadata (safe to change) and Selectors (immutable).

The Conflict: Changing a selector breaks the "Ownership Link" between the Deployment and its Pods.

The Production Trade-off: * Option A (The Nuke): Delete/Recreate (Accepts downtime for clean labels).

Option B (The Patch): Update metadata labels only (Maintains uptime, but creates "Labeling Debt" where selectors don't match standard labels).
## change selectors
In HA (high-availability) production, we almost never change selectors. Why? Because if you change the selector, the Deployment "loses track" of its existing pods, which can cause an outage.

# reasoning / rationale
- I've deleted the cnpg-deployment and create a new one 
- While this is optimal and secure for my current development, isn't it a good practice in production environments or more advanced homelab development.
  - why?: 
# Best practices in migration: Clean State 
- In a real production migration (e.g., moving from one labeling standard to another), we often:
1. Create a second deployment with the new labels.
2. Shift traffic to it.
3. Delete the old one.


# elements
- CRDs 
  - k8s API communication
- Operator Deployment
- 
- RBAC (Roles and Bindings) - Permissions
  - ServiceAccount
  - ClusterRole
- Admission Webhooks - Validation 
# Annotation too long (Error)

# immutable fields (kustomization files)


 
- 
- 
- 
- 
- 
- 
