# Roadmap: Automated Application Environment Isolation

## 1. Status
**Backlog / Proposed** 

## 2. Context & Problem Statement
The current setup relies on a `ClusterSecretStore` for Secret Management. While this minimizes friction during the early stages of the lab, it introduces a **Single Point of Failure**:
* **Shared Identity:** Every namespace utilizes the same `external-secrets` ServiceAccount.
* **Blast Radius:** A compromise of the ESO ServiceAccount provides potential access to all OpenBao paths permitted by the shared role.
* **Auditability:** Vault logs show a single identity for all secret requests, making it difficult to trace access back to a specific application.

## 3. Proposed Solution: The `app_environment` Tofu Module
The goal is to develop a reusable OpenTofu module to encapsulate the "Secure-by-Default" namespace lifecycle, effectively automating the isolation process.

### Implementation Logic
The module will automate the following unit of work:
1. **Namespace:** Provisioning of the `v1/Namespace` with required labels.
2. **Identity:** Creation of a dedicated `v1/ServiceAccount` (e.g., `{{app_name}}-eso-sa`).
3. **OpenBao Policy:** Generation of an HCL policy in OpenBao limited to `secret/data/apps/{{app_name}}/*`.
4. **Vault Auth Role:** Mapping the specific K8s ServiceAccount + Namespace to the restricted OpenBao Policy.
5. **SecretStore:** Deployment of a namespaced `SecretStore` that references the dedicated local ServiceAccount.

### Trade-off Analysis
| Feature | ClusterSecretStore (Current) | Automated Isolation (Future) |
| :--- | :--- | :--- |
| **Operational Effort** | Low (Single global manifest) | Medium (Tofu module invocation) |
| **Security Posture** | Shared Blast Radius | Restricted Blast Radius |
| **Audit Granularity** | Low (Shared Role) | High (Per-app logging) |

---

## 4. Future Transition: Crossplane Integration
As the cluster matures, I will evaluate **Crossplane** as a potential replacement or evolution for the Tofu-based "Namespace Factory."

### The Crossplane Advantage
* **Control Loop Logic:** Unlike the imperative nature of Tofu, Crossplane provides a "self-healing" state. If an external resource (like an OpenBao policy) is deleted, the Crossplane controller will restore it automatically.
* **Unified Interface:** Infrastructure can be requested via a single Kubernetes Custom Resource (CRD), removing the need for external CLI-based `tofu apply` commands.
* **State Management:** Shifting the Source of Truth to the Kubernetes ETCD eliminates the management of local or remote `.tfstate` files.

### Decision Triggers for Crossplane
* Migration to a Multi-Node or High-Availability cluster configuration.
* Requirement for a fully "Self-Healing" infrastructure that corrects drift in real-time.

# `app_environment` IaC module example
```terraform
module "cert_manager_env" {
  source           = "../../modules/app_environment"
  app_name         = "cert-manager"
  security_tier    = "infrastructure"
  vault_url        = "http://openbao-active.openbao.svc.cluster.local:8200"
  vault_mount_path = "secret"
}
```
# main.tf example
```terraform
# 1. Create the isolated Namespace
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.app_name
    labels = {
      "managed-by"          = "opentofu"
      "security-tier"       = var.security_tier
      "secret-access/vault" = "enabled" 
    }
  }
}

# 2. Create the dedicated ServiceAccount for ESO
resource "kubernetes_service_account" "eso_sa" {
  metadata {
    name      = "${var.app_name}-eso-sa"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

# 3. Create the OpenBao Policy (Scoped only to this app's path)
resource "vault_policy" "app_policy" {
  name   = "policy-${var.app_name}"
  policy = <<EOT
path "${var.vault_mount_path}/data/${var.app_name}/*" {
  capabilities = ["read"]
}
EOT
}

# 4. Create the Vault Auth Role (The bridge)
resource "vault_kubernetes_auth_backend_role" "app_role" {
  backend                          = "kubernetes"
  role_name                        = "${var.app_name}-role"
  bound_service_account_names      = [kubernetes_service_account.eso_sa.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.this.metadata[0].name]
  token_policies                   = [vault_policy.app_policy.name]
  token_ttl                        = 3600
}

# 5. Create the Namespaced SecretStore (The "Local Manual")
resource "kubernetes_manifest" "secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "openbao-store"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    spec = {
      provider = {
        vault = {
          server  = var.vault_url
          path    = var.vault_mount_path
          version = "v2"
          auth = {
            kubernetes = {
              mountPath = "kubernetes"
              role      = vault_kubernetes_auth_backend_role.app_role.role_name
              serviceAccountRef = {
                name = kubernetes_service_account.eso_sa.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}
```
