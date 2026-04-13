#################
### Key Vault ###
#################

resource "azurerm_resource_group" "argocd" {
  name     = module.platform_azure_resource_names.resource_group_name
  location = var.location

  tags = local.azure_tags
}

# Manages an Azure keyvault.
#
# https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault
#
module "argocd_key_vault" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault.git?ref=v2.0.0"

  azure_resource_attributes = local.aurora_azure_resource_attributes

  naming_convention = "gc"
  user_defined      = "ARGO"

  resource_group_name = azurerm_resource_group.argocd.name

  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  public_network_access_enabled = false
  private_endpoints = [
    {
      sub_resource_name   = "vault"
      subnet_id           = module.aurora.vnet_subnets["infrastructure"].id
      private_dns_zone_id = null
    }
  ]

  tags = local.azure_tags
}

resource "azurerm_key_vault_access_policy" "cicd_runner_sp" {
  key_vault_id = module.argocd_key_vault.id
  tenant_id    = data.azurerm_client_config.this.tenant_id
  object_id    = data.azurerm_client_config.this.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]
}

resource "azurerm_key_vault_access_policy" "argocd_kv_msi" {
  key_vault_id = module.argocd_key_vault.id
  tenant_id    = data.azurerm_client_config.this.tenant_id
  object_id    = azurerm_user_assigned_identity.argocd_vault_plugin.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]
}

###########
### MSI ###
###########

resource "azurerm_user_assigned_identity" "argocd_vault_plugin" {
  name                = "${module.platform_azure_resource_names.managed_identity_name}-argocd"
  resource_group_name = azurerm_resource_group.argocd.name
  location            = var.location
  tags                = local.azure_tags
}

resource "azurerm_role_assignment" "argocd_vault_plugin_msi_managed_identity_operator" {
  scope                = azurerm_user_assigned_identity.argocd_vault_plugin.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aurora.cluster_kubelet_identity.object_id
}

resource "azurerm_key_vault_secret" "argocd_vault_plugin_msi_client_id" {
  name         = "${module.platform_azure_resource_names.key_vault_secret_name}-argocd-kv-aadpodidentity-client-id"
  value        = azurerm_user_assigned_identity.argocd_vault_plugin.client_id
  key_vault_id = module.argocd_key_vault.id
}

resource "azurerm_key_vault_secret" "argocd_vault_plugin_msi_resource_id" {
  name         = "${module.platform_azure_resource_names.key_vault_secret_name}-argocd-kv-aadpodidentity-resource-id"
  value        = azurerm_user_assigned_identity.argocd_vault_plugin.id
  key_vault_id = module.argocd_key_vault.id
}

######################
### ArgoCD Secrets ###
######################

