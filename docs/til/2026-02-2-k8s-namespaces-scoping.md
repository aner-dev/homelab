# TIL: Kubernetes Namespaces & Resource Scoping

## 1. The Issue: "The Ghost Resource"
I applied a manifest successfully (`externalsecret.external-secrets.io/vault-smoketest created`), but when I ran `kubectl get`, the resource was nowhere to be found (`Error from server (NotFound)`).

## 2. The Learning: Namespaces as Isolation
Most Kubernetes resources are **Namespaced**. If you are "standing" in one namespace, you cannot see resources in another unless you explicitly look there.

### Key Commands:
* **Check current namespace:** `kubens` (if using the tool) or `kubectl config view --minify | grep namespace`.
* **Look into a specific room:** `kubectl get <resource> -n <namespace>`.
* **Look everywhere:** `kubectl get <resource> -A` (or `--all-namespaces`).

## 3. Scoping: Namespaced vs. Cluster-Scoped
Not all resources live inside namespaces.
* **Namespaced:** Secrets, Pods, Deployments, ConfigMaps, ExternalSecrets.
* **Cluster-Scoped:** ClusterSecretStore, Nodes, Namespaces, PersistentVolumes (PV).

> **Rule of Thumb:** If the resource name starts with "Cluster" (like `ClusterSecretStore`), it is visible to everyone, everywhere.

## 4. The "Handshake" Debugging Flow
When linking Vault and Kubernetes via External Secrets:
1. **Vault Engine:** Enable KV-v2.
2. **K8s Auth:** Enable the auth method in Vault.
3. **Vault Config:** (The missing piece) Tell Vault how to talk to the K8s API (`vault_kubernetes_auth_backend_config`).
4. **ESO Bridge:** Create the `ClusterSecretStore` to link them.
5. **Validation:** Check status with `kubectl get clustersecretstore`.

## 5. Metadata vs. Context
Even if your local terminal context is set to `external-secrets`, if your YAML file says `namespace: default`, the resource will be created in **default**.
