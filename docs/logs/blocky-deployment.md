# 3 binary sources 
- docker hub image 
- github releases 
- truecharts 
- The Docker Hub Image (spx01/blocky): This is a Community/Personal build.
  - It might be outdated or contain unverified changes.
- The GitHub Releases/GHCR: This is the Official Upstream.
  - It is the "purest" form of the software, maintained by the actual authors (0xERR0R).
- The Helm Chart (TrueCharts): This is a Third-Party Wrapper.
  - TrueCharts is a massive project, but they often "Opinionatedly" change how things work to fit their specific ecosystem.
## reasoning: upstream proximity and dependency hierarchy
The closer you are to the original source code, the more control you have. The further away you are, the more you rely on someone else's choices.
## The Decision: Use the Official GitHub Container Registry (GHCR) image: ghcr.io/0xerr0r/blocky
Why? It is published directly by the developers of Blocky. It is the gold standard for "Production/" layer. 

# vendor management 
- issue & doubt: should I harcode the default `config.yaml` of blocky in `base/` directory? Or just including it as another resource in the `base/kustomization.yaml`? Like I did in the `cnpg` operator deployment? 
- reasoning:
- previous parameters I've thought: the **file length** of the file will define that decision; because cnpg-operator manifest was 10 thousand lines of code large. 
- correction & learning: the **customization needs** is a *valid parameter* to take in account for the decision making of hardcoding or not the yaml manifest. 
  - Not simply think about the **file lenght**; although it is often related with the "customizability/configurability level"  of the yaml manifest. It is a consequence, not a cause. 
- `blocky/base/config.yaml`: A highly demand of customization and personal configuration file. 
  - meaning: it should have a dedicated .yaml file in `base/` 
# operator manifests 
- question: the cnpg-operator manifest has 10 thousand lines of code in average, would be that **file lenght** a pattern in operator yaml manifests? 
- answer: Yes, that 'Operator Pattern' is a fundamental pillar of modern Kubernetes.
- They're always 10k lines? Often, yes. 
  - Operators like CNPG, Longhorn, Prometheus-Operator, or Istio are massive because they aren't just one app—they are a collection of:
    - CRDs (Custom Resource Definitions): Teaching K8s new "words" like Cluster or Backup.
    - RBAC: Detailed permissions for the operator to watch the cluster.
    - Deployments: The actual "brain" (the controller) that runs the loop.
- in kubernetes the *operator* is treated like a *system library*  
### "Don't Fork what you can Vendor." (AI enrichment)
- If you copy-paste those 10,000 lines into your repo, you have "Forked" it. Now you are responsible for fixing bugs in those 10,000 lines. That is a maintenance nightmare.
- If you point to the URL, you are "Vendoring" it. You trust the maintainers to fix the bugs, and you just bump the version tag when you're ready.
- 
- 
# config.yaml
- 1. upstreams (connectivity)
- 2. custom DNS (shows how the DNS connects to the cluster nodes)
- 3. blocking (ad-block logic)
- 4. caching (performance)
- 5. ports & logging (observability)
# k8s architecture and backend logic
- 
# `config.yaml`
## decisions and reasoning
### SubPath vs. Directory decision
SubPath (the initial setup): Mounts a single file.
Problem: If you update the ConfigMap in the API, the file inside the Pod never updates until you restart the Pod.

Directory Mount (the better option): Mounts the whole folder.
Benefit: Kubernetes can "Hot Reload" the file. When you change your DNS rules, Blocky sees the update in seconds without dropping a single packet.
# Why a DNS applications needs a volume logic? If it's nature is to be a stateless 
- ConfigMap
- In order to deliver all the configuration manifest across all the containers within all the pods, I've decided to implement a `ConfigMap`
- I've encountered with the need to create a `volumeMounts` in order to have a reliable 'delivery' of my configuration specification/manifest. 
## avoiding use `subPath` 
- **symlink rotation** executed by k8s, specifically by the **kubelet** 
  - based in directories, subPath because its nature of being a file 
- because I'm not using another file within `/app/config`, mounting the whole directory will the optimal option to implement. 
### subPath trade-offs
- sacrify that **hot reload capability** 
- 


# Log Entry: Refactoring Vault Role Naming Convention
Context & Implementation
During the initial setup of the Blocky secret pipeline, I identified a significant naming mismatch between the Tofu-provisioned Vault roles and the Kubernetes ServiceAccounts.
Initially, the logic relied on complex string interpolation that appended environment suffixes (e.g., -production, -staging) to the Role IDs.
# Problem detection & reasoning
I concluded this approach was over-engineered and fragile; it forced unnecessary changes in the Kustomize overlays and broke the "Build Once, Deploy Anywhere" principle.
# Fix & implementation
To resolve this, I decoupled the App Identity from its environment context.
I refactored the base/main.tf logic to a 1:1 mapping (App Name = Role Name), ensuring that blocky always authenticates as blocky-role regardless of the cluster, while using metadata-driven policies to handle environment-specific secret paths.

# future improvements in tofu / infrastructure as code 
Variable DRYness & Orchestration

Current State: Utilizing terraform.tfvars within environment overlays (production/, staging/). This requires a "pass-through" variable declaration in the overlay's variables.tf, creating minor boilerplate redundancy.
## The Role of .tfvars as SSOT (Source of Truth):
In the current architecture, the .tfvars file acts as the Single Source of Truth (SSOT) for all application-specific metadata. By centralizing values—such as namespaces (ns) and target environments (envs)—within this data-only file, we decouple "The Logic" (how a Vault role is built) from "The Data" (which apps need roles). This ensures that adding a new service to the homelab only requires a single-line entry in the .tfvars map, rather than a modification of the underlying Tofu logic.
## future tech stack
Target State: Implement Terragrunt or FluxCD Post-Build Substitution.

Objective: Achieve a "DRY" (Don't Repeat Yourself) architecture where the apps_config schema is defined once in base/ and values are inherited/merged automatically, eliminating the need for redundant variable declarations in overlays.

# issue: Circular Dependency & Infrastructure Deadlock: Flux & Blocky DNS Loop 

During the initial bootstrapping of our cluster's network infrastructure, I encountered a classic "chicken-and-egg" circular dependency between our GitOps controller (FluxCD) and our custom DNS provider (Blocky). 

Because our cluster relies on Blocky to resolve external domains and enforce network policies, the internal CoreDNS was intended to forward upstream requests to it. However, Blocky's deployment manifests and configurations are managed via Infrastructure as Code (IaC) and stored in our Git repository on Codeberg. 



This created a perfect deadlock:
* **Flux** could not resolve `codeberg.org` to fetch the Blocky manifests because the upstream DNS resolver (Blocky) wasn't deployed yet.
* **Blocky** couldn't be deployed because Flux couldn't reach the repository to apply its manifests.

Breaking this loop required an imperative, "break-glass" intervention. By manually editing the live `coredns` ConfigMap in the `kube-system` namespace to temporarily point to a public DNS provider (like `1.1.1.1`), I provided Flux with the necessary external resolution to clone the repository. Once Flux fetched the `feat/blocky-dns` branch, it could finally deploy Blocky, allowing us to eventually revert CoreDNS to use Blocky as the permanent, declarative upstream. 












