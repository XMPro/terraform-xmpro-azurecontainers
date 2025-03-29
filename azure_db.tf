resource "azurerm_mssql_server" "mssql" {
  count                        = var.use_existing_sql_server ? 0 : 1
  name                         = "${var.prefix}-${var.environment}-sqlserver"
  resource_group_name          = azurerm_resource_group.xmprodocker.name
  location                     = azurerm_resource_group.xmprodocker.location
  version                      = "12.0"
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.use_existing_sql_server ? 0 : 1
  name             = "FirewallRule-AllowAzureServices"
  server_id        = azurerm_mssql_server.mssql[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "ai" {
  count          = var.use_existing_sql_server ? 0 : 1
  name           = "AI"
  server_id      = azurerm_mssql_server.mssql[0].id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 1
  read_scale     = false
  create_mode    = "Default"
  zone_redundant = false
  sku_name       = "S0"
}

resource "azurerm_mssql_database" "ad" {
  count          = var.use_existing_sql_server ? 0 : 1
  name           = "AD"
  server_id      = azurerm_mssql_server.mssql[0].id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 1
  read_scale     = false
  create_mode    = "Default"
  zone_redundant = false
  sku_name       = "S0"
}

resource "azurerm_mssql_database" "ds" {
  count          = var.use_existing_sql_server ? 0 : 1
  name           = "DS"
  server_id      = azurerm_mssql_server.mssql[0].id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 1
  read_scale     = false
  create_mode    = "Default"
  zone_redundant = false
  sku_name       = "S0"
}
# resource "azurerm_mssql_database" "sm" {
#   count          = var.use_existing_sql_server ? 0 : 1
#   name           = "SM"
#   server_id      = azurerm_mssql_server.mssql[0].id
#   collation      = "SQL_Latin1_General_CP1_CI_AS"
#   max_size_gb    = 1
#   read_scale     = false
#   create_mode    = "Default"
#   zone_redundant = false
#   sku_name       = "S0"
# }