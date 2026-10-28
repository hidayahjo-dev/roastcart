variable "subscription_id" {
  description = "Azure for Students subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Existing RoastCart resource group"
  type        = string
}

variable "vnet_address_space" {
  description = "Existing VNet CIDR range"
  type        = list(string)
}

variable "aca_subnet_prefix" {
  description = "Existing ACA subnet CIDR"
  type        = string
}

variable "private_endpoint_subnet_prefix" {
  description = "Existing Private Endpoint subnet CIDR"
  type        = string
}

variable "backend_image_tag" {
  description = "Git commit SHA tag of the RoastCart backend image in ACR"
  type        = string
}
