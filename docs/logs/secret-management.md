# terraform providers 
the `provider` is a **separate binary process* 
## issue: missing provider
`❯ tofu plan -out=prod.tfplan
╷
│ Error: Inconsistent dependency lock file
│
│ The following dependency selections recorded in the lock file are inconsistent with the current configuration:
│   - provider registry.opentofu.org/hashicorp/kubernetes: required by this configuration but no version is selected
│   - provider registry.opentofu.org/hashicorp/vault: required by this configuration but no version is selected
│
│ To make the initial dependency selections that will initialize the dependency lock file, run:
│   tofu init
`
## error: 
I've missing the dependencies because I was doing a `tofu plan` after declaring a new `provider` but before doing a `tofu init`; command that were installed the new provider declared, the binary. 
## solution & learning:
`tofu init` to ensure the installation of all the declared dependencies. 
### extra:
`ls -R .terraform/providers`: util command to have a fast lookup of the binaries installed 
## issue: Zombie Provider (kubernetes-terraform-provider)
📝 Description
A "Zombie Provider" occurs when the OpenTofu/Terraform engine has the provider binary available on disk (after a tofu init), but the code lacks an explicit provider configuration block.
The binary is "alive" but "brainless"—it knows how to talk to Kubernetes, but it doesn't know where your cluster is.
### 🔍 SymptomsError Message
(post configmaps) or (get namespaces) followed by a connection failure.
Default Behavior: The provider falls back to http://localhost:8080 (the hardcoded default).
,onfusion: The user sees the binary in ,terraform/providers/ and wonders why it isn't working.

### Reasoning
Discovery vs. Configuration: tofu init only handles Discovery (downloading the binary).
The provider "kubernetes" {} block handles Configuration (providing the "map and flashlight").
### Implicit vs. Explicit
Relying on implicit providers is dangerous in production.
Always explicitly define the provider and its config_path or config_context.
###  The FixDefine Identity
Add the provider to the required_providers block in versions.tf.
Provide the Map: Create an explicit provider "kubernetes" {} block.
Point to the Cluster: Set config_path = "~/.kube/config" and config_context = "your-context-name".
Key Takeaway
Binary != Configuration. Just because the driver is installed doesn't mean the car knows where to drive. In production, never let Tofu "guess" your cluster location.

# FluxCD 

## FluxCD cluster-scoped customizations
**Flux operates with Cluster-Admin privileges by default.**
Creates a `kind: Kustomization` object in my `artix-home` dir is actually performing a **Cluster-Level Configuration**. 
- This is why it is the perfect tool for "Cluster-level" tasks:
   1. ClusterSecretStore: This is a cluster-scoped object (it works across all namespaces). Flux is perfect for deploying this.
   2. CRDs: Installing the "Definitions" that the whole cluster uses.
   3. RBAC: Setting up the permissions for everyone in the cluster.

## FluxCD & Kustomization APIs
apiVersion: kustomize.config.k8s.io <- native 
  - A standalone CLI tool (often used via kubectl kustomize).
  - The Job: It handles client-side templating.
    - It patches YAMLs, adds common labels, and combines multiple files into one big stream.
  - Limitations: It is "dumb."
    - It doesn't know about the cluster state. It can't "wait" for a ConfigMap or "inject" a value from a live secret.
- apiVersion: kustomize.toolkit.fluxcd.io <- 
  - fluxcd CRD created by the flux team 
  - The Job: It handles server-side orchestration.
    - It is the "engine" inside your cluster that says: "Go fetch that Git repo, run the native Kustomize on it, and then apply it to the cluster."
  - Power: Because it is a *Flux-specific controller*, it has extra features that native Kustomize doesn't have, like postBuild substitution, dependsOn logic, and health checking.
### both are API groups 
### how they work together in my homelab
Native Kustomize (k8s.io) is the Blueprint. It describes what the house should look like.

Flux Kustomize (fluxcd.io) is the Construction Manager. He reads the blueprint, but he also knows how to hire the plumber (ESO) and make sure the electricity (ConfigMap) is connected before the walls are finished.

# issue: secret injection (eso-vault-flux-tofu)
# Solution: FluxCD variable substitution
