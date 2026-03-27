# ADR 001: Stateful and Stateless Cluster Segregation

* **Status**: Proposed / In-Progress
* **Date**: 2026-03-27
* **Deciders**: @user (Architect)
* **MVP Goal**: Deploy `linkding` across the cluster boundary.

## 1. Context and Problem Statement
Currently, the `artix` cluster handles both stateful (Postgres, Forgejo) and stateless workloads. This creates "noisy neighbor" issues and complicates the backup strategy for persistent volumes. We need a way to isolate "Data Gravity" from "App Agility."

## 2. Decision Drivers
* **Security**: Isolate the database network from the public-facing application network.
* **Resiliency**: Updates to the stateless cluster should not risk the integrity of the Forgejo/Postgres data.
* **Scalability**: Use Cilium ClusterMesh to provide cross-cluster networking.

## 3. Proposed Architecture
* **Cluster A (Stateful/Athanor)**:
    - Workloads: Forgejo, CloudNative-PG, Longhorn.
    - Exposure: Internal IP-pools managed by Cilium.
* **Cluster B (Stateless/Anima)**:
    - Workloads: Linkding, Quartz Blog, Traefik.
    - Exposure: Public Gateway API / Ingress.

## 4. Connectivity Strategy (The "Linkding" Path)
1. **Database**: Postgres running in Cluster A.
2. **App**: Linkding running in Cluster B.
3. **Bridge**: Cilium ClusterMesh provides Global Service peering.
4. **Secret Management**: External-Secrets syncing DB credentials across the mesh.

## 5. Consequences
* **Positive**: Better resource allocation; cleaner FluxCD multi-tenancy logic.
* **Negative**: Increased complexity in networking (ClusterMesh overhead).
* **Neutral**: Requires two distinct `kubeconfig` contexts.

## 6. Implementation Log
- [ ] Initialize `anima` cluster directory in `clusters/`.
- [ ] Configure Cilium ClusterMesh.
- [ ] Migrate Postgres to CNPG in `athanor`.
- [ ] Deploy Linkding as MVP.
