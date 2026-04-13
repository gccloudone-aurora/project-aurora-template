#######################
### Azure Defaults ###
#######################

variable "tags" {
  type = any
}

variable "env" {}

variable "group" {}

variable "project" {}

variable "location" {
  description = "The Azure region where the resources should exist."
  type        = string
  nullable    = false
  default     = "Canada Central"
}

variable "domain" {
  type = any
}

#######################
### Aurora Defaults ###
#######################

# variable "location" {
#   description = "The Azure region where the resources should exist."
#   type        = string
#   nullable    = false
#   default     = "Canada Central"
# }

variable "aurora_common_azure_tags" {
  description = "Common Aurora tags for use on Azure resources."
  type        = map(string)
}

#####################
### Subscriptions ###
#####################

# variable "<sdlc>_subscription_id" {
#   description = "The subscription ID of the <sdlc> subscription."
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
      aur_dev_cc_00 = string
    })
    grafana = optional(object({
      admin_password = string
    }))
    loki = optional(object({
      username = string
      password = string
    }))
    kiali = object({
      grafana_token = string
    })
    kubecost = object({
      token       = string
      product_key = string
    })
  })
  sensitive = true
}
