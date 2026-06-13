1. 2 helm charts: operator & crds
2. victoriametrics project had decisioned to dedicate a distinct helm chart for its `CRDs`, separate from the `operator` charts.
3. - that's the reason for the `base/helm-release-crds.yaml` manifest.
