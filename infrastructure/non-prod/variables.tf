variable "location" {
  description = "The Azure region where the resources should exist."
  type        = string
  nullable    = false
  default     = "Canada Central"
}

variable "aurora_common_azure_tags" {
  description = "Common Aurora tags for use on Azure resources."
  type        = map(string)
}

#####################
### Subscriptions ###
#####################

# variable "management_subscription_id" {
#   description = "The subcription ID of the management subscription."
#   type        = string
#   nullable    = false
#   sensitive   = true
# }

# variable "workstations_subscription_id" {
#   description = "The subcription ID of the Workstations subscription."
#   type        = string
#   nullable    = false
#   sensitive   = true
# }

# variable "auroranonprod_subscription_id" {
#   description = "The subcription ID of the AuroraNonProd subscription."
#   type        = string
#   nullable    = false
#   sensitive   = true
# }

# variable "auroraprod_subscription_id" {
#   description = "The subcription ID of the AuroraProd subscription."
#   type        = string
#   nullable    = false
#   sensitive   = true
# }

variable "dev_subscription_id" {
  description = "The subcription ID of the dev subscription."
  type        = string
  nullable    = false
}

# variable "test_subscription_id" {
#   description = "The subcription ID of the test subscription."
#   type        = string
#   nullable    = false
# }

# variable "uat_subscription_id" {
#   description = "The subcription ID of the uat subscription."
#   type        = string
#   nullable    = false
# }

# variable "qa_subscription_id" {
#   description = "The subcription ID of the qa subscription."
#   type        = string
#   nullable    = false
# }

# variable "prod_subscription_id" {
#   description = "The subcription ID of the prod subscription."
#   type        = string
#   nullable    = false
# }

######################
### Common Network ###
######################

variable "dns_server_ip_addresses" {
  description = "The subcription ID that the BGP Route Reflector is in."
  type        = list(string)
}

# variable "firewall_ip_address" {
#   description = "The IP address of the hub firewall."
#   type        = string
# }

###########################
### BGP Route Reflector ###
###########################

# variable "route_reflector_apt_repository_username" {
#   description = "The username of the service principal used to authenticate to the debian Artifactory repository which has the route reflector binaries."
#   type        = string
#   nullable    = false
#   sensitive   = true
# }

# variable "route_reflector_apt_repository_password" {
#   description = "The password or API token of the service principal used to authenticate to the debian Artifactory repository which has the route reflector binaries."
#   type        = string
#   nullable    = false
#   sensitive   = true
# }

#######################
### Argo CD Secrets ###
#######################

variable "platform_component_secrets" {
  description = "The secrets that require user input and that are used to create the platform components using Argo CD. The Argo CD Vault Plugin tool is used."
  type = object({
    image_pull_secret = object({
      aurora_dev_cc_00  = string
    })
    grafana = optional(object({
      admin_password = string
    }))
    loki = optional(object({
      username = string
      password = string
    }))
    kiali = object({
      aurora_dev_cc_00_grafana_token  = string
    })
    kubecost = object({
      token       = string
      product_key = string
    })
  })
  sensitive = true
}
