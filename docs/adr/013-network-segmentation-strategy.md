# ADR 012: Network Segmentation & Database Exposure Strategy

## Status
Accepted

## Context
I would require a networking architecture for the Athanor cluster that balances security with the need for external data inspection (DBeaver/pgAdmin). 

I evaluated three distinct patterns:
1. **ClusterIP only:** Maximum security, but introduces significant friction by requiring a temporary `kubectl port-forward` for every session.
2. **Dedicated Database IP Pool:** High observability and alignment with **High Availability** standards, but increases operational complexity by requiring the management of multiple Cilium IPPool resources.
3. **Traefik TCP Facade:** Provides a stable external endpoint using the existing LoadBalancer IP, reducing configuration overhead while maintaining a structured ingress path.

## Decision
I will implement **Option 3 (Traefik TCP Facade)**. 
- Application services will remain strictly on `type: ClusterIP`.
- Database access will be routed through a dedicated Traefik EntryPoint on port 5432.
- I will defer the creation of a dedicated `postgres-pool` until the cluster expands to multiple nodes or requires hardware-level IP auditing.

## Rationale (Production Principles)
My decision is based on several **Production-grade** foundations:
- **Blast Radius Control:** Future-proofing the network so that database traffic can eventually be isolated to prevent application-layer congestion from impacting data integrity.
- **Deterministic Auditing:** Ensuring that infrastructure components have predictable network identities, making it easier to write external firewall rules.
- **Resource Isolation:** Preventing "IP Exhaustion" by ensuring the address space is partitioned logically between general ingress and core stateful services.

## Consequences
- **Positive:** Reduced cognitive load; I only need to maintain a single Cilium IPPool and a unified **Label Taxonomy**.
- **Negative:** Shared fate; a failure in the Traefik LoadBalancer affects both web traffic and direct database management.
