variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Existing RoastCart resource group"
  type        = string
  default     = "rg-roastcart-dev"
}
