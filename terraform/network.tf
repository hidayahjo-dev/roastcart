# Existing VNet - to be imported
resource "azurerm_virtual_network" "roastcart" {
  name                = "vnet-roastcart"
  location            = "malaysiawest"
  resource_group_name = data.azurerm_resource_group.roastcart.name

  address_space = var.vnet_address_space
}

# Existing ACA subnet — to be imported
resource "azurerm_subnet" "aca" {
  name                 = "snet-aca"
  resource_group_name  = data.azurerm_resource_group.roastcart.name
  virtual_network_name = azurerm_virtual_network.roastcart.name

  address_prefixes = [var.aca_subnet_prefix]

  private_endpoint_network_policies = "Disabled"

  delegation {
    name = "0"

    service_delegation {
      name = "Microsoft.App/environments"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Existing subnet reserved for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints-ps"
  resource_group_name  = data.azurerm_resource_group.roastcart.name
  virtual_network_name = azurerm_virtual_network.roastcart.name

  address_prefixes = [var.private_endpoint_subnet_prefix]

  private_endpoint_network_policies = "Disabled"
}


