data "azurerm_subscription" "this" {}

data "azurerm_subnet" "route_reflector_subnet" {
  name                 = "RouteReflectorSubnet"
  virtual_network_name = "<FILLIN_VIRTUAL_NETWORK_NAME>"
  resource_group_name  = "<FILLIN_RESOURCE_GROUP_NAME>"
}

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
