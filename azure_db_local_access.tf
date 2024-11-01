# External data source to fetch public IP using the script
data "external" "get_public_ip" {
  program = ["bash", "${path.module}/get_public_ip.sh"] # For Linux/macOS
}

# Firewall rule using the fetched IP
resource "azurerm_mssql_firewall_rule" "allow_local_access" {
  count            = var.is_azdo_pipeline ? 0 : 1
  name             = "allow-local-access"
  server_id        = azurerm_mssql_server.mssql[0].id
  start_ip_address = data.external.get_public_ip.result["public_ip"]
  end_ip_address   = data.external.get_public_ip.result["public_ip"]
}