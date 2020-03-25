# this is a workaround to allow JIT
# initialization of these providers
# https://github.com/hashicorp/terraform/issues/2430

resource "local_file" "kubeconfig" {
  depends_on = [module.aws]
  content    = module.aws.kubeconfig
  filename   = "${path.root}/kubeconfig-${var.deployment_id}"
}

resource "local_file" "astronomer_helm_values" {
  content  = var.astronomer_helm_values
  filename = "${path.root}/${var.deployment_id}-config.yaml"
}

provider "kubernetes" {
  host                   = module.aws.kube_endpoint
  cluster_ca_certificate = module.aws.kube_ca_certificate
  token                  = module.aws.kube_auth_token
  load_config_file       = false
  version                = "~> 1.9"
}

provider "helm" {
  version         = "~> 0.10"
  service_account = "tiller"
  namespace       = "kube-system"
  install_tiller  = false
  kubernetes {
    host                   = module.aws.kube_endpoint
    cluster_ca_certificate = module.aws.kube_ca_certificate
    token                  = module.aws.kube_auth_token
    load_config_file       = false
  }
}
