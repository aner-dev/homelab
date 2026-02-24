provider "vault" {
  address = var.openbao_addr
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homelab"
}
