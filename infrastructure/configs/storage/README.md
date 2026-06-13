# Cluster Priority Hierarchy (Athanor)

## Rationale
In a Kubernetes cluster, **Resource Contention** is inevitable. When the node (Ryzen 5 5600GT) reaches its CPU or Memory limits, the Kubelet must decide which Pods to "Evict" (kill) to keep the system stable. 

Without Priority Classes, this selection is random or based on resource usage alone. This documentation defines a **Tiered Survival Hierarchy** to ensure that critical infrastructure (Longhorn, Networking) survives even if applications are struggling.



---

## Naming Convention

We use a functional prefixing system to make the purpose of each class immediately obvious within a manifest.

| Priority Class | Value | Tier | Typical Use Cases |
| :--- | :--- | :--- | :--- |
| `infra-foundation` | 900,000,000 | **Critical** | Longhorn Manager, Cilium, Cert-Manager |
| `app-stateful` | 500,000,000 | **High** | CloudNative-PG, Forgejo, MariaDB |
| `app-ephemeral` | 100,000,000 | **Standard** | Linkding, Commafeed, Scrapers |

---

## The Manifests

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: infra-foundation
value: 900000000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
description: "Core cluster services. These pods are the last to be evicted."
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: app-stateful
value: 500000000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
description: "Stateful applications that require persistent storage."
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: app-ephemeral
value: 100000000
preemptionPolicy: Never
globalDefault: false
description: "Non-critical workloads that should not trigger preemption."
```

## Operational Behavior
- Preemption: If an infra-foundation pod needs to start but the node is full, it will Preempt (kill) an app-ephemeral or app-stateful pod to take its place.
 
- The "Safe" Tier: app-ephemeral is set to preemptionPolicy: Never. This means these pods will wait in a "Pending" state until resources are free, rather than aggressively killing other pods to start.

- Storage Stability: By placing Longhorn in the infra-foundation tier, we prevent "Storage Deadlock," where a database tries to run but the storage engine has been evicted.

## Metadata & Constraints
- Range: Values must be less than or equal to 1 billion.
 
- System Protection: Values above 1 billion are reserved for system-cluster-critical (K8s internal components). We stay just below that to respect system stability.
