# infrastructure/tofu/openbao/base/outputs.tf
# export the map of roles created in base/variables.tf
output "app_role_names" {
  description = "Map of all generated OpenBao Kubernetes auth roles"
  value       = { for k, v in vault_kubernetes_auth_backend_role.app_roles : k => v.role_name }
}

output "app_policy_names" {
  description = "Map of all generated OpenBao policies"
  value       = { for k, v in vault_policy.app_policies : k => v.name }
}
