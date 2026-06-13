# labels & naming conventions 

# alerting stack 
## pending CRDs manifests
- `vmauth`: This is an Application Proxy.
  It lives behind your Gateway. You use it only if you want to say: "User A can only read metrics from Namespace X, but User B can read everything." 
  - **Decision**: Stick with Gateway API + Cilium. Only add `vmauth `if you need complex, user-based permission logic inside the metrics app itself.
- `vmgateway`: This is for **Multi-tenancy**.
  - If you aren't selling "Metrics-as-a-Service" to other people, you do not need this.
## `VMAlertmanager`
- cluster-scoped resource
- it will act as **the central notification hub** for the "Athanor" cluster.
  - As long as the `VMAlert` instances are pointed at it, it will handle the routing, deduplication, and silencing for everything.
    - Therefore it does not care if an alert comes from `node-exporter`, `postgres`, or a `mise-task` in that sense.
### binary configuration file 
- `alertmanager.yaml`: This is the internal configuration used by the actual Alertmanager binary.
  - The `Operator` takes the logic I wrote in `configRawYaml` and automatically generates a `Secret` containing a file named `alertmanager.yaml`, then mounts it into the Pod for me.
  - **is that `Secret` an standard K8s secret? YES**:
    - technical plumbing: the Operator creates a standard Kubernetes Secret object (type `Opaque`).
      - The Secret itself is named after the CRD (e.g., vmalertmanager-athanor-alertmanager-config), but the **Data Key** inside that Secret is named `alertmanager.yaml`.
        - vm docs: "Generated config stored at Secret created by the operator, it has the following name template vmalertmanager-CRD_NAME-config."
    - The Operator then tells the StatefulSet to **mount that secret as a volume (volume mounting).** 
      - Mount Path: Usually ``/etc/alertmanager/config/``
      - Resulting File: `/etc/alertmanager/config/alertmanager.yaml`
## configuration fields (cheatsheet)
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
# receivers 
- FOSS tools & possible future deployments:
  - [gotify](https://github.com/gotify/server)
  - [ntfy](https://github.com/binwiederhier/ntfy)
