locals {
  aurora_azure_resource_attributes = {
    department_code = substr(var.env, 0, 2)
    owner           = var.group
    project         = var.project
    environment     = substr(var.env, 2, 1)
    location        = var.location
    instance        = 0
  }

  azure_tags = merge(var.tags, var.aurora_common_azure_tags)

  domain = var.domain

  service_principal_owner_names = [
    "full.name@ssc-spc.gc.ca"
  ]
  service_principal_owners = []

  owner = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

  custom_ca               = null
  dns_servers             = var.dns_server_ip_addresses
  ddos_protection_plan_id = null

  ## Network
  vnet_address_space = ["XX.XXX.X.X/22"]
  vnet_peers         = []
  vnet_id            = null
  subnet_ids         = null

  # BYON
  # vnet_id    = data.terraform_remote_state.L1.outputs.Project-vnet.id
  # subnets    = null
  # subnet_ids = { for key, value in data.terraform_remote_state.L1.outputs.subnets : key => value.id }

  subnets = {
    RouteServerSubnet = {
      address_prefixes      = ["XX.XXX.X.X/27"]
      associate_route_table = false
      create_nsg            = false
    }
    apiserver = {
      address_prefixes        = ["XX.XXX.X.X/27"]
      service_delegation_name = "Microsoft.ContainerService/managedClusters"
    }
    infrastructure = {
      address_prefixes = ["XX.XXX.X.X/26"]
    }
    loadbalancer = {
      address_prefixes = ["XX.XXX.X.X/27"]
    }
    gateway = {
      address_prefixes = ["XX.XXX.X.X/27"]
    }
    system = {
      address_prefixes  = ["XX.XXX.X.X/27"]
      service_endpoints = ["Microsoft.Storage"]
    }
    general = {
      address_prefixes  = ["XX.XXX.X.X/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
    }
  }

  environment_data_sources = {
    dns_zone_id = {
      azmk8s       = data.azurerm_private_dns_zone.aks_api_server.id
      cert_manager = data.azurerm_dns_zone.cert_manager.id
      blob_storage = data.azurerm_private_dns_zone.blob_storage.id
      keyvault     = data.azurerm_private_dns_zone.keyvault.id
    }
    active_directory = {
      service_principal_id = {
        # DevOps S.P.
        cicd_runner = data.azurerm_client_config.this.client_id
        # Cluster Admins Owner
        cluster_admins_owner = local.owner
      }
      group_id = {
        aurora_general_cluster_user = ""
      }
      tenant_id       = data.azurerm_client_config.this.tenant_id
      subscription_id = data.azurerm_client_config.this.subscription_id
    }
  }
}

###########
### BGP ###
###########

locals {
  asn_cns = 64512

  # Route Reflector
  # route_reflector_subnet_id = data.azurerm_subnet.route_reflector_subnet.id
  # route_reflector_ipv4_addresses = [
  #   "XX.XXX.X.XXX"
  # ]

  # Create BGP connections between the cluster's Azure Route Server & the BGP Route Reflector
  # route_server_bgp_peers = length(local.route_reflector_ipv4_addresses) > 0 ? [
  #   for index, route_reflector_ip in local.route_reflector_ipv4_addresses : {
  #     name     = "vm-route-reflector-${index}"
  #     peer_asn = local.asn_cns
  #     peer_ip  = route_reflector_ip
  #   }
  # ] : []
  # route_server_resource_group_name = module.aurora.platform_resource_group_id
  # route_server_subnet_id           = module.aurora.vnet_subnets["RouteServerSubnet"].id

  # BYON
  # route_server_resource_group_name = data.terraform_remote_state.L1.outputs.resource_groups_L1["Network"].name
  # route_server_subnet_id           = data.terraform_remote_state.L1.outputs.subnets["RouteServerSubnet"].id

  # Route Table
  # route_table_next_hop_ip_address = "XX.XXX.X.XXX"

  # # Create BGP connections between the Cilium virtual routers & the BGP Route Reflector
  # cilium_bgp_peers = [for route_reflector_ip in local.route_reflector_ipv4_addresses :
  #   {
  #     asn = local.asn_cns
  #     ip  = "${route_reflector_ip}/32"
  #   }
  # ]
  # cilium_cluster_address_prefixes = ["XXX.XX.X.X/16"]
}

##################
### Kubernetes ###
##################

locals {
  aurora_namespace_annotations = {
    "project.ssc-spc.gc.ca/onboarding"     = ""
    "project.ssc-spc.gc.ca/lead"           = "Full Name"
    "project.ssc-spc.gc.ca/technical-lead" = "Full Name"
    "project.ssc-spc.gc.ca/git-group"      = "https://github.com/gccloudone-aurora"
  }

  aurora_namespace_labels = {
    "project.ssc-spc.gc.ca/name"         = "Aurora"
    "finance.ssc-spc.gc.ca/workload-id"  = "00001"
    "project.ssc-spc.gc.ca/team"         = "Aurora"
    "project.ssc-spc.gc.ca/division"     = "IT"
    "project.ssc-spc.gc.ca/frc"          = "00000"
    "project.ssc-spc.gc.ca/pe"           = "00000"
    "project.ssc-spc.gc.ca/ato-received" = "false"
    "project.ssc-spc.gc.ca/project-id"   = "00000"
    "namespace.ssc-spc.gc.ca/purpose"    = "system"
  }

  namespace_metadata = {
    annotations = local.aurora_namespace_annotations
    labels      = local.aurora_namespace_labels
  }
}

################
### Platform ###
################

locals {
  grafana_sp = {
    members = {
      admin  = {}
      viewer = {}
    }
  }
}
