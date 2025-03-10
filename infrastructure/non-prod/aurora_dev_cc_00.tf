locals {
  aurora_dev_cc_00_azure_resource_attributes = {
    project     = "aurora"
    environment = "dev"
    location    = var.location
    instance    = 0
  }
}

module "aurora_dev_cc_00_azure_resource_prefixes" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-prefixes.git?ref=v1.0.0"

  name_attributes = local.aurora_dev_cc_00_azure_resource_attributes
}

#######################################
### Aurora Environment Module ###
#######################################

# Manages the Aurora Environment.
#
# https://gitlab.k8s.cloud.statcan.ca/cloudnative/platform/terraform/terraform-statcan-azure-cloud-native-environment
#
module "aurora_dev_cc_00" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment?ref=v1.0.0"

  azure_resource_attributes = local.aurora_dev_cc_00_azure_resource_attributes

  ## Network ##
  vnet_address_space = ["192.0.2.0/23"]
  vnet_peers         = []
  ddos_protection_plan_id = null

  # custom_ca = "BASE64 Encoded String"

  dns_servers = var.dns_server_ip_addresses

  subnets = {
    RouteServerSubnet = {
      address_prefixes      = ["192.0.2.0/27"]
      associate_route_table = false
      create_nsg            = false
    }
    apiserver = {
      address_prefixes        = ["192.0.2.32/27"]
      service_delegation_name = "Microsoft.ContainerService/managedClusters"
    }
    infrastructure = {
      address_prefixes = ["192.0.2.64/26"]
    }
    loadbalancer = {
      address_prefixes = ["192.0.2.128/27"]
    }
    gateway = {
      address_prefixes = ["192.0.2.160/27"]
    }
    system = {
      address_prefixes  = ["192.0.2.192/27"]
      service_endpoints = ["Microsoft.Storage"]
    }
    general = {
      address_prefixes  = ["192.0.177.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
      service_endpoint_policy_definitions = [{
        scopes = ["/subscriptions/${var.dev_subscription_id}"]
      }]
    }
  }
  route_table_next_hop_ip_address = local.route_table_next_hop_ip_address
  route_server_bgp_peers          = local.route_server_bgp_peers

  ## AKS Infrastructure ##
  kubernetes_version      = "1.29.10"
  node_os_upgrade_channel = "None"
  cluster_sku_tier        = "Standard"
  cluster_admins = [data.azurerm_client_config.this.object_id]

  node_pools = {
    system = {
      mode                   = "System"
      vm_size                = "Standard_D4s_v5"
      max_pods               = 30

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
    },
  }

  # Platform Infrastructure
  grafana_sp = local.grafana_sp

  # Data sources
  data_sources             = local.environment_data_sources
  service_principal_owners = local.service_principal_owners

  tags = local.azure_tags
}

######################
### ArgoCD Secrets ###
######################

# Manages the Aurora Environment ArgoCD secrets.
#
# https://gitlab.k8s.cloud.statcan.ca/cloudnative/platform/terraform/terraform-statcan-azure-cloud-native-environment-argo-secrets
#
module "aurora_dev_cc_00_argocd_secrets" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-argo-secrets.git?ref=v1.0.0"

  azure_resource_attributes = local.aurora_dev_cc_00_azure_resource_attributes
  argocd_keyvault_id        = module.argocd_key_vault.id

  # Azure & Kubernetes cluster secrets
  azure_secrets = {
    tenant_id       = data.azurerm_client_config.this.tenant_id
    subscription_id = data.azurerm_client_config.this.subscription_id
  }
  kubernetes_cluster = {
    server = module.aurora_dev_cc_00.cluster_kubeconfig.0.host
    argocd_sa = {
      token  = module.aurora_dev_cc_00_argocd_cluster_sp.service_account_token_secret.data.token
      caData = module.aurora_dev_cc_00_argocd_cluster_sp.service_account_token_secret.data["ca.crt"]
    }
  }
  image_pull_secret = var.platform_component_secrets.image_pull_secret.aurora_dev_cc_00

  # Workflow component secrets
  argo_workflow_secrets = {
    sso_service_principal = {
      client_id     = module.aurora_dev_cc_00.platform_infrastructure.argo_workflows_sso_sp.application_registration.client_id
      client_secret = module.aurora_dev_cc_00.platform_infrastructure.argo_workflows_sso_sp.application_registration_password.value
    }
    storage_account = {
      name     = module.aurora_dev_cc_00.platform_infrastructure.argo_workflows_storage_account_name
      endpoint = module.aurora_dev_cc_00.platform_infrastructure.argo_workflows_primary_blob_endpoint
      key      = module.aurora_dev_cc_00.platform_infrastructure.argo_workflows_primary_access_key
    }
  }

  # Security & Networking component secrets
  cert_manager_secrets = {
    aad_pod_identity = {
      client_id   = module.aurora_dev_cc_00.platform_infrastructure.cert_manager_identity_client_id
      resource_id = module.aurora_dev_cc_00.platform_infrastructure.cert_manager_identity_id
    }
  }
  velero_secrets = {
    aad_pod_identity = {
      client_id   = module.aurora_dev_cc_00.platform_infrastructure.velero_identity_client_id
      resource_id = module.aurora_dev_cc_00.platform_infrastructure.velero_identity_id
    }
    storage_account = {
      name                = module.aurora_dev_cc_00.platform_infrastructure.velero_storage_account_name
      resource_group_name = module.aurora_dev_cc_00.platform_infrastructure.backup_resource_group_name
    }
  }

  # Observability component secrets
  loki_secrets = var.platform_component_secrets.loki != null ? {
    username = var.platform_component_secrets.loki.username
    password = var.platform_component_secrets.loki.password
  } : null
  grafana_secrets = {
    admin_password = var.platform_component_secrets.grafana != null ? var.platform_component_secrets.grafana.admin_password : null
    sso_service_principal = {
      client_id     = module.aurora_dev_cc_00.platform_infrastructure.grafana_sso_sp.application_registration.client_id
      client_secret = module.aurora_dev_cc_00.platform_infrastructure.grafana_sso_sp.application_registration_password.value
    }
  }
  kiali_secrets = {
    grafana_token = var.platform_component_secrets.kiali.aurora_dev_cc_00_grafana_token
  }
  kubecost_secrets = {
    service_principal = {
      client_id     = module.aurora_dev_cc_00.platform_infrastructure.kubecost_sp.application_registration.client_id
      client_secret = module.aurora_dev_cc_00.platform_infrastructure.kubecost_sp.application_registration_password.value
    }
    token       = var.platform_component_secrets.kubecost.token
    product_key = var.platform_component_secrets.kubecost.product_key
  }

  bill_of_landing = {
    sa = {
      token  = module.aurora_dev_cc_00_bill_of_landing_sp.service_account_token_secret.data.token
      caData = module.aurora_dev_cc_00_bill_of_landing_sp.service_account_token_secret.data["ca.crt"]
    }
  }


  depends_on = [
    module.aurora_dev_cc_00
  ]

  # Cross-subscription keyvault access fix
  # See https://github.com/hashicorp/terraform-provider-azurerm/issues/22064#issuecomment-1769799318
  # providers = { azurerm = azurerm.auroranonprod }
}
