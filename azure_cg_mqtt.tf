resource "azurerm_container_group" "rabbitmq" {
  name                = "cg-${var.prefix}-rabbitmq-${var.environment}-${var.location}"
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ip_address_type     = "Public"
  dns_name_label      = "cg-${var.prefix}-rabbitmq-${var.environment}-${var.location}"
  os_type             = "Linux"


  exposed_port {
    port     = 1883
    protocol = "TCP"
  }
  exposed_port {
    port     = 5672
    protocol = "TCP"
  }

  exposed_port {
    port     = 15672
    protocol = "TCP"
  }

  ##TO DO: add more variables and query more keys from keyvault
  container {
    name   = "rabbitmq"
    image  = "${var.acr_url}/rabbitmq:management"
    cpu    = "0.5"
    memory = "1"

    environment_variables = {
      "RABBITMQ_DEFAULT_USER" = "${var.rabbitmq_user}"
      "RABBITMQ_DEFAULT_PASS" = "${var.rabbitmq_password}"
    }
    ports {
      port     = 1883
      protocol = "TCP"
    }
    ports {
      port     = 5672
      protocol = "TCP"
    }
    ports {
      port     = 15672
      protocol = "TCP"
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.logs.workspace_id
      log_type      = "ContainerInsights"
      workspace_key = azurerm_log_analytics_workspace.logs.primary_shared_key
    }
  }
  
  tags = {
    product    = "RABBITMQ"
    createdby  = "jonahfrany"
    createdfor = "${var.environment} rabbitmq"
  }
}