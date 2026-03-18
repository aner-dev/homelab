# ADR-011: Cilium Security Posture & L7 Gateway Strategy

## Status
Accepted

## Context
While inspecting the **RBAC manifests** for Cilium, I identified that the `cilium-operator` is granted **mutating permissions** (`create`, `update`, `patch`, `delete`) on the `secrets` resource. These **over-privileged verbs** unnecessarily increase the **blast radius** of the Cilium control plane; a compromise of the operator pod could lead to unauthorized manipulation of sensitive cluster data.

I realize that these permissions are intentional within the Cilium ecosystem when it functions as the **Gateway API implementation**, where the operator acts as a secret-proxy for TLS certificates. However, I am currently using **Traefik** for L7 traffic management. 

I have evaluated the trade-offs: 
- **Cilium:** Offers high-performance eBPF-driven routing but introduces significant kernel-level complexity and debugging overhead.
- **Traefik:** Incurs minor CPU overhead but is significantly easier to implement and manage through its middleware ecosystem.

I have decided to stick with Traefik for its operational simplicity while acknowledging the performance cost.

## Decision
I am retaining the default Cilium RBAC permissions on the `cilium-operator` rather than hardening them at this time.

## Rationale

1. **Operational Simplicity over Micro-Optimization:** Traefik operates entirely in user-space as a standard Go-based reverse proxy. This abstracts away low-level networking, allowing me to debug L7 routing using standard HTTP logs and metrics. 
2. **Avoiding eBPF Debugging Overhead:** While Cilium offers superior performance by bypassing the traditional network stack via eBPF, troubleshooting it requires specialized tooling (`hubble`, `cilium monitor`) and deep kernel-level knowledge. I am choosing to avoid this steep debugging curve at this stage.
3. **Hardware Headroom:** The performance decrease of Traefik is a minor CPU overhead. The Ryzen 5 5600GT has more than enough compute power to absorb this without any noticeable bottleneck for a homelab environment.
4. **Strategic Technical Debt:** (Keep your existing point about security and keeping the door open for future Cilium testing).


## Consequences
- **Security:** The `cilium-operator` remains over-privileged. I must monitor this component as a high-value target.
- **Future Action:** If I decide to move away from Gateway API experimentation entirely, I will apply a Kustomize patch to enforce the **Principle of Least Privilege (PoLP)** by stripping these mutating verbs.

## References
- Cilium Documentation: [Gateway API Support](https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/gateway-api/)
- Cloud Native Computing Foundation (CNCF): [Cloud Native Security Whitepaper](https://github.com/cncf/tag-security/blob/main/security-whitepaper/v2/cloud-native-security-whitepaper-v2.md)
