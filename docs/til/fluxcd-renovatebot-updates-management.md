- flux never opens Pull Requests (PRs)
  - Flux is a "Pull" tool; it pulls from Git to the Cluster.
  - It doesn't have the permissions (usually) or the logic to write back to your Git repo.
# trade-off 
- so the 'minor wildcard' trade-off would be having a smooth update workflow of minor patches, but a slightly (or not to slithgly, you need to say that to me) probability of getting my network broak without knowing that that minor update was the responsable, or at least doesn't have that update tracked in git.
# ADR from minor wildcard to pinned renovate updates:
