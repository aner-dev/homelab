# auto-unseal is "PRE-API" logic; the Factory is "POST-API"" logic 
# --- 1. CORE CONFIGURATION (Global Handshake & auto-unseal) ---
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "Main secret storage for applications"
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc"
  disable_iss_validation = true
}

# --- 2. THE APP FACTORY LOGIC ---
locals {
  # The 'locals' now only handles DATA TRANSFORMATION, not data definition.
  apps = var.apps_config

  app_list = flatten([
    for name, cfg in local.apps : [
      for env in cfg.envs : {
        id   = env == "base" ? name : "${name}-${env}"
        name = name
        ns   = cfg.ns
        path = "apps/${name}/${env}" # Path pattern: apps/blocky/production
      }
    ]
  ])

  app_map = { for item in local.app_list : item.id => item }
}

# --- 3. DYNAMIC RESOURCE GENERATION ---
resource "vault_policy" "app_policies" {
  for_each = local.app_map

  name   = "${each.key}-policy"
  policy = <<EOT
path "${vault_mount.kvv2.path}/data/${each.value.path}/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "app_roles" {
  for_each = local.app_map

  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "${each.key}-role"
  bound_service_account_names      = ["${each.value.name}-sa"]
  bound_service_account_namespaces = [each.value.ns]
  token_policies                   = [vault_policy.app_policies[each.key].name]
  token_ttl                        = 3600
}

