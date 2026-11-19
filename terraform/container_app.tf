# New Flask backend in the VNet-integrated ACA environment

resource "azurerm_container_app" "backend_vnet" {
  name                         = "roastcart-backend-vnet"
  resource_group_name          = data.azurerm_resource_group.roastcart.name
  container_app_environment_id = data.azurerm_container_app_environment.roastcart_aca_env_vnet.id
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"


  # Attach existing user-assigned managed identity
  identity {
    type = "UserAssigned"

    identity_ids = [
      data.azurerm_user_assigned_identity.acr_pull.id
    ]
  }

  # Authenticate to existing Azure Container Registry
  registry {
    server   = data.azurerm_container_registry.roastcart.login_server
    identity = data.azurerm_user_assigned_identity.acr_pull.id
  }

  # Container deployment configuration
  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "roastcart-backend"
      image  = "${data.azurerm_container_registry.roastcart.login_server}/roastcart-backend:${var.backend_image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }
    }
  }

  secret {
    name  = "database-url"
    value = var.database_url
  }

  # HTTP ingress for initial backend testing
  ingress {
    external_enabled = true
    target_port      = 5000
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
