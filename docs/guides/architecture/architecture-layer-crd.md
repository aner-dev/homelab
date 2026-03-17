Level 1 (The Boss): clusters/artix/01-crds.yaml

It doesn't know what a CRD is. It only knows that it has a job: "Find every Kustomization in infrastructure/crds/ and execute them."

Level 2 (The Manager): infrastructure/crds/cilium-crds.yaml

It acts as the manager for the Cilium domain. It looks at its spec.path and says: "My job is to take everything inside infrastructure/crds/cilium/manifests/ and apply it to the cluster."

Level 3 (The Workers): infrastructure/crds/cilium/manifests/*.yaml

These are the actual CRD definitions (the YAMLs). They don't have any GitOps logic; they are just raw data waiting to be applied by Level 2.
