#################################
### Aurora Environment Module ###
#################################

# Manages the Aurora Environment.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment
#
module "aurora" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment.git?ref=v2.1.5"

  azure_resource_attributes = local.aurora_azure_resource_attributes

  naming_convention = "gc"
  user_defined      = "AKS"

  custom_ca               = local.custom_ca
  dns_servers             = local.dns_servers
  ddos_protection_plan_id = local.ddos_protection_plan_id

  ## Network
  vnet_address_space       = local.vnet_address_space
  vnet_peers               = local.vnet_peers
  vnet_id                  = local.vnet_id
  subnets                  = local.subnets
  subnet_ids               = local.subnets_ids
  vnet_integration_enabled = false

  # Routes
  route_table_next_hop_ip_address = local.route_server_bgp_peers
  route_server_bgp_peers          = local.route_table_next_hop_ip_address

  ## AKS
  kubernetes_version      = "1.35.1"
  node_os_upgrade_channel = "None"
  cluster_sku_tier        = "Premium"
  cluster_support_plan    = "AKSLongTermSupport"

  ## Network
  network_plugin      = "none"
  network_mode        = null
  network_policy      = null
  network_data_plane  = null

  spn_object_ids = local.spn_object_ids

  cluster_admins = concat(
    local.spn_object_ids,
    [
      local.owner,
    ]
  )

  cluster_admins_group_object_id = local.cluster_admins_group_object_id

  node_pools = {
    system = {
      availability_zones = [1]
      mode               = "System"
      vm_size            = "Standard_D4s_v5"
      max_pods           = 60
      os_sku             = "AzureLinux"

      enable_auto_scaling    = true
      auto_scaling_min_nodes = 1
      auto_scaling_max_nodes = 4

      pod_subnet_id = local.pod_subnet_id

      node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
      node_labels = {
        "node.ssc-spc.gc.ca/use"     = "general",
        "node.ssc-spc.gc.ca/purpose" = "system",
      }
    },
    general = {
      availability_zones     = [1]
      vm_size                = "Standard_D8s_v5"
      max_pods               = 62
      enable_auto_scaling    = true
      auto_scaling_min_nodes = 1
      auto_scaling_max_nodes = 3
      os_sku             = "AzureLinux"

      pod_subnet_id = local.pod_subnet_id

      node_labels = {
        "node.ssc-spc.gc.ca/use"     = "general",
        "node.ssc-spc.gc.ca/purpose" = "general",
      }
    },
    gateway = {
      availability_zones     = [1]
      vm_size                = "Standard_D4s_v5"
      max_pods               = 30
      enable_auto_scaling    = true
      auto_scaling_min_nodes = 1
      auto_scaling_max_nodes = 3
      os_sku             = "AzureLinux"

      pod_subnet_id = local.pod_subnet_id

      node_taints = ["node.ssc-spc.gc.ca/purpose=gateway:NoSchedule"]
      node_labels = {
        "node.ssc-spc.gc.ca/use"     = "general",
        "node.ssc-spc.gc.ca/purpose" = "gateway",
      }
    },
  }

  # Platform Infrastructure
  grafana_sp = local.grafana_sp

  # Data sources
  data_sources             = local.environment_data_sources
  service_principal_owners = local.service_principal_owners


  # Private DNS Zone
  create_private_dns_zone_role = true

  # Custom Role Assignments
  create_custom_role_assignment = true

  tags = local.azure_tags
}
