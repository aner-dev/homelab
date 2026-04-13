# vmagent.yaml
## concepts
|**Process Step**|**Action by the Operator**|**Audit Question**|
|---|---|---|
|**Discovery**|Checks for `VMServiceScrape` objects across the cluster.|Does the Agent have the RBAC permissions to see other namespaces?|
|**Filtering**|Applies your `Selectors` (e.g., `selectAllByDefault`).|Am I accidentally scraping system pods I don't need?|
|**Generation**|Updates a `Secret` prefixed with `vmagent-athanor-agent`.|Did the configuration reload successfully after my last change?|
|**Execution**|Mounts that secret into the `VMAgent` pod and starts scraping.|Is the Agent OOMKilled (Out of Memory) because of too many targets?|
## cheatsheet
|**Field**|**Purpose**|**Best Practices**|
|---|---|---|
|**`remoteWrite`**|Data Export|Always use the internal Kube-DNS cluster URL for latency and security.|
|**`replicaCount`**|Availability|In a single-node Ryzen setup, `1` is optimal. Avoid `2+` to prevent duplicate metric scraping.|
|**`resources`**|Stability|`VMAgent` memory usage scales with the number of **targets**. Monitor its RAM usage closely.|
|**`RBAC`**|Permissions|Use the default created by the Operator unless you need strict security boundaries.|

# scrapes 
## scrape target hierarchy 
|**Kind**|**Relevancy**|**Senior Use Case**|
|---|---|---|
|**`VMServiceScrape`**|**Critical**|The standard. Use this for 95% of your apps (Forgejo, Gitea, Exporters). It targets the Service and follows the endpoints.|
|**`VMPodScrape`**|**Low**|Use only for "headless" apps or pods that exist without a Service (rare in a clean architecture).|
|**`VMNodeScrape`**|**Medium**|Specific to host-level metrics. The Operator usually handles this to get `node-exporter` data.|
|**`VMStaticScrape`**|**Low**|Use for targets **outside** your cluster (e.g., monitoring your Ryzen host's temperature from a script).|
|**`VMProbe`**|**Medium**|Used for "Blackbox" monitoring. Checking if a website is up (`200 OK`) rather than reading internal metrics.|
|**`VMScrapeConfig`**|**High**|The "Escape Hatch." Use this when you need complex Prometheus relabeling rules that the standard CRDs don't support.|
## `VMScrapeConfig` relevance 
- While VMServiceScrape is easy and declarative, VMScrapeConfig allows me to write raw Prometheus-style scrape configurations.
- I will likely need this only if you are integrating a legacy application or a tool that requires very specific Relabeling Configurations (changing label names on the fly before they hit the DB).
