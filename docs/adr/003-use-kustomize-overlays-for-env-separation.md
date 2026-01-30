# 3. Use Kustomize Overlays for Environment Separation

## Status
Accepted

## Context
I want to have a layered separation in my deployments without unnecessary duplicating YAML code. 
Thus I need a way to apply different resource limits and secrets to the same base applications.
Add personalized overrides on top of the base templates of deployment 
Use case example: My main node has 32G of RAM, nonetheless if I go for vacations I'll take my laptop with 4G of RAM with me. So I'll need a way to have the same application being deployed on my laptop, but with hardware adaptations. 
This will also require a *testing environment*

## Decision
I'll implement a **Layered Environment Pattern** across the repository (e.g., inside `apps/`, `infrastructure/`, etc.). 

Each main directory will contain:
* **base/**: The "Template" layer. Contains the core manifests (Deployment, Service, Networking) and a `kustomization.yaml` that aggregates them.
* **production/**: The "Live" layer. This directory points to `../base` as a resource and applies patches (e.g., secret values, resource limits, hostnames).
* **staging/**: The "Testing" layer. Follows the same logic as production but for testing purposes.

Example path: `apps/production/linkding/kustomization.yaml` will reference `../../base/linkding`.


## Consequences
* **Positive:** Reduced directory nesting, making navigation faster in the terminal.
* **Positive:** Strict **Environment Parity**; everything in production MUST exist in base first.
* **Positive:** Ready for **FluxCD/GitOps** path targeting.
* **Positive:** My infrastructure will be 'Node/Hardware-Agnostic', allowing me to instantiate my homelab in different devices.
* **Negative:** Requires careful relative path management (`../../base/...`) in the environment-level kustomizations.
