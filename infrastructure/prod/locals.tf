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

  custom_ca                      = ""
  cluster_admins_group_object_id = null
  dns_servers                    = var.dns_server_ip_addresses
  ddos_protection_plan_id        = null

  spn_object_ids = var.spn_object_ids
  service_principal_owner_names = [
    "first.last@ssc-spc.gc.ca"
  ]
  service_principal_owners = var.spn_object_ids

  owner = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

  # Helper
  # subnets_map = {
  #   for k, s in data.azurerm_subnet.this :
  #   k => {
  #     id   = s.id
  #     name = s.name
  #   }
  # }

  # Network
  vnet_address_space = ["XX.XXX.X.X/22"]
  vnet_peers         = []
  vnet_id            = null
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
  subnets_ids = null

  pod_subnet_id = "<FILLIN_POD_SUBNET_ID>"

  # Data Sources
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

  # Platform
  grafana_sp = {
    members = {
      admin = {}
      viewer = {
        # aurora_general_cluster_user = data.azuread_group.aurora_general_cluster_user.object_id
      }
    }
  }
}

####################
### BGP Solution ###
####################

locals {
  asn_cns = 64512

  route_reflector_ipv4_addresses  = []
  route_server_bgp_peers          = null
  route_table_next_hop_ip_address = null
}

##################
### Kubernetes ###
##################

locals {
  aurora_namespace_annotations = {
    "project.ssc-spc.gc.ca/onboarding"     = ""
    "project.ssc-spc.gc.ca/lead"           = ""
    "project.ssc-spc.gc.ca/technical-lead" = ""
    "project.ssc-spc.gc.ca/git-group"      = "https://github.com/gccloudone-aurora"
  }

  aurora_namespace_labels = {
    "project.ssc-spc.gc.ca/name"         = "Aurora"
    "finance.ssc-spc.gc.ca/workload-id"  = "00001"
    "project.ssc-spc.gc.ca/team"         = "Aurora"
    "project.ssc-spc.gc.ca/division"     = "HSB"
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
