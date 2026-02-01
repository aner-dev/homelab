variable "eso_namespace" {
  description = "The Kubernetes namespace where External Secrets Operator is running"
  type        = string
  default     = "external-secrets"
}
variable "vault_url" {
  type        = string
  description = "The internal network URL of the Vault service"
  default     = "http://vault.vault.svc.cluster.local:8200"
}
