# 009: Prefer OCI Registries for Artifact Distribution

## Status
Accepted

## Context
As the homelab grows, managing diverse artifact types (Docker images, Helm charts, and Kustomize overlays) across different repository formats introduces operational overhead. 

Traditional Helm repositories rely on a monolithic `index.yaml` file. As the number of chart versions grows, this file becomes large, slow to parse, and prone to race conditions during updates. Furthermore, traditional repositories require specific authentication schemes and lack the robust security features—such as vulnerability scanning and content trust—that modern container registries provide.

Given that I have already established Harbor as our private OCI registry (see [ADR-008](008-harbor-as-private-oci-registry.md)), I have a centralized location capable of storing all these artifacts using a unified protocol.

## Decision
I will adopt an **OCI-first bias** for all infrastructure artifacts. 

1. **Helm Charts:** I will prioritize using OCI references (`oci://`) over traditional HTTPS repositories. Upstream charts will be mirrored to our local Harbor instance.
2. **Flux Integration:** I will use Flux's `HelmRepository` with `type: oci` or the `OCIRepository` resource for distributing Kustomize bundles.
3. **Unified Authentication:** All image pulls and chart fetches will authenticate against Harbor using the same robot accounts and RBAC structure.
4. **Versioning:** I will strictly follow SemVer, leveraging OCI tags to manage artifact lifecycles across the `base/`, `production/`, and `staging/` environments.

### Workarounds
In cases where an upstream provider does not yet support OCI distribution, I will:
* Manually pull the chart and push it to our Harbor OCI registry.
* Fall back to a traditional Helm repository only as a temporary measure, documented within the specific component's `base/` directory.

## Consequences
* **Easier:** Centralized auditing and security scanning for both images and charts within Harbor.
* **Easier:** Significant performance improvements in Flux reconciliation, as it no longer needs to download and parse massive `index.yaml` files.
* **Easier:** Simplified CI/CD pipelines (Gitea Actions) by using a single toolset (e.g., `helm push`, `oras`, or `crane`) for all uploads.
* **Difficult:** Requires a manual step to mirror upstream charts that do not natively provide OCI endpoints.
* **Difficult:** Initial migration of existing `HelmRepository` resources from legacy URLs to OCI URLs.
