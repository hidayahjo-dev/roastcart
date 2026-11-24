# Existing RoastCart resource group
data "azurerm_resource_group" "roastcart" {
  name = var.resource_group_name
}

# Existing VNet
data "azurerm_virtual_network" "roastcart" {
  name                = "vnet-roastcart"
  resource_group_name = data.azurerm_resource_group.roastcart.name
}

# Existing Private Endpoint subnet
data "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints-ps"
  virtual_network_name = data.azurerm_virtual_network.roastcart.name
  resource_group_name  = data.azurerm_resource_group.roastcart.name
}

# Existing PostgreSQL Flexible Server
data "azurerm_postgresql_flexible_server" "roastcart" {
  name                = "roastcart-dev-pg-db"
  resource_group_name = data.azurerm_resource_group.roastcart.name
}
