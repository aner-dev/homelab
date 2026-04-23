# TIL: Kubernetes Networking - `port` vs `targetPort`

## The Core Concept
In Kubernetes, a `Service` acts as a stable "Front Door" (Abstration Layer) for a group of Pods. The distinction between `port` and `targetPort` allows the infrastructure to remain standardized even when applications use non-standard internal ports.

## Comparison Table

| Field | Identity | Scope | Senior Definition |
| :--- | :--- | :--- | :--- |
| **`port`** | **Infrastructure Port** | Service (Cluster-Internal) | The "Standardized" port used by the cluster to access the service (e.g., 80). |
| **`targetPort`** | **Application Port** | Pod/Container (Backend) | The "Hardcoded" port the application binary is actually listening on (e.g., 9090). |

## The "Senior" Mental Model
The `Service` acts as a **Translator**. 

1. **Input:** Traffic arrives at the Service on the **Infrastructure Port** (`port`).
2. **Translation:** The Service maps that traffic to the **Application Port** (`targetPort`).
3. **Output:** The packet is delivered to the Pod on the port the application expects.



## Why This Matters (The "Athanor" Context)
1. **Decoupling:** You can change the application's internal port (e.g., moving from a Python app on 5000 to a Go app on 8080) without changing your `HTTPRoutes`, `CiliumNetworkPolicies`, or Global Scrapers. You only update the `targetPort`.
2. **Standardization:** It allows all internal web traffic in the `athanor` cluster to move over port `80`, creating a clean and predictable network map.
3. **Observability:** Centralized tools like VictoriaMetrics can assume a standard port for scraping while the `Service` handles the "messy" reality of the backend.

## Common Rule of Thumb
* **Service Port (`port`)**: What the **Cluster** sees.
* **Target Port (`targetPort`)**: What the **App** sees.
