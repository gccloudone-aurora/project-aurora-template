#################################
### Aurora Environment Module ###
#################################

# Manages the Aurora Environment.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment
#
module "aurora" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment.git?ref=v2.0.0"

  azure_resource_attributes = local.aurora_azure_resource_attributes

  naming_convention = "gc"
  user_defined      = "AKS"

  custom_ca               = local.custom_ca
  dns_servers             = local.dns_servers
  ddos_protection_plan_id = local.ddos_protection_plan_id

  ## Network
  vnet_address_space = local.vnet_address_space
  vnet_peers         = []
  vnet_id            = local.vnet_id
  subnets            = local.subnets
  subnet_ids         = local.subnet_ids

  ## Routes
  # route_server_bgp_peers          = local.route_server_bgp_peers
  # route_table_next_hop_ip_address = local.route_table_next_hop_ip_address

  ## AKS
  kubernetes_version      = "1.30.11"
  node_os_upgrade_channel = "None"
  cluster_sku_tier        = "Standard"
  cluster_admins          = [data.azurerm_client_config.this.object_id, local.owner]

  node_pools = {
    system = {
      availability_zones     = [1]
      mode       = "System"
      node_count = 1
      vm_size    = "Standard_D4s_v5"
      max_pods   = 30

      enable_auto_scaling    = true
      auto_scaling_min_nodes = 1
      auto_scaling_max_nodes = 3

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
      auto_scaling_max_nodes = 2

      node_taints = ["node.ssc-spc.gc.ca/purpose=gateway:NoSchedule"]
      node_labels = {
        "node.ssc-spc.gc.ca/use"     = "general",
        "node.ssc-spc.gc.ca/purpose" = "gateway",
      }
    }
  }

  # Platform
  grafana_sp = local.grafana_sp

  # Data sources
  data_sources             = local.environment_data_sources
  service_principal_owners = local.service_principal_owners

  tags = local.azure_tags
}
