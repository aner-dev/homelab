# RBAC Governance & Supply Chain Security

## Executive Summary
This document outlines my methodology for auditing Kubernetes RBAC resources provided by third-party Helm charts. The objective is to prevent "security debt" by ensuring that every external controller operates under the **Principle of Least Privilege**.

## My Initial Reasoning
When I began deploying controllers like Cilium, I questioned the necessity of the `ServiceAccount` and its corresponding `ClusterRole`. My initial hypothesis was that every subject required an "Identity Card" to interact with the K8s API. 

Through iterative exploration, I refined this into a "Key-Value" mental model:
* **AuthN (Key):** The `ServiceAccount` acts as the immutable identity.
* **AuthZ (Value):** The `ClusterRole` defines the granular capabilities (permissions).

By decoupling identity from network exposure, I realized that I could harden my infrastructure by setting `automountServiceAccountToken: false` for workloads that do not require API interaction.

## Conceptual Alignment: "Inspecting RBAC from external providers"
I defined my operational approach as **"Inspecting RBAC from external providers."** While intuitive, this practice aligns with established industry standards:

| My Term | Official DevOps Terminology |
| :--- | :--- |
| Inspecting RBAC from external providers | **Supply Chain Security / Third-Party RBAC Governance** |
| Identity / Key | **Authentication (AuthN)** |
| Capabilities / Value | **Authorization (AuthZ)** |
| Additive Permission Rules | **Atomic RBAC / Principle of Least Privilege** |



## Why Manual Audit is Necessary
External providers often include "default" RBAC configurations designed for maximum compatibility rather than minimum privilege. Relying on these defaults without inspection introduces **Excessive Privilege** risk. My governance baseline requires:
1.  **Rendering:** Generating manifests locally to avoid live-cluster impact.
2.  **Audit:** Searching for high-risk targets.
3.  **Correction:** Applying Kustomize Strategic Merge Patches to remove unnecessary permissions.

### Audit Checklist
| Target | Why it is relevant | Senior Audit Question |
| :--- | :--- | :--- |
| **Wildcards (`*`)** | Total control over a resource or group. | Does this app *really* need `*` on Nodes, or just `get/patch`? |
| **Escalation Verbs** | `escalate`, `bind`, `impersonate`. | Can this ServiceAccount create new permissions for itself? |
| **Sensitive Resources** | `secrets`, `nodes`, `certificates`. | Why is this operator reading my Vault/OpenBao secrets? |

## Audit Toolkit & CLI Reference
To perform these audits efficiently, I utilize the following toolchain:

* **`helm template`**: Renders charts into plain YAML without installing them.
* **`fd`**: Navigates the file structure (configured via `.fdignore`).
* **`rg` (ripgrep)**: Performs contextual discovery to identify sensitive keywords.
    * *Usage:* `rg -A 5 -B 5 "secrets" ./rendered.yaml`
* **`sed`**: Extracts specific code blocks for surgical analysis.
* **`yq`**: The industry-standard tool for parsing YAML structures.
    * *Usage:* `yq eval '.rules' ./rendered.yaml`
