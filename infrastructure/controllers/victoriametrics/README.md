# 2 helm charts: operator & crds
- victoriametrics project had decisioned to dedicate a distinct helm chart for its `CRDs`, separate from the `operator` charts.
  - that's the reason for the `base/helm-release-crds.yaml` manifest.
