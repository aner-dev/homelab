# `kind: CiliumClusterwideNetworkPolicy` errors & refactor 
`CiliumClusterwideNetworkPolicy` (CCNP) only for **universal truths** (DNS, K8s API, Health).
`CiliumNetworkPolicy` (CNP) for **functional relationships** (App -> DB).
# refactor
## What stays in the Cluster-Wide Policy?
- DNS (CoreDNS/Blocky): Every pod needs to resolve names to function.
 
- K8s API: Every pod needs to talk to the "brain" of the cluster.
 
- Health: System checks.

## What moves to the App-Specific Policy?
- Database (Postgres): Only the app owner needs this.
 
- Cache (Redis): Only the app owner needs this.
 
- Metrics (Prometheus): Only the scraper needs to reach the pods.
 
- Traefik: Only the apps being exposed need to receive traffic from Traefik.

