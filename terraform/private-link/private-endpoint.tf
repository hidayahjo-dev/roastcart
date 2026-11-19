
# PostgreSQL Flexible Server Private Endpoint
#
# Disposable resource:
# Created during development/showcase sessions.
# Destroyed when private connectivity is no longer needed.

resource "azurerm_private_endpoint" "postgres" {
  name = "pe-roastcart-postgres"
  # Private Endpoint must match VNet region
  #location            = data.azurerm_resource_group.roastcart.location
  location = data.azurerm_virtual_network.roastcart.location

  resource_group_name = data.azurerm_resource_group.roastcart.name

  # Existing Private Endpoint subnet
  subnet_id = data.azurerm_subnet.private_endpoints.id

  # Connect this Private Endpoint to PostgreSQL
  private_service_connection {
    name                           = "psc-roastcart-postgres"
    private_connection_resource_id = data.azurerm_postgresql_flexible_server.roastcart.id

    subresource_names    = ["postgresqlServer"]
    is_manual_connection = false
  }

  tags = {
    project     = "roastcart"
    environment = "dev"
    managed_by  = "terraform"
    lifecycle   = "disposable"
  }
}
