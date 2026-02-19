variable "eso_namespace" {
  description = "The Kubernetes namespace where External Secrets Operator is running"
  type        = string
  default     = "external-secrets"
}
variable "openbao_addr" {
  type        = string
  description = "The internal network URL of the OpenBao service"
  default     = "http://openbao.openbao.svc.cluster.local:8200"
}
