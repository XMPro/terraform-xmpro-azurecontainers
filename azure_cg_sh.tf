data "external" "ds_sh_outputs" {
  program = ["pwsh", "${path.module}/TerraformDSoutputs.ps1",
    "-targetServerName", "${local.mssql_server_url}",
    "-targetUser", var.db_admin_username,
    "-targetPassword", var.db_admin_password,
  "-CompanyName", var.companyname]
  depends_on = [azurerm_container_group.ds, azurerm_container_group.ad, azurerm_container_group.ai, azurerm_mssql_firewall_rule.allow_local_access]
}

locals {
  container_streamhost_data = {
    default = {
      streamhost_name              = "SH-01-TFACI-DEFAULT-${var.environment}-${var.location}"
      ds_server_url                = "https://ds.${azurerm_dns_zone.dns.name}/"
      streamhost_collection_id     = data.external.ds_sh_outputs.result["DefaultId"]
      streamhost_secret            = data.external.ds_sh_outputs.result["DefaultSecret"]
      appinsights_connectionstring = azurerm_application_insights.appinsights.connection_string
      streamhost_container_image   = var.streamhost_default_container_image
      streamhost_cpu               = var.sh_default_cpu
      streamhost_memory            = var.sh_default_memory
      env_variables                = {}
      volumes                      = []
    },
    ai = {
      streamhost_name              = "SH-02-TFACI-AI-${var.environment}-${var.location}"
      ds_server_url                = "https://ds.${azurerm_dns_zone.dns.name}/"
      streamhost_collection_id     = data.external.ds_sh_outputs.result["AIAssistantId"]
      streamhost_secret            = data.external.ds_sh_outputs.result["AIAssistantSecret"]
      appinsights_connectionstring = azurerm_application_insights.appinsights.connection_string
      streamhost_container_image   = var.streamhost_ai_container_image
      streamhost_cpu               = var.sh_ai_cpu
      streamhost_memory            = var.sh_ai_memory
      env_variables = {
        "AZURE_OPENAI_CHAT_DEPLOYMENT_NAME"       = "${var.docker_azure_openaichatdeploymentname}"
        "AZURE_OPENAI_EMBEDDINGS_DEPLOYMENT_NAME" = "${var.docker_azure_openaiembeddingsdeploymentname}"
        "OPENAI_API_VERSION"                      = "${var.docker_openaiversion}"
        "SCRIPT_PATH"                             = "${var.docker_migration_script_path}"
      }
      volumes = [{
        name                 = "rag-data"
        mount_path           = "/scripts"
        read_only            = false
        share_name           = azurerm_storage_share.sh_data.name
        storage_account_name = azurerm_storage_account.storage_account.name
        storage_account_key  = azurerm_storage_account.storage_account.primary_access_key
      }]
    }
  }
  log_analytics_id                 = azurerm_log_analytics_workspace.logs.workspace_id
  log_analytics_primary_shared_key = azurerm_log_analytics_workspace.logs.primary_shared_key
  resource_group_name              = azurerm_resource_group.xmprodocker.name
  resource_group_location          = azurerm_resource_group.xmprodocker.location
}

module "sh" {
  # source = "../terraform-xmpro-streamhost"
  source = var.module_streamhost_source

  for_each = local.container_streamhost_data

  streamhost_name            = each.value.streamhost_name
  streamhost_cpu             = each.value.streamhost_cpu
  streamhost_memory          = each.value.streamhost_memory
  streamhost_container_image = each.value.streamhost_container_image

  streamhost_collection_id     = each.value.streamhost_collection_id
  streamhost_secret            = each.value.streamhost_secret
  appinsights_connectionstring = each.value.appinsights_connectionstring
  ds_server_url                = each.value.ds_server_url

  prefix                           = var.prefix
  environment                      = var.environment
  location                         = var.location
  log_analytics_id                 = local.log_analytics_id
  log_analytics_primary_shared_key = local.log_analytics_primary_shared_key
  resource_group_name              = local.resource_group_name
  resource_group_location          = local.resource_group_location

  environment_variables = each.value.env_variables

  volumes = each.value.volumes

  depends_on = [azurerm_log_analytics_workspace.logs]
}