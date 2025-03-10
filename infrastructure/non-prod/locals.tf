locals {
  azure_tags = {}

  service_principal_owner_names = [
    "full.name@ssc-spc.gc.ca"
  ]
  service_principal_owners = []

  environment_data_sources = {
    dns_zone_id = {
      azmk8s       = data.azurerm_private_dns_zone.aks_api_server.id
      cert_manager = data.azurerm_dns_zone.cert_manager.id
      blob_storage = null
      keyvault     = null
    }
    active_directory = {
      service_principal_id = {
        cicd_runner = "99999999-9999-9999-9999-999999999999"
      }
      group_id = {
        cloudoperations           = ""
        aurora_general_cluster_user = ""
      }
      tenant_id       = data.azurerm_client_config.this.tenant_id
      subscription_id = data.azurerm_client_config.this.subscription_id
    }
  }
  route_table_next_hop_ip_address = "192.0.4.42"
}

###############################
### Platform Infrastructure ###
###############################

locals {
  grafana_sp = {
    members = {
      admin  = {}
      viewer = {}
    }
  }
}

# locals {
#   grafana_sp = {
#     members = {
#       admin = {
#         cloudoperations = data.azuread_group.cloudoperations.id
#       }
#       viewer = {
#         aurora_general_cluster_user = data.azuread_group.aurora_general_cluster_user.id
#       }
#     }
#   }
# }

########################
### Azure Networking ###
########################

# locals {
#   internal_address_prefixes = {
#     management_subnet               = data.azurerm_subnet.management.address_prefixes
#     workstations_subnet             = data.azurerm_subnet.workstations.address_prefixes
#     internal_boundary_route_servers = data.azurerm_virtual_hub.internal_route_server.virtual_router_ips
#   }
# }

####################
### BGP Solution ###
####################


locals {
  route_server_bgp_peers = []
}

# locals {
#   asn_aurora = 64512
#   route_reflector_ipv4_addresses = [
#     data.azurerm_virtual_machine.vm-route-reflector-0.private_ip_address,
#   ]

#   # Create BGP connections between the cluster's Azure Route Server & the BGP Route Reflector
#   route_server_bgp_peers = [for index, route_reflector_ip in local.route_reflector_ipv4_addresses :
#     {
#       name     = "vm-route-reflector-${index}"
#       peer_asn = local.asn_aurora
#       peer_ip  = route_reflector_ip
#     }
#   ]

#   # Create BGP connections between the Cilium virtual routers & the BGP Route Reflector
#   cilium_bgp_peers = [for route_reflector_ip in local.route_reflector_ipv4_addresses :
#     {
#       asn = local.asn_aurora
#       ip  = "${route_reflector_ip}/32"
#     }
#   ]
#   cilium_cluster_address_prefixes = ["192.0.2.0/16"]
# }

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
