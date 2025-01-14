resource "azurerm_key_vault" "ai_vault" {
  name                = format("%s-vault-%s-ai", var.companyname, random_string.name_suffix.result)
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "terraform_ai_policy" {
  key_vault_id = azurerm_key_vault.ai_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Create",
    "Get",
    "List",
    "Update",
    "Delete",
    "Purge"
  ]

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Update",
    "Delete",
    "Import",
    "Backup",
    "Restore",
    "Sign",
    "Verify"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}

resource "azurerm_key_vault_access_policy" "ai_aci_policy" {
  key_vault_id = azurerm_key_vault.ai_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_group.ai.identity[0].principal_id
  depends_on   = [azurerm_container_group.ai]

  secret_permissions = [
    "Get",
    "List"
  ]

  key_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "ai_data_connection_string" {
  name         = "xmpro--data--connectionString"
  value        = local.ai_connection_string
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai_appinsights_connectionstring" {
  name         = "ApplicationInsights--ConnectionString"
  value        = azurerm_application_insights.appinsights.connection_string
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai__xmsettings_data_connection_string" {
  name         = "xmpro--xmsettings--data--connectionString"
  value        = local.ai_connection_string
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai_client_id" {
  name         = "xmpro--xmidentity--client--id"
  value        = data.external.deployment_script_outputs.result["AIProductId"]
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai_client_sharedkey" {
  name         = "xmpro--xmidentity--client--sharedkey"
  value        = data.external.deployment_script_outputs.result["AIProductKey"]
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai_aiassistant_mqtt_clientid" {
  name         = "xmpro--aIDesigner--aiAssistant--mqtt--clientid"
  value        = "aiserver"
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai_aiassistant_mqtt_username" {
  name         = "xmpro--aIDesigner--aiAssistant--mqtt--username"
  value        = var.rabbitmq_user
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}

resource "azurerm_key_vault_secret" "ai_aiassistant_mqtt_password" {
  name         = "xmpro--aIDesigner--aiAssistant--mqtt--password"
  value        = var.rabbitmq_password
  key_vault_id = azurerm_key_vault.ai_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ai_policy]
}
