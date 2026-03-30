# ADR 014: Separation of Infrastructure Provisioning and Kubernetes Workloads

## Status
Accepted

## Context
The repository structure originally included the Infrastructure as Code (IaC) logic (OpenTofu) within the same directory as the Kubernetes manifests (e.g., `homelab/infrastructure/tofu`). This structure creates ambiguity between the code responsible for provisioning hardware/base services and the code responsible for managing application workloads.

## Decision
Relocate all OpenTofu configuration files from the `infrastructure/` subdirectory to a top-level directory named `tofu/`. 

The repository hierarchy is restructured as follows:
* `tofu/`: Contains the Layer 0 logic (Machine provisioning, LUKS, K3s installation).
* `kubernetes/`: Contains the Layer 1 logic (FluxCD, application manifests, and cluster-wide operators).

## Rationale
The separation is based on the following architectural requirements:

* **Lifecycle Decoupling:** Infrastructure provisioning (Layer 0) has a different lifecycle and frequency of change compared to application manifests (Layer 1). Infrastructure must be fully established and stable before Kubernetes workloads can be scheduled.
* **Credential Scoping:** Tofu requires high-level administrative access to host resources, disk devices, and secret backends (OpenBao). Kubernetes manifests require cluster-scoped or namespace-scoped permissions. Separation prevents the accidental exposure or misuse of high-level credentials during routine application deployment.
* **Blast Radius Mitigation:** Isolating the provisioning logic ensures that modifications or accidental deletions within the Kubernetes manifest directory do not impact the underlying infrastructure state or trigger unintended hardware reconfigurations.
* **Conceptual Clarity:** A top-level directory establishes a clear hierarchy, identifying Tofu as the "Parent" process that provides the environment for the "Child" process (Kubernetes).

## Consequences
* **Path Refactoring:** Existing paths in CI/CD pipelines, Flux kustomizations, or local scripts must be updated to point to the new `tofu/` directory.
* **State Management:** Tofu state files remain independent of Kubernetes GitOps operations, reducing the risk of state corruption.
* **Improved Scalability:** The repository follows the industry standard of separating "Provisioning" from "Configuration," making it easier to manage as more nodes or services are added.
