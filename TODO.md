# bash scripts 
- all the `<app>/base/kustomization.yaml` manifests should have the `recommended labels`
- create a bash scripts that searches for those manifests, reads them & if they do not have the labels the script will write them and even create the file itself
  - **creative name:** a `kustomization.yaml` 'template generator' if you will
## mise tasks `cluster:helm-audit`
- [ ] make it agnostic & idempotent
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

