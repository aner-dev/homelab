# decouple CRD management from FluxCD Helm Controller
- files/notes I need and/or are related to this architectural decision:
- 'docs/guides/criteria.md' / 'docs/guides/layer-criteria.md' 
  - 'docs/guides/crd-criteria.md'
- 'guides/homelab-networking.md'
- 'fluxcd architecture orchestration layered.md'
- 'guides/SOPs.md' or a dedicated 'guides/fluxcd-SOP.md' (standard operating procedure)
# rationale
- ***lifecycle*** will be the core theoretical object to use as a reference for this new architectural approach. 

# markdown table 
## GitOps Layer Mapping Table

This table defines the standard architectural layers for the Artix homelab infrastructure.

| Layer | Name | Responsibility | Example App |
| :--- | :--- | :--- | :--- |
| **01** | **CRDs** | Cluster-wide API Extensions | Cilium, Longhorn, Gateway API |
| **02** | **Controllers** | Operators/Logic Providers | Cert-Manager, Traefik, Harbor Operator |
| **03** | **Secrets** | Security/Vault integration | ExternalSecrets, OpenBao |
| **04** | **Applications** | Workloads (Standard Apps) | Vaultwarden, Linkding, Quartz |
| **05** | **Ingress** | Routing/Policy Management | Gateway, ExternalDNS, Cilium Network Policies |

