# Level A: The Global Baseline (CCNP)
Where: `infrastructure/controllers/cilium/production/network-policies/`

What: the current global-zero-trust-baseline.

Why: This is the "Safety Net." It applies to every pod in the cluster, regardless of namespace.

# Level B: Infrastructure Component Protection (CNP)
Where: Inside each infra controller's folder (e.g., `infrastructure/controllers/traefik/base/network-policy.yaml`).

What: Rules that allow Prometheus to scrape Traefik, or Traefik to talk to its own dashboard.

Improvement: Move policies for Blocky out of the baseline and into `./infrastructure/ingress/blocky/base/network-policies.yaml.`

# Level C: Application Isolation (CNP)
Where: apps/<app-name>/base/

What: Functional relationships (e.g., linkding → postgresql).

Improvement: My linkding-cnp.yaml is perfectly placed. It keeps the "Business Logic" of the networking within the app's own lifecycle.
