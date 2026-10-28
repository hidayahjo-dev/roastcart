import {
  to = azurerm_virtual_network.roastcart

  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/vnet-roastcart"
}

# Import existing ACA infrastructure subnet
import {
  to = azurerm_subnet.aca

  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/vnet-roastcart/subnets/snet-aca"
}

# Import existing Private Endpoint subnet
import {
  to = azurerm_subnet.private_endpoints

  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/vnet-roastcart/subnets/snet-private-endpoints-ps"
}
