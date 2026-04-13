# resource "azurerm_role_assignment" "platform_operator_dev" {
#   role_definition_name = local.platform_operator_role_name
#   principal_id         = local.platform_operator_group_id
#   scope                = "/providers/Microsoft.Management/managementGroups/CNPDev"
# }

# resource "azurerm_role_assignment" "platform_operator_nonprod" {
#   role_definition_name = local.platform_operator_role_name
#   principal_id         = local.platform_operator_group_id
#   scope                = "/providers/Microsoft.Management/managementGroups/CNPNonProd"
# }

# resource "azurerm_role_assignment" "platform_operator_prod" {
#   role_definition_name = local.platform_operator_role_name
#   principal_id         = local.platform_operator_group_id
#   scope                = "/providers/Microsoft.Management/managementGroups/CNPProd"
# }