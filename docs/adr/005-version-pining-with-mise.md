# Status
Accepted

# Context
During the deployment of core infrastructure (specifically the External Secrets Operator), I encountered a toolchain mismatch. My local "system" binaries were too new (Kustomize v5.8.0 and Helm v4.0.5), leading to a regression where Kustomize attempted to use legacy flags (-c) that the new Helm version had removed.

Without a way to lock these versions, the repository is fragile; "Future me" or other contributors would face "it works on my machine" errors depending on their OS updates. I need a way to ensure the environment is deterministic and consistent across all development stages.

# Decision
I will implement Mise (a polyglot tool manager) to enforce specific binary versions at the repository root.

Implementation Details:

A .mise.toml file will be placed in the root of the homelab repository.

We will standardize on N-1 (Stable) versions rather than "Bleeding Edge" to ensure compatibility between wrappers (Kustomize) and binaries (Helm).

Target Versions: * kustomize@5.7.0 (Avoids v5.8.0 namespace regressions).

helm@3.16.4 (LTS stability).

kubectl@1.30.x (Cloud provider parity).

# Consequences
Positive: Determinism. Every kustomize build or kubectl apply will behave identically, regardless of the host OS (Artix, Ubuntu, or macOS).

Positive: Infrastructure-as-Code (IaC) Integrity. The tools used to build the infrastructure are now versioned alongside the code itself.

Positive: Faster Onboarding. If I move this project to a new laptop, mise install restores the entire working environment in seconds.

Negative: Dependency Overhead. Requires mise to be installed on the host machine and the shell to be "activated" to respect the local versions.

Negative: Maintenance. Requires periodic reviews of the .mise.toml to move to newer stable versions once regressions are patched.
