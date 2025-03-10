locals {
  platform_azure_resource_attributes = {
    project     = "common"
    environment = "dev"
    location    = var.location
    instance    = 0
  }
}

module "platform_azure_resource_prefixes" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-prefixes.git?ref=v1.0.0"

  name_attributes = local.platform_azure_resource_attributes
}

resource "azurerm_resource_group" "argocd" {
  name     = module.platform_azure_resource_prefixes.resource_group_prefix
  location = var.location

  tags = local.azure_tags
}

#################
### Key Vault ###
#################

module "argocd_key_vault" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault.git?ref=v1.0.0"

  azure_resource_attributes = local.platform_azure_resource_attributes
  user_defined              = "argocd"
  resource_group_name       = azurerm_resource_group.argocd.name

  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  public_network_access_enabled = false
  private_endpoints = [
    {
      sub_resource_name   = "vault"
      subnet_id           = module.aurora_dev_cc_00.vnet_subnets["infrastructure"].id
      private_dns_zone_id = null
    }
  ]

  tags = local.azure_tags
}

resource "azurerm_key_vault_access_policy" "gitlab_runner_sp" {
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

# resource "azurerm_key_vault_access_policy" "cloudoperations" {
#   key_vault_id = module.argocd_key_vault.id
#   tenant_id    = data.azurerm_client_config.this.tenant_id
#   object_id    = data.azuread_group.cloudoperations.object_id

#   secret_permissions = [
#     "Get",
#     "List",
#     "Set",
#     "Delete",
#     "Recover",
#     "Backup",
#     "Restore"
#   ]
# }

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
  name                = "${module.platform_azure_resource_prefixes.managed_identity_prefix}-argocd"
  resource_group_name = azurerm_resource_group.argocd.name
  location            = var.location
  tags                = local.azure_tags
}

resource "azurerm_role_assignment" "argocd_vault_plugin_msi_managed_identity_operator" {
  scope                = azurerm_user_assigned_identity.argocd_vault_plugin.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aurora_dev_cc_00.cluster_kubelet_identity.object_id
}

resource "azurerm_key_vault_secret" "argocd_vault_plugin_msi_client_id" {
  name         = "${module.platform_azure_resource_prefixes.prefix}-argocd-kv-aadpodidentity-client-id"
  value        = azurerm_user_assigned_identity.argocd_vault_plugin.client_id
  key_vault_id = module.argocd_key_vault.id
}

resource "azurerm_key_vault_secret" "argocd_vault_plugin_msi_resource_id" {
  name         = "${module.platform_azure_resource_prefixes.prefix}-argocd-kv-aadpodidentity-resource-id"
  value        = azurerm_user_assigned_identity.argocd_vault_plugin.id
  key_vault_id = module.argocd_key_vault.id
}
