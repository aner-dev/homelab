# observability
- [ ] alerting stack (cluster-scoped) (`VMAlertmanager, VMAlert, VMRule` manifests)
  - [ ] auth & access (`VMAuth, VMUser` manifests)
  - [ ] probing (`VMProbe` manifests)
- [ ] **CI integration**: integrate `mise-tasks` with victoriametrics (`pushgateway` logic, short-lived jobs)
  - future: integrate the `centralized CI workflow in mise` with victoriametrics & observability
    - `stevearc/overseer.nvim` "A task runner and job management plugin for Neovim"
# labels selectors 
- [ ] refactor `CiliumClusterWideNetworkPolicy` manifest with `set-based` **label selectors** (`matchExpressions` field)
- I've been using just `equally-based` type (`matchLabels`)

