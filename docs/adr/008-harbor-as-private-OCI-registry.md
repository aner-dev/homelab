# ADR-008: Implementation of Harbor as a Private OCI Registry

## Status
Proposed

## Context
Our current Kubernetes homelab relies on external public registries (Docker Hub, Quay.io, GitHub Container Registry) for container images and Helm charts. This creates a hard dependency on external internet connectivity for cluster reconciliation. Furthermore, it lacks a "Production-Grade" environment for practicing OCI (Open Container Initiative) artifact management, vulnerability scanning, and lifecycle governance.

## Decision
We will deploy **Harbor** as the central artifact management system for the homelab. Harbor will serve as our private OCI-compliant registry, hosting both container images and Helm charts (using the OCI distribution spec).

### 1. Reasoning & Motivation
* **Local Autonomy:** Reduce the "Internet Dependency" (Air-gapping logic). Once an image is pulled into Harbor, the cluster can restart or scale without an active internet connection.
* **Latency Reduction:** Pulling large container layers over a local 1Gbps/10Gbps network is significantly faster than pulling from public clouds.
* **Security & Governance:** Implementation of automated vulnerability scanning (Trivy) to identify "CVEs" in our images before they reach production.

### 2. Industry-Standard OCI Learning
Deploying Harbor allows us to master production patterns used in Enterprise/Cloud environments:
* **Image Tagging & Lifecycle:** Managing "Production-ready" vs "Staging" tags.
* **Robot Accounts:** Implementing the "Least Privilege" principle by giving FluxCD specific pull-only credentials.
* **Registry Mirroring:** Learning how to "proxy" public images (like Longhorn or OpenBao) into an internal repository.

### 3. Infrastructure Integration
* **Storage (Longhorn):** Harbor requires a database (PostgreSQL) and a storage backend. It will consume **Distributed Block Storage** provided by Longhorn via a dedicated `StorageClass`.
* **Secrets (OpenBao):** The admin credentials, database passwords, and certificate private keys will be stored and governed by OpenBao.
* **GitOps (FluxCD):** Flux will be reconfigured to use Harbor as its primary `HelmRepository` source, moving from `https` public URLs to local OCI references.

### 4. Capabilities & Future Improvements
* **Artifact Consistency:** Ensuring that the same image SHA is used across all environments.
* **Content Trust:** Potential implementation of image signing (Cosign/Notary) to ensure only "trusted" images run in the cluster.
* **Storage Optimization:** Using Harbor's garbage collection to manage the 1TB SSD space efficiently by purging old, unused image layers.

## Consequences
* **Positive:** Higher cluster stability, faster deployments, and deeper knowledge of OCI distribution.
* **Negative:** Increased resource consumption (CPU/RAM) on the single-node cluster to run Harbor's microservices (Registry, Core, Jobservice, Database).
* **Mitigation:** We will start with a "Small" profile for Harbor, disabling non-essential features like ChartMuseum (in favor of OCI) to save memory.
