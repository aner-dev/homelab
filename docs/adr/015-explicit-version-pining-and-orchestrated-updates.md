# ADR-005: Transition to Explicit Version Pinning and Orchestrated Updates

## Status
Proposed

## Context
Our current FluxCD configuration utilizes Semantic Versioning (SemVer) wildcards (e.g., `1.19.*`) for Helm chart reconciliations. While this provides high update velocity with minimal manual intervention, it introduces several "Senior-level" risks:
- **Opaque Updates:** Version changes occur "in-place" without a corresponding Git commit, creating "Ghost Updates."
- **Debugging Friction:** Troubleshooting cluster degradation becomes difficult when the underlying binary has changed without an audit trail.
- **CRD Desynchronization:** Our automated CRD harvest logic (via Mise) requires a known version to ensure the local manifests match the running cluster state.

## Decision
We will migrate all `HelmRelease` manifests from wildcard ranges to **explicitly pinned versions**. 

The update lifecycle will be managed as follows:
1. **Renovate Bot** will track upstream OCI registries and Helm repositories.
2. Renovate will open **Pull Requests** for all version increments (Patch and Minor).
3. **Patch Updates** will be configured for automated merging (Automerge) if basic linting passes.
4. **Minor/Major Updates** will require manual review and the execution of the `sync-crds` Mise task.

## Consequences
- **Positive:** Full audit trail in Git history for every version change.
- **Positive:** Simplified rollbacks via standard Git `revert` operations.
- **Positive:** Elimination of "Ghost Updates" and opaque version drift.
- **Negative:** Increased volume of Pull Requests (mitigated by Renovate's grouping and automerge features).
- **Negative:** Requires a running instance of Renovate (Self-hosted or GitHub App).

## Comparison Table

| Feature | Wildcard Strategy (`1.19.*`) | Pinned + Renovate Strategy (`1.19.2`) |
| :--- | :--- | :--- |
| **Visibility** | **Opaque.** Changes are invisible in Git. | **Transparent.** Every change has a PR. |
| **Control** | **Passive.** Update happens when Flux runs. | **Active.** Update happens when you merge. |
| **Rollback** | **Complex.** Requires manual manifest edits. | **Trivial.** Standard Git Revert. |
| **Stability** | **Risky.** Potential for untested breakages. | **High.** Updates are gated and intentional. |
