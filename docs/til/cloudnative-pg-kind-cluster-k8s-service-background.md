- When a `kind: Cluster` is defined/declared, **the operator** automatically *creates 3 different Services* in the background to handle different types of traffic.

# 3 services (markdown table)
|**Service Name**|**Type**|**Purpose**|
|---|---|---|
|**`[cluster-name]-rw`**|`ClusterIP`|**Read-Write:** Points only to the current Primary node. Use this for your App.|
|**`[cluster-name]-ro`**|`ClusterIP`|**Read-Only:** Points to the Replicas. Use this for BI or reporting tools.|
|**`[cluster-name]-r`**|`ClusterIP`|**Ready:** Points to any instance that is "Ready" (Primary or Replica).|
# cli inspection
```bash
kubectl get svc -n [your-namespace]
```

# why it is a Structural Necessity?

- In Kubernetes, Pods are "ephemeral" (they can die and get new IPs at any time).
  - A Database Cluster **must have a stable entry point.**
  - athanor example case:
    - Without that ClusterIP Service, the Linkding app would have to "guess" the IP of the database pod every time it restarts.
- The Service acts as the Stable Anchor in the "Athanor" hallways.
