# concepts 
## A. The Client Name Lookup 
In Kubernetes, IPs are like temporary phone numbers. If a Pod restarts, it gets a new one.
`clientLookup` is the mechanism that allows Blocky to ask: "I see IP 10.42.0.50—who is this actually?"

- rDNS (Reverse DNS) Trick: Blocky sends a "PTR" query to an upstream (like CoreDNS) asking for the name associated with that IP.

- Mapping: Once Blocky knows the name is searxng-xxxx, it can apply specific rules.

## B. Conditional DNS 
**routing** based on the destination.

Logic: "If the user is looking for *.cluster.local, don't go to the internet. Go to CoreDNS."

"Fallback" Upstream: If when looking for `grafana.athanor.local` it’s not in `customDNS`, `fallbackUpstream: true` would allow Blocky to try the internet (though it will fail), while `false` stops the leak immediately.

## C. Upstream Groups 
This is where I can decide who gets what privacy level.
Now that I have the "Identity" (from `clientLookup`), I can assign it to a "Policy", meaning **an upstream group**.
# code: `upstream.groups:"<app>*"` formula 
- It matches the starting string.
 
- In Kubernetes, Pod names are generated as [DeploymentName]-[ReplicaSetHash]-[PodHash].
 
- Example: searxng-5f67b67694-abc12
 
- The Blocky pattern searxng* acts as a **prefix match.** 
  - It says: "If the client name starts with 'searxng', regardless of the random hash at the end, apply this group."
 
- Granular Distinction:
by just adding the application name (the prefix) to `upstreams.groups`, I am able to create a dedicated "lane" for that service's traffic.
## cilium identity-based conceptual correlation/connection
- I've found remarkable that this `clientLookup` mechanism correlates with the "identity-based" conceptual approach of cilium regarding Networking Management.
- I see it as a good signal both in my understanding about its simplicity and effectiveness while also follow analogous procedures of a such remarkable project as cilium is. 


# bootstrap DNS (the "chicken-and-egg" resolver / the bootstrap paradox)
- When I tell Blocky to use `https://dns.mullvad.net/dns-query`, Blocky first needs to know the IP address of `dns.mullvad.net`.
- **But Blocky is the DNS server.** If it doesn't know the IP yet, it can't connect to the encrypted service. 
  - This is the Bootstrap Paradox.
## Global/Cloud Implications:

- Production: In a cloud environment, if your external DNS provider (like Mullvad) changes their IP and you have hard-coded it in your main upstreams, your cluster goes dark.

- Security: Bootstrapping via `1.1.1.1` or `8.8.8.8` (Plain DNS) is the industry standard to "kickstart" the encrypted tunnel.
# filtering: protocol optimization
- **Filtering types of DNS queries**
  - DNS can ask for many record types (A for IPv4, AAAA for IPv6, MX for mail).
  - Filtering allows you to explicitly drop queries you don't want to support.
## Global/Cloud Implications:

- The IPv6 Latency Issue: Many applications (including those in K8s) try to resolve IPv6 (AAAA) first.
  - **Timeout:** If your network or your ISP doesn't support IPv6 properly, the app waits for a timeout before falling back to IPv4.
  - **Latency:** This adds milliseconds of latency to every single connection.

- Production: In an IPv4-only cluster (like many homelabs), filtering AAAA queries makes the network feel "snappier" because Blocky immediately tells the app "IPv6 doesn't exist here," forcing an instant IPv4 connection.
## Application in config.yaml:
```yaml
filtering:
  queryTypes:
    # This configuration will drop all 'AAAA' (IPv6) queries.
    - AAAA # Drop IPv6 queries to eliminate "dual-stack" wait times in an IPv4 homelab
```
- I can define *one or more DNS query types*, all queries with these types will be dropped (empty answer will be returned).
# FQDN only (strict identity)
- A Fully Qualified Domain Name (FQDN) ends with a dot or has a complete structure (e.g., google.com.). An "unqualified" name is just my-server.
 
## Global/Cloud Implications:
 
- Security: In a production environment, **unqualified names are dangerous.**
  - If a user types internal-api, and a malicious actor creates a domain named internal-api in a different search suffix, the traffic could be hijacked.
 
- Performance: It stops "DNS search path" spam.
  - When I type `google.com`, the OS might try google.com.athanor.local first. `fqdnOnly` **kills this noise.**
 
- > [!WARNING]
> Warning: In a K8s homelab, this can be dangerous. K8s relies heavily on short names (e.g., service-name instead of service-name.namespace.svc.cluster.local).
# Application in config.yaml:

- Decision: I'll Keep this disabled (false) for now.
  - Enabling it in a K8s cluster will likely break the internal service discovery unless I am extremely disciplined with my YAML manifests.
```yaml
fqdnOnly:
  enabled: false
```
> [!NOTE]
> - In domain environments, it may be useful to only respond to FQDN requests. If this option is enabled blocky will respond immediately with NXDOMAIN if the request is not a valid FQDN. The request is therefore not processed further by other options like custom or conditional.
> [!WARNING]
> Please be aware that by enabling this your resolution will break unless every query is for a fully qualified domain name.
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


# concepts 
## DNS metadata leakage 
- how `customDNS` prevents **DNS metadata leakage??** 
- In a production environment, customDNS is used to ensure that internal services are never reachable (or even visible) from the public internet.

