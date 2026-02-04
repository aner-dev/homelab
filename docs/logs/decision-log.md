# main header
decision: eliminate 'kubernetes_config_map "vault_brige" resource' in `tofu/vault/base/main.tf`
```terraform
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
```
# reasoning
## circular dependency 
Sequence of steps needed if I make the `vault_url` dynamic via a ConfigMap managed by Tofu:
1. To start External Secrets, I need that ConfigMap.
2. To get the ConfigMap, Tofu must run.
3. In some advanced setups, Tofu itself needs a secret from Vault to run (to access the S3 backend).

Edge Case: If the cluster goes down, I can't start Vault because I can't get the secret, and I can't get the secret because the ConfigMap isn't there yet.

Fix: Core infrastructure (DNS, Vault, Storage) should be hardcoded so the cluster can "boot up" from zero without needing a "bridge."
## blast radius
If Tofu manages that ConfigMap and I make a mistake in Tofu variables, accidentally change the vault_url to a typo (vualt...) for instance:

What happens?: Every single App in Ir cluster (Vaultwarden, Linkding, Grafana) breaks instantly because their SecretStore is pointing to a dead URL.

Fix: If the URL is hardcoded in YAML, a mistake in Tofu cannot break Ir existing, running applications. This is "Fault Isolation."
