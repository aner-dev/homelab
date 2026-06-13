resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "Main secret storage for applications"
}

locals {
  apps = var.apps_config
  app_map = { for name, cfg in local.apps : name => {
    name = name
    ns   = cfg.ns
    envs = cfg.envs
    }
  }
}

resource "vault_policy" "app_policies" {
  for_each = local.app_map
  name     = "${each.key}-policy"
  policy   = <<EOT
%{for env in each.value.envs~}
path "${vault_mount.kvv2.path}/data/apps/${each.key}/${env}/*" {
  capabilities = ["read"]
}
%{endfor~}
EOT
}

resource "vault_kubernetes_auth_backend_role" "app_roles" {
  for_each                         = local.app_map
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "${each.key}-role"
  bound_service_account_names      = [each.key]
  bound_service_account_namespaces = [each.value.ns]
  token_policies                   = [vault_policy.app_policies[each.key].name]
  token_ttl                        = 3600
}
