
|**Domain**|**What it handles**|**Examples in configs/**|
|---|---|---|
|**Security / Auth** (Missing)|Trust, Certificates, and Access.|`ClusterIssuer` (cert-manager), `SecretStore` (External Secrets), Global `RoleBindings`.|
|**Storage**|Persistence and Backups.|`StorageClass` (Longhorn default), Backup targets.|
|**Networking**|Traffic flow and Encryption.|`GatewayClass`, Gateway Listeners, WireGuard parameters.|
|**Observability**|Telemetry and Alerting.|`global-scrape.yaml`, Alertmanager routing rules.|
|**Compute** (Optional)|Resource management.|`LimitRange`, `PriorityClass` (deciding which pods get evicted first).|

