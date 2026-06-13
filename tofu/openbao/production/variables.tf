variable "apps_config" {
  type = map(object({
    ns   = string
    envs = list(string)
  }))
}
variable "openbao_addr" {
  type        = string
  description = "The URL for the OpenBao server"
  # You can keep the default in base, but declaring it here allows 
  # you to override it in production/terraform.tfvars if needed.
}
