## TLS Strategy: Public Trust vs. Private CA

The cluster utilizes **Publicly Trusted Certificates** (Let's Encrypt via deSEC) for internal and external networking to avoid the **laborious** maintenance of a Private CA.

| Approach | Effort Level | Maintenance | Trust Level |
| :--- | :--- | :--- | :--- |
| **Public CA (deSEC/LE)** | Low | Automated (Flux + cert-manager) | Universal / Out-of-the-box |
| **Private CA (e.g., Vault)** | **Laborious** | High (Manual CA injection per device) | Internal only / Restricted |

**Decision:** Leveraging "Split-Brain DNS" with **Blocky** allows us to use public certificates for private IPs, ensuring a seamless "Green Lock" experience on all devices without manual certificate trust management.
