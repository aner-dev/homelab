# infrastructure/tofu/openbao/base/moved.tf

# 1. Move the Blocky Policy
moved {
  from = vault_policy.blocky
  to   = vault_policy.app_policies["blocky-production"]
}

# 2. Move the Blocky Role
moved {
  from = vault_kubernetes_auth_backend_role.blocky
  to   = vault_kubernetes_auth_backend_role.app_roles["blocky-production"]
}

# 3. Move External Secrets (System app)
moved {
  from = vault_policy.external_secrets
  to   = vault_policy.app_policies["external-secrets-base"]
}
