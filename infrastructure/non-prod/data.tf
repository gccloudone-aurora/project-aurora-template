data "azurerm_subscription" "this" {}

############
### DDOS ###
############

# data "azurerm_network_ddos_protection_plan" "this" {
#   name                = "management-ddos"
#   resource_group_name = "management-rg"

#   provider = azurerm.management
# }

###########
### DNS ###
###########

data "azurerm_dns_zone" "cert_manager" {
  name                = "cloud-nuage.canada.ca"
  resource_group_name = "RESOURCE_GROUP_NAME"
}

data "azurerm_private_dns_zone" "aks_api_server" {
  name                = "DNS_ZONE_NAME.private.canadacentral.azmk8s.io"
  resource_group_name = "RESOURCE_GROUP_NAME"
}

# data "azurerm_private_dns_zone" "blob_storage" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = "network-management-rg"

#   provider = azurerm.management
# }

# data "azurerm_private_dns_zone" "keyvault" {
#   name                = "privatelink.vaultcore.azure.net"
#   resource_group_name = "network-management-rg"

#   provider = azurerm.management
# }

###########
### AAD ###
###########

data "azurerm_client_config" "this" {}

# data "azuread_group" "cloudoperations" {
#   object_id        = "99999999-9999-9999-9999-999999999999"
#   security_enabled = true
# }

# data "azuread_group" "aurora_general_cluster_user" {
#   object_id        = "99999999-9999-9999-9999-999999999999"
#   security_enabled = true
# }

# data "azuread_user" "aad_service_principal_owners" {
#   for_each            = { for index, user in local.service_principal_owner_names : index => user }
#   user_principal_name = each.value
# }

###############
### Subnets ###
###############

# data "azurerm_subnet" "management" {
#   name                 = "management"
#   virtual_network_name = "management-vnet"
#   resource_group_name  = "management-rg"

#   provider = azurerm.management
# }

# data "azurerm_subnet" "workstations" {
#   name                 = "workstations"
#   virtual_network_name = "workstations-vnet"
#   resource_group_name  = "workstations-rg"

#   provider = azurerm.workstations_provider
# }

##################
## BGP Solution ##
##################

# data "azurerm_virtual_network" "bgp_route_reflector" {
#   name                = "platform-dev-cc-00-vnet"
#   resource_group_name = "platform-dev-cc-00-rg"

#   provider = azurerm.auroranonprod
# }

# data "azurerm_virtual_machine" "vm-route-reflector-0" {
#   name                = "platform-dev-cc-00-vm-route-reflector-0"
#   resource_group_name = "platform-dev-cc-00-rg"

#   provider = azurerm.auroranonprod
# }

# data "azurerm_virtual_hub" "internal_route_server" {
#   name                = "internal-route-server"
#   resource_group_name = "management-rg"

#   provider = azurerm.management
# }

###############
## Key Vault ##
###############

# data "azurerm_key_vault" "argocd" {
#   name                = "kv999999argocd"
#   resource_group_name = "common-dev-cc-00-rg"

#   provider = azurerm.auroranonprod
# }
