# 1. Enable the KV (Key-Value) Secret Engine version 2
# This creates the "Folders" where your passwords will live.
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  description = "Main secret storage for applications"
}

# 2. Define the Policy
# This is the "Rulebook" that says: "You can only read secrets."
resource "vault_policy" "external_secrets" {
  name   = "external-secrets-policy"
  policy = <<EOT
path "${vault_mount.kvv2.path}/data/*" {
  capabilities = ["read"]
}
EOT
}

# 3. Enable Kubernetes Auth Method
# This tells Vault: "Trust my Kubernetes cluster to verify identities."
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

# 4. Create the Role (The Bridge)
# This connects a specific K8s ServiceAccount to the Policy.
resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets-role"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = [var.eso_namespace]
  token_policies                   = [vault_policy.external_secrets.name]
  token_ttl                        = 3600
}

# 5. Configure the Backend (The System Handshake)
# This allows Vault to verify the ServiceAccount tokens with the K8s API.
resource "vault_kubernetes_auth_backend_config" "main" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc"
  disable_iss_validation = true
}

resource "kubernetes_config_map_v1" "vault_bridge" {
  metadata {
    name      = "vault-bridge-config"
    namespace = var.eso_namespace
  }

  data = {
    vault_url  = var.vault_url
    vault_role = vault_kubernetes_auth_backend_role.external_secrets.role_name
    auth_path  = vault_auth_backend.kubernetes.path
  }
}
