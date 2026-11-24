
# Private DNS Zone for Azure PostgreSQL Flexible Server
# using Azure Private Link.

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.roastcart.name

  tags = {
    environment = "dev"
    lifecycle   = "disposable"
    managed_by  = "terraform"
    project     = "roastcart"
  }
}


# Link RoastCart VNet to PostgreSQL Private DNS Zone.


# Link RoastCart VNet to PostgreSQL Private DNS Zone.

resource "azurerm_private_dns_zone_virtual_network_link" "roastcart" {
  name                = "link-roastcart-vnet-postgres"
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  virtual_network_id  = data.azurerm_virtual_network.roastcart.id

  registration_enabled = false

  tags = {
    environment = "dev"
    lifecycle   = "disposable"
    managed_by  = "terraform"
    project     = "roastcart"
  }
}

