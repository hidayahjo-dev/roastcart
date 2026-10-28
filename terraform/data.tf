data "azurerm_resource_group" "roastcart" {
  name = var.resource_group_name
}

data "azurerm_container_registry" "roastcart" {
  name                = "acrroastcart26"
  resource_group_name = data.azurerm_resource_group.roastcart.name
}

data "azurerm_postgresql_flexible_server" "roastcart" {
  name                = "roastcart-dev-pg-db"
  resource_group_name = data.azurerm_resource_group.roastcart.name
}

# Existing VNet-integrated ACA environment
data "azurerm_container_app_environment" "roastcart_aca_env_vnet" {
  name                = "roastcart-aca-env-vnet"
  resource_group_name = data.azurerm_resource_group.roastcart.name
}

# Existing user-assigned managed identity for ACR pulls
data "azurerm_user_assigned_identity" "acr_pull" {
  name                = "roastcart-aca-pull-identity"
  resource_group_name = data.azurerm_resource_group.roastcart.name
}
