# Standard Networking Signatures
The following signatures will be the primary fingerprints used to define the `CiliumClusterwideNetworkPolicy` (CCNP).

| Service Type | Protocol | Dest Port (Magnitude) | Rationale |
| :--- | :--- | :--- | :--- |
| **DNS (Blocky)** | `UDP / TCP` | `53` | Core utility for name resolution. |
| **Web (Gateway)** | `TCP` | `80 / 443` | Inbound/Outbound traffic via Traefik. |
| **Database** | `TCP` | `5432` | Postgres SQL wire protocol. |
| **Observability** | `TCP` | `9090` | Prometheus metric scraping signature. |
| **Cache (Redis)** | `TCP` | `6379` | High-speed data transfer signature. |


# Labeling Standards: Prefixes and Namespaces
- Using the prefix `networking.homelab.local/` is a best practice and aligns with official Kubernetes standards.
 
- **Kubernetes labels** follow the *DNS Subdomain format (RFC 1123).*
  - Using a prefix prevents Label Collision (when two different tools try to use the same label name, like role).
  - Official Examples: You will see `io.kubernetes.pod.name`, `cilium.io/app`, or `app.kubernetes.io/name`.
- Homelab's Implementation:
  - Using `networking.homelab.local/[signature-name]` follows the standard recommendations.
    - It clearly identifies that the label is a Custom Internal Policy specific to the "Athanor" infrastructure.
