# 21. Decoupled Global Issuer and Workload Certificate Strategy

## Status
Accepted

## Context
Legacy `ClusterIssuer` configurations utilized explicit domain selection rules (`spec.solvers.selector.dnsNames`). While this approach provided an initial sense of explicit filtering, it introduces a severe architectural coupling defect. 

Whenever a new internal subdomain tier (such as `*.internal.yourdomain.dedyn.io`) or an independent application ingress endpoint is introduced to the cluster, operators are forced to perform a breaking modification to global cluster-wide authority resources. This breaks the DRY (Don't Repeat Yourself) principle, increases manual platform synchronization friction, and violates the principle of least privilege in multi-tenant GitOps environments.

## Decision
Domain pattern validation is entirely decoupled from global `ClusterIssuer` assets by stripping all `selector` matching matrices from the solver array, turning the deSEC.io webhook into a generic, unconditional catch-all driver. 

Structural naming conventions, subdomain routing patterns, and wildcard taxonomies are strictly declared and enforced at the workload namespace layer using individual `Certificate` Custom Resources.

| Architectural Component | Target Implementation Layer | Senior Audit Question |
| :--- | :--- | :--- |
| **Global Routing Authority** | `ClusterIssuer` (Catch-All Webhook) | Does this control mechanism possess the API access credentials to solve challenges for any valid workspace request? |
| **Domain Taxonomy Boundaries** | `Certificate` (Strict `dnsNames` Constraints) | Is the requested domain string strictly bound to authorized internal infrastructure naming conventions? |

## Consequences
* **Decoupled Architecture:** Modifying or adding application subdomains no longer requires configuration updates or introduces regression risks to global cluster issuer infrastructure.
* **RBAC Alignment:** Application teams or local automated pipelines can provision explicit certificates within isolated namespaces without requiring administrative rights to cluster-wide resources.
* **Config Cleanliness:** Eliminates the necessity of maintaining duplicate, error-prone domain name records across multiple layers of abstraction.
