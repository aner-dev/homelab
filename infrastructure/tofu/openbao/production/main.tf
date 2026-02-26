# infrastructure/tofu/openbao/production/main.tf
module "vault_permissions" {
  source      = "../base"
  apps_config = var.apps_config
}
