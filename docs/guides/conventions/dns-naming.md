# Homelab DNS & FQDN Convention

## Overview
This document defines the Single Source of Truth (SSOT) for network naming within the internal infrastructure. We follow a **Convention over Configuration** pattern to simplify the deployment of new services.

## The Root Zone
The internal TLD (Top Level Domain) for all Kubernetes services is:
`*.homelab.local`

## Infrastructure Mapping (The "Static" Layer)
Physical nodes and legacy hardware are mapped individually in the Blocky `customDNS` configuration.

| Hostname | IP Address | Description |
| :--- | :--- | :--- |
| `gateway.homelab` | `192.168.1.1` | Main Router / Internet Exit |
| `vault.homelab` | `192.168.1.50` | Physical Security / Hardware Vault |

## Kubernetes Ingress (The "Dynamic" Layer)
We use a **Wildcard DNS** entry to route all subdomains to the Cilium LoadBalancer. This allows for instant deployment of new services without modifying DNS records.

**Wildcard Mapping:**
`homelab.local` -> `192.168.1.192` (Cilium LoadBalancer IP)

### FQDN Structure
All Kubernetes services must follow this format:
`<service-name>.homelab.local`

**Examples:**
- `longhorn.homelab.local`
- `grafana.homelab.local`
- `traefik.homelab.local`

## Traffic Flow (Under the Hood)
1. **Resolution:** Blocky resolves any `*.homelab.local` query to `192.168.1.192`.
2. **Ingress:** The browser connects to Traefik on Port 443 (HTTPS).
3. **Routing:** Traefik inspects the **HTTP Host Header** and matches it against the `HTTPRoute` manifest.
4. **Encryption:** TLS termination is handled by Traefik using certificates issued by `cert-manager` (via `vault-issuer` or `letsencrypt`).

## Troubleshooting
- **DNS Lookup:** `dig +short <service>.homelab.local @<blocky-ip>`
- **HTTP Headers:** `curl -vI -H "Host: <service>.homelab.local" https://192.168.1.192 --insecure`
