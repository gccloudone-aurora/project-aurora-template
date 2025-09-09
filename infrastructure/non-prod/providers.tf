terraform {
  required_version = "= 1.9.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.10.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

#################
### Providers ###
#################

provider "azuread" {
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  storage_use_azuread             = true
  use_cli = true
}

# provider "azurerm" {
#   features {}
#   alias                      = "<sdlc>"
#   subscription_id            = var.<sdlc>_subscription_id
#   skip_provider_registration = "true"
# }

# Configures the kubernetes provider from Hashicorp
# Some special notes:
#   - The 'exec' plugin is used here since AAD authentication is required to authenticate to the cluster. AAD authentication is required because local accounts are disabled (which should be always).
#     See: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
#   - In AKS, the 'server-id' argument that is provided to the 'kubelogin' command is the same for ALL environments/clusters and should remain statically configured
#     See: https://azure.github.io/kubelogin/concepts/aks.html
provider "kubernetes" {
  alias                  = "aurora"
  host                   = module.aurora.cluster_kubeconfig.0.host
  cluster_ca_certificate = base64decode(module.aurora.cluster_kubeconfig.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--use-azurerm-env-vars",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630",
      "--login",
      "azurecli"
    ]
  }
}
