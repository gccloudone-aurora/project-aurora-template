# Manages Aurora Resources Names.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-names
#
module "aurora_azure_resource_names" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-names.git?ref=v2.0.0"

  naming_convention = "gc"
  user_defined      = "PLATFORM"

  name_attributes = local.aurora_azure_resource_attributes
}

# Manages Aurora Resources Names.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-names
#
module "platform_azure_resource_names" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-names.git?ref=v2.0.0"

  naming_convention = "gc"
  user_defined      = "ARGO"

  name_attributes = local.aurora_azure_resource_attributes
}