# Manages Aurora Environment ArgoCD secrets.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-argo-secrets
#
module "aurora_argocd_secrets" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-argo-secrets.git?ref=v2.0.0"

  azure_resource_attributes = local.aurora_azure_resource_attributes

  naming_convention = "gc"
  user_defined      = "ARGO"

  argocd_keyvault_id = module.argocd_key_vault.id

  load_balancer_subnet_name = module.aurora.vnet_subnets["loadbalancer"].name

  # Azure & Kubernetes cluster secrets
  azure_secrets = {
    tenant_id       = data.azurerm_client_config.this.tenant_id
    subscription_id = data.azurerm_client_config.this.subscription_id
  }
  kubernetes_cluster = {
    server = module.aurora.cluster_kubeconfig.0.host
    argocd_sa = {
      token  = module.aurora_argocd_cluster_sp.service_account_token_secret.data.token
      caData = module.aurora_argocd_cluster_sp.service_account_token_secret.data["ca.crt"]
    }
  }
  image_pull_secret = var.platform_component_secrets.image_pull_secret.aurora_dev_cc_00

  # Workflow component secrets
  argo_workflow_secrets = {
    sso_service_principal = {
      client_id     = module.aurora.platform_infrastructure.argo_workflows_sso_sp.application_registration.client_id
      client_secret = module.aurora.platform_infrastructure.argo_workflows_sso_sp.application_registration_password.value
    }
    storage_account = {
      name     = module.aurora.platform_infrastructure.argo_workflows_storage_account_name
      endpoint = module.aurora.platform_infrastructure.argo_workflows_primary_blob_endpoint
      key      = module.aurora.platform_infrastructure.argo_workflows_primary_access_key
    }
  }

  # Security & Networking component secrets
  cert_manager_secrets = {
    aad_pod_identity = {
      client_id   = module.aurora.platform_infrastructure.cert_manager_identity_client_id
      resource_id = module.aurora.platform_infrastructure.cert_manager_identity_id
    }
  }
  velero_secrets = {
    aad_pod_identity = {
      client_id   = module.aurora.platform_infrastructure.velero_identity_client_id
      resource_id = module.aurora.platform_infrastructure.velero_identity_id
    }
    storage_account = {
      name                = module.aurora.platform_infrastructure.velero_storage_account_name
      resource_group_name = module.aurora.platform_infrastructure.backup_resource_group_name
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
      client_id     = module.aurora.platform_infrastructure.grafana_sso_sp.application_registration.client_id
      client_secret = module.aurora.platform_infrastructure.grafana_sso_sp.application_registration_password.value
    }
  }
  kiali_secrets = {
    grafana_token = var.platform_component_secrets.kiali.grafana_token
  }
  kubecost_secrets = {
    service_principal = {
      client_id     = module.aurora.platform_infrastructure.kubecost_sp.application_registration.client_id
      client_secret = module.aurora.platform_infrastructure.kubecost_sp.application_registration_password.value
    }
    token       = var.platform_component_secrets.kubecost.token
    product_key = var.platform_component_secrets.kubecost.product_key
  }

  bill_of_landing = {
    sa = {
      token  = module.aurora_bill_of_landing_sp.service_account_token_secret.data.token
      caData = module.aurora_bill_of_landing_sp.service_account_token_secret.data["ca.crt"]
    }
  }

  depends_on = [
    module.aurora
  ]

  # Cross subscription keyvault access fix
  # See https://github.com/hashicorp/terraform-provider-azurerm/issues/22064#issuecomment-1769799318
  # providers = { azurerm = azurerm.<sdlc> }
}

####################
### ArgoCD OIDC ###
####################

# Manages Azure service principals.
#
# https://github.com/gccloudone-aurora-iac/terraform-azure-service-principal
#
module "argocd_oidc_sp" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-service-principal.git?ref=v2.0.0"

  azure_resource_attributes = local.aurora_azure_resource_attributes

  naming_convention = "gc"
  user_defined      = "ARGO"

  owners = local.service_principal_owners

  web_redirect_uris = [
    "https://aur.aurora.${local.domain}/auth/callback",
    // "https://project.aurora.${local.domain}/auth/callback"
  ]

  group_membership_claims = ["All", "ApplicationGroup"]
  optional_claims = {
    access_tokens = [{
      name = "groups"
    }]
    id_tokens = [{
      name = "groups"
    }]
    saml2_tokens = [{
      name = "groups"
    }]
  }
}

resource "azurerm_key_vault_secret" "argocd_oidc_sp_client_id" {
  name         = "${module.aurora_azure_resource_names.key_vault_secret_name}-argocd-oidc-sp-client-id"
  value        = module.argocd_oidc_sp.application_registration.client_id
  key_vault_id = module.argocd_key_vault.id
}

resource "azurerm_key_vault_secret" "argocd_oidc_sp_client_secret" {
  name         = "${module.aurora_azure_resource_names.key_vault_secret_name}-argocd-oidc-sp-client-secret"
  value        = module.argocd_oidc_sp.application_registration_password.value
  key_vault_id = module.argocd_key_vault.id
}
