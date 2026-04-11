# --- 1. THE MOUNT ---
resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "PKI engine for athanor cluster certificates"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 315360000 # 10 years (must be >= Root CA TTL)
}

# --- 2. ROOT CA ---
resource "vault_pki_secret_backend_root_cert" "root" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "athanor-root-ca"
  ttl                  = "315360000" # 10 years
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "Homelab"
  organization         = "Athanor"
}

# --- 3. ROLE  ---
resource "vault_pki_secret_backend_role" "athanor_role" {
  backend          = vault_mount.pki.path
  name             = "athanor-dot-local"
  ttl              = 86400 # 24 hours (short-lived certs are safer)
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["athanor.local", "svc.cluster.local"]
  allow_subdomains = true
}

# --- 4. AUTH BINDING  ---
# REUSE the kubernetes auth backend defined in auth_kubernetes.tf
resource "vault_kubernetes_auth_backend_role" "cert_manager" {
  backend                          = "kubernetes" # Path from auth_kubernetes.tf
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager"]
  bound_service_account_namespaces = ["cert-manager"]
  token_policies                   = [vault_policy.cert_manager_policy.name]
  token_ttl                        = 3600
}

# Add the policy that actually allows signing
resource "vault_policy" "cert_manager_policy" {
  name   = "cert-manager-policy"
  policy = <<EOT
path "${vault_mount.pki.path}/sign/${vault_pki_secret_backend_role.athanor_role.name}" {
  capabilities = ["update"]
}
EOT
}
