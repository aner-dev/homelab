provider "vault" {
  adress = var.openbao_url
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "rancher-desktop"
}
