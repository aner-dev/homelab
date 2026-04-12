# `mise-tasks` vs. Kubernetes Job 

Switching from K8s Jobs to `mise-tasks` is a **trade-off between Portability and Orchestration**.

## Cases for `mise-tasks` (Good Decision for "Day 0")

- **Simplicity:** You don't need to worry about `BAO_TOKEN` secrets in K8s or `ttlSecondsAfterFinished`.
    
- **Developer Experience:** Since you use `mise-in-place`, running `mise run bootstrap-pki` is faster than waiting for a Pod to schedule and pull an image.
    
- **Ideal for:** One-time cluster setup or "Cold Starts" where you are sitting at your Artix PC.
    

## The Case for Kubernetes Jobs (The "GitOps" Way)

- **Self-Healing:** If you wipe your cluster and FluxCD re-installs everything, the **Job** will run automatically. `mise` requires you to be there to push the button.
    
- **Lifecycle:** The `pki-bootstrap-job` is part of the "Athanor" infrastructure itself.
    
# conclusion
- **Verdict:** Keep **Infrastructure Initialization** (PKI, Databases, CSI) as **K8s Jobs** so they are managed by Flux.
- Use **`mise-tasks`** for **Local Development** tasks (linting, building linkding images, or manually unsealing OpenBao).

