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