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







