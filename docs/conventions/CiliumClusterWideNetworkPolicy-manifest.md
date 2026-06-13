# Standard Networking (network-zones)
The following network-zones will be the primary fingerprints used to define the `CiliumClusterwideNetworkPolicy` (CCNP).

| Service Type | Protocol | Dest Port (Magnitude) | Rationale |
| :--- | :--- | :--- | :--- |
| **DNS (Blocky)** | `UDP / TCP` | `53` | Core utility for name resolution. |
| **Web (Gateway)** | `TCP` | `80 / 443` | Inbound/Outbound traffic via Traefik. |
| **Database** | `TCP` | `5432` | Postgres SQL wire protocol. |
| **Observability** | `TCP` | `9090` | Prometheus metric scraping network-zone. |
| **Cache (Redis)** | `TCP` | `6379` | High-speed data transfer network-zone. |


# Labeling Standards: Prefixes and Namespaces
- Using the prefix `networking.athanor.local/` is a best practice and aligns with official Kubernetes standards.
 
- **Kubernetes labels** follow the *DNS Subdomain format (RFC 1123).*
  - Using a prefix prevents Label Collision (when two different tools try to use the same label name, like role).
  - Official Examples: You will see `io.kubernetes.pod.name`, `cilium.io/app`, or `app.kubernetes.io/name`.
- athanor's Implementation:
  - Using `networking.athanor.local/[network-zone-name]` follows the standard recommendations.
    - It clearly identifies that the label is a Custom Internal Policy specific to the "Athanor" infrastructure.
