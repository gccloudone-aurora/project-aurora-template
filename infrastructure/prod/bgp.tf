####################
### Route Server ###
####################

# Manages an Azure Route Server and BGP connections within it.
#
# Only used in BYON (Bring Your Own Network) environments.
#
# https://github.com/gccloudone-aurora-iac/terraform-azure-route-server
#
# module "route_server" {
#   source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-route-server.git?ref=v2.0.0"

#   count = local.vnet_id != null ? 1 : 0

#   azure_resource_attributes = local.aurora_azure_resource_attributes
#   naming_convention         = "gc"
#   user_defined              = "BGP"

#   resource_group_name = local.route_server_resource_group_name
#   subnet_id           = local.route_server_subnet_id

#   bgp_peers = local.route_server_bgp_peers

#   tags = local.azure_tags
# }

#######################
### Route Reflector ###
#######################

# Manages an Azure Route Reflector (VM) and configures BIRD.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-bgp-route-reflector
#
# module "bgp_route_reflector" {
#   source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-bgp-route-reflector.git?ref=v2.0.0"

#   azure_resource_attributes = local.aurora_azure_resource_attributes
#   naming_convention         = "gc"
#   user_defined              = "bgp"

#   source_image = data.azurerm_platform_image.bgp_route_reflector

#   subnet_id = local.route_reflector_subnet_id

#   vm_instances         = 1
#   private_ip_addresses = local.route_reflector_ipv4_addresses

#   tags = local.azure_tags
# }
