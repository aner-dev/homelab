variable "apps_config" {
  description = "Map of apps and their environments. Overridden by environment-specific module calls."
  type = map(object({
    ns   = string
    envs = list(string)
  }))

  # Standard 'Safe-by-Default' values
  default = {
    "external-secrets" = {
      ns   = "external-secrets",
      envs = ["production"]
    }
  }
}

variable "openbao_addr" {
  type    = string
  default = "http://openbao.openbao.svc.cluster.local:8200"
}
