# resource "azurerm_role_assignment" "platform_operator_<sdlc>" {
#   role_definition_name = local.platform_operator_role_name
#   principal_id         = local.platform_operator_group_id
#   scope                = "/providers/Microsoft.Management/managementGroups/AUR<sdlc>"
# }