- Isolation: By defining `git.athanor.local` in `customDNS`, only clients inside the network can find the IP (internal: LAN + Cluster).
  - To the outside world, **that domain doesn't exist.**

- Security (No Leaks): Because Blocky holds the answer locally in its memory, it never has to ask an "Upstream" (like Google or Mullvad) for the IP.
  - **This is how it prevents DNS Metadata Leakage.**
# LAN vs cluster homelab's network: Key Differences
- **personal synthesis**:
  - both (LAN & k8s cluster network/homelab) coexist within a *shared ecosystem* because one is nested into the other. 
  - At using k8s for a homelab, my LAN now is *holding a virtual network*, that can be configured to interact with my LAN in external networking interactions. 
- AI enrichment:
> [!NOTE]
  > To refine it for a professional discussion, you are describing a Virtual Overlay Network (Kubernetes/Cilium) running on top of a Physical Underlay Network (your LAN/Artix Host).
- **interview explanation:**
  - "My Kubernetes cluster implements a Virtual Overlay (Cilium) that is nested within my Physical LAN. While the Pod network is isolated by default, I use Cilium's ingress and load-balancing capabilities to bridge specific services into my LAN's address space for external interaction."
## markdown table
    > 
|**Feature**|**LAN (Physical/Host)**|**Cluster (Virtual/Cilium)**|
|---|---|---|
|**Visibility**|Your router sees these IPs.|Your router **cannot** see these IPs directly.|
|**Lifespan**|Long-lived (Static or DHCP lease).|Ephemeral (Pods die and get new IPs).|
|**Management**|Router / Artix NetworkManager.|Kubernetes / Cilium CNI.|
|**Addressing**|`192.168.x.x`|`10.42.x.x`|

# how they interacte (cilium is the bridge)
- When you use Cilium as a LoadBalancer, you are essentially telling Cilium:
  - "Take this IP from my LAN (e.g., 192.168.1.192) and map it to a Service in my Cluster."

- This is why your customDNS mapping athanor.local: 192.168.1.192 works (`blocky/config.yaml`.)
  - Your browser (on the LAN) asks for `athanor.local`, gets a LAN IP, and then Cilium "sucks" that traffic into the Cluster.


# query logging 
- While a DNS server’s primary job is to find addresses, query logging is the process of writing down every single question asked and every answer given.

- In a professional environment, you don't just want the network to work; you want to know exactly how it is being used.
  - it is essentially the "Black Box Flight Recorder" of a network.

## 1. Why does Query Logging exist? (The "Why")
- There are 3 primary pillars that justify the existence of query logging:

1. Security & Threat Hunting: Modern malware and ransomware often use DNS to "call home" to a Command & Control (C2) server. By looking at logs, security teams can see if a machine is trying to talk to a known malicious domain.

2. Troubleshooting & Debugging: When an application says "Connection Refused," the problem is often that the DNS resolved to the wrong IP or didn't resolve at all. Logs allow you to see the exact millisecond a request failed and why.

3. Audit & Compliance: In regulated industries (finance, healthcare), organizations are legally required to keep a record of network activity. This creates an "audit trail" if a data breach occurs.

2. Where is it used? (markdown table)

|**Environment**|**Use Case**|**Implementation**|
|---|---|---|
|**Enterprise SOC**|Detecting data exfiltration.|High-speed databases (Elasticsearch, Splunk).|
|**ISP / Carrier**|Legal mandates and traffic shaping.|Massive, high-throughput distributed logs.|
|**Home/Lab**|Monitoring ad-blocking and privacy.|Simple CSV files or local databases (MariaDB).|
|**Cloud (AWS/GCP)**|VPC Flow Logs and DNS Firewall.|Managed services like CloudWatch.|
## theoretical/learning relevance
If you are learning to manage a network, there are three critical trade-offs you must understand:

### A. The Privacy Paradox
DNS logs are a map of a person's digital life. Every website visited, every app opened, and every smart device heartbeat is recorded.

The Senior Take: "Anonymize at the source if possible." If you don't need the clientIP to solve a problem, don't log it.

### B. The Storage Impact
DNS traffic is incredibly chatty. A single busy server can generate millions of queries a day.

Standard text/CSV logs grow exponentially and can fill up a hard drive quickly.

Databases offer better searching but require more CPU and RAM to manage the "write" operations.

### C. Performance Overhead
Writing to a disk is slower than reading from RAM. If a DNS server has to wait for a database to "confirm" a log was written before it answers the client, it adds latency.

Asynchronous Logging: Most modern tools (like Blocky) use a "buffer." They answer the user immediately and write the log to the disk/database a few seconds later in a "bulk" batch.
# security 
## traffic inspection workflow (markdown table)

|**Phase**|**Tool**|**Action**|**Expected Result**|
|---|---|---|---|
|**1. Intent**|**Neovim**|Define `upstreams` as DoH (`https://`).|No "plain" DNS destinations.|
|**2. Generation**|**Browser/Curl**|Visit a new domain (e.g., `codeberg.org`).|Traffic is triggered.|
|**3. Internal Audit**|**`kubectl logs`**|Check Blocky `queryLog` (Console).|See the query and the "Privacy" group.|
|**4. Wire Audit**|**`tcpdump`**|Monitor `eth0` on port 53.|**Total Silence** (No packets detected).|
|**5. Verification**|**`tcpdump`**|Monitor `eth0` on port 443 (HTTPS).|Encrypted "noise" going to Mullvad/LibreDNS.|
