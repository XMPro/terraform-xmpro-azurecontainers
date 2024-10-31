data "external" "ds_sh_outputs" {
  program = ["pwsh", "${path.module}/TerraformDSoutputs.ps1",
    "-targetServerName", "${local.mssql_server_url}",
    "-targetUser", var.db_admin_username,
    "-targetPassword", var.db_admin_password,
  "-CompanyName", var.companyname]
  depends_on = [azurerm_container_group.ds, azurerm_container_group.ad, azurerm_container_group.ai, azurerm_mssql_firewall_rule.allow_local_access]
}

module "sh" {
  source = "../../modules/azure_streamhost/"
  container_streamhost_data = {
    ai = {
      name                            = "shAI"
      gateway_server_url              = "https://ds.${azurerm_dns_zone.dns.name}/"
      gateway_collection_id           = "${data.external.ds_sh_outputs.result["AIAssistantId"]}"
      gateway_secret                  = "${data.external.ds_sh_outputs.result["AIAssistantSecret"]}"
      appinsights_connectionstring    = "${azurerm_application_insights.appinsights.connection_string}"
      sh_cpu                          = var.sh_ai_cpu #default value
      sh_memory                       = var.sh_ai_memory #default value
    },
    default = {
      name                            = "shDefault"
      gateway_server_url              = "https://ds.${azurerm_dns_zone.dns.name}/"
      gateway_collection_id           = "${data.external.ds_sh_outputs.result["DefaultId"]}"
      gateway_secret                  = "${data.external.ds_sh_outputs.result["DefaultSecret"]}"
      appinsights_connectionstring    = "${azurerm_application_insights.appinsights.connection_string}"
      sh_cpu                          = var.sh_default_cpu #default value
      sh_memory                       = var.sh_default_memory #default value

    }
  }
  prefix                              = var.prefix
  environment                         = var.environment
  location                            = var.location
  log_analytics_id                    = azurerm_log_analytics_workspace.logs.workspace_id
  log_analytics_primary_shared_key    = azurerm_log_analytics_workspace.logs.primary_shared_key
  resource_group_name                 = azurerm_resource_group.xmprodocker.name
  resource_group_location             = azurerm_resource_group.xmprodocker.location
  storage_account_name                = azurerm_storage_account.storage_account.name
  storage_account_primary_access_key  = azurerm_storage_account.storage_account.primary_access_key

  depends_on = [ azurerm_log_analytics_workspace.logs ]
}