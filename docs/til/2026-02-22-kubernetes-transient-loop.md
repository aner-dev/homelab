# Post-Mortem & Learnings: GitOps Deadlock & The Kubernetes Control Loop

**Date:** 2026-02-22
**Context:** Bootstrapping FluxCD to a feature branch (`feat/blocky-dns`) on my homelab cluster using Codeberg.
**Architecture Context:** `base-production-staging` directory structure.

## 1. Incident Overview (The Symptoms)
While executing a `flux bootstrap git` command to point my cluster to my Codeberg repository, the process hung indefinitely at the `► cloning branch...` phase. It eventually timed out with the following error:

> `gitrepository 'flux-system/flux-system' not ready: '...dial tcp: lookup codeberg.org on 10.43.0.10:53: server misbehaving'`

Initially, this looked like a Git authentication issue, but injecting credentials directly into the URL (a standard CI/CD bypass technique) did not resolve it. The true failure was deeper in the cluster's networking stack.

## 2. Root Cause Analysis: The Circular Dependency
The core issue was a classic infrastructure deadlock:
1. **Flux** needed to reach the internet (Codeberg) to download my manifests.
2. To resolve `codeberg.org`, Flux queried **CoreDNS** (the internal cluster DNS at `10.43.0.10`).
3. CoreDNS was configured (via K3s defaults) to forward external queries to the host machine's `/etc/resolv.conf`.
4. Because I was in the middle of migrating my network to **Blocky DNS**, the host's upstream DNS was either broken or pointing to a Blocky instance that had not been fully deployed yet.

**The result:** Flux couldn't deploy Blocky because it had no DNS, and the cluster had no external DNS because Flux hadn't deployed Blocky.
