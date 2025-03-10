terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.10.0"
    }
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.15, < 4.0"
      configuration_aliases = [azurerm.dns_zone_provider]
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0.0, < 3.0.0"
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
  skip_provider_registration = "true"
}

# provider "azurerm" {
#   features {}
#   alias                      = "management"
#   subscription_id            = var.management_subscription_id
#   skip_provider_registration = "true"
# }

# provider "azurerm" {
#   features {}
#   alias                      = "workstations_provider"
#   subscription_id            = var.workstations_subscription_id
#   skip_provider_registration = "true"
# }

# provider "azurerm" {
#   features {}
#   alias                      = "auroranonprod"
#   subscription_id            = var.auroranonprod_subscription_id
#   skip_provider_registration = "true"
# }

# provider "azurerm" {
#   features {}
#   alias                      = "auroraprod"
#   subscription_id            = var.auroraprod_subscription_id
#   skip_provider_registration = "true"
# }

# Configures the kubernetes provider from Hashicorp
# Some special notes:
#   - The 'exec' plugin is used here since AAD authentication is required to authenticate to the cluster. AAD authentication is required because local accounts are disabled (which should be always).
#     See: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
#   - In AKS, the 'server-id' argument that is provided to the 'kubelogin' command is the same for ALL environments/clusters and should remain statically configured
#     See: https://azure.github.io/kubelogin/concepts/aks.html

provider "kubernetes" {
  alias                  = "aurora_dev"
  host                   = module.aurora_dev_cc_00.cluster_kubeconfig.0.host
  cluster_ca_certificate = base64decode(module.aurora_dev_cc_00.cluster_kubeconfig.0.cluster_ca_certificate)

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
      "spn"
    ]
  }
}
