resource "azurerm_application_insights" "appinsights" {
  name                = "appi-${var.prefix}-${var.environment}-${var.location}"
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.prefix}-logs-workspace"
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}