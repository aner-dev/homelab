`infrastructure/tofu/vault/main.tf` should now only be responsible for:

Mounts: vault_mount (Where the secrets live).

Policies: vault_policy (Who can see what).

Auth Backends: vault_auth_backend (Enabling the K8s login method inside Vault).

Roles: vault_kubernetes_auth_backend_role (Mapping K8s identities to Vault policies).

Everything else stays in YAML for Flux.
