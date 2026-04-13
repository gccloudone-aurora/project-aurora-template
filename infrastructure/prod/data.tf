data "azurerm_subscription" "this" {}

###########
### DNS ###
###########

data "azurerm_dns_zone" "cert_manager" {
  name                = "example.ca"
  resource_group_name = "<FILLIN_RESOURCE_GROUP_NAME>"
}

data "azurerm_private_dns_zone" "aks_api_server" {
  name                = "privatelink.canadacentral.azmk8s.io"
  resource_group_name = "<FILLIN_RESOURCE_GROUP_NAME>"
}

data "azurerm_private_dns_zone" "blob_storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "<FILLIN_RESOURCE_GROUP_NAME>"
}

data "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "<FILLIN_RESOURCE_GROUP_NAME>"
}

###########
### AAD ###
###########

data "azurerm_client_config" "this" {}

# data "azuread_group" "aurora_general_cluster_user" {
#   object_id        = "XXXXX-XXXX-XXXX-XXXX-XXXXX"
#   security_enabled = true
# }

# data "azuread_user" "aad_service_principal_owners" {
#   for_each            = { for index, user in local.service_principal_owner_names : index => user }
#   user_principal_name = each.value
# }

##################
## BGP Solution ##
##################

data "azurerm_platform_image" "bgp_route_reflector" {
  location  = var.location
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
  version   = "24.04.202502040"
}
