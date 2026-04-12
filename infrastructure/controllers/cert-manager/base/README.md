# DNS & TLS Convention (Athanor Cluster)

## Wildcard Strategy
To simplify certificate management and reduce ACME rate-limiting, we use a **Wildcard Pattern** for all internal and external services.

| Scope | Domain Pattern | Issuer |
| :--- | :--- | :--- |
| **Internal (LAN)** | `*.athanor.local` | `vault-issuer` (OpenBao) |
| **External (WAN)** | `*.yourdomain.com` | `letsencrypt-desec` |

### Usage in HTTPRoutes
When defining a new `HTTPRoute`, the `hostnames:` field **must** adhere to the patterns above to ensure Traefik can successfully attach the `athanor-wildcard-cert` secret.

> **Note:** Nested subdomains (e.g., `app.dev.athanor.local`) are NOT covered by the current wildcard and require a dedicated Certificate resource.

## TLS Strategy: Public Trust vs. Private CA

The cluster utilizes **Publicly Trusted Certificates** (Let's Encrypt via deSEC) for internal and external networking to avoid the **laborious** maintenance of a Private CA.

| Approach | Effort Level | Maintenance | Trust Level |
| :--- | :--- | :--- | :--- |
| **Public CA (deSEC/LE)** | Low | Automated (Flux + cert-manager) | Universal / Out-of-the-box |
| **Private CA (e.g., Vault)** | **Laborious** | High (Manual CA injection per device) | Internal only / Restricted |

**Decision:** Leveraging "Split-Brain DNS" with **Blocky** allows us to use public certificates for private IPs, ensuring a seamless "Green Lock" experience on all devices without manual certificate trust management.

# Issuer Redundancy
The cluster implements a "Plug-and-Play" Issuer strategy.
While deSEC is the primary provider for DNS-01 challenges, a Cloudflare ClusterIssuer is maintained as a fallback. This ensures high availability for TLS certificate renewals and prevents vendor lock-in.
