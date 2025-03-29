resource "azurerm_key_vault" "ds_vault" {
  name                = format("%s-vault-%s-ds", var.companyname, random_string.name_suffix.result)
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "terraform_ds_policy" {
  key_vault_id = azurerm_key_vault.ds_vault.id
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

resource "azurerm_key_vault_access_policy" "ds_aci_policy" {
  key_vault_id = azurerm_key_vault.ds_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_group.ds.identity[0].principal_id
  depends_on   = [azurerm_container_group.ds]

  secret_permissions = [
    "Get",
    "List"
  ]

  key_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "ds_appinsights_connectionstring" {
  name         = "ApplicationInsights--ConnectionString"
  value        = azurerm_application_insights.appinsights.connection_string
  key_vault_id = azurerm_key_vault.ds_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ds_policy]
}

resource "azurerm_key_vault_secret" "ds__xmsettings_data_connection_string" {
  name         = "xmpro--xmsettings--data--connectionString"
  value        = local.ds_connection_string
  key_vault_id = azurerm_key_vault.ds_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ds_policy]
}

resource "azurerm_key_vault_secret" "ds_data_connection_string" {
  name         = "xmpro--data--connectionString"
  value        = local.ds_connection_string
  key_vault_id = azurerm_key_vault.ds_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ds_policy]
}

resource "azurerm_key_vault_secret" "ds_client_id" {
  name         = "xmpro--xmidentity--client--id"
  value        = module.sm.DSProductId
  key_vault_id = azurerm_key_vault.ds_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ds_policy]
}

resource "azurerm_key_vault_secret" "ds_client_sharedkey" {
  name         = "xmpro--xmidentity--client--sharedkey"
  value        = module.sm.DSProductKey #data.external.deployment_script_outputs.result["DSProductKey"]
  key_vault_id = azurerm_key_vault.ds_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_ds_policy]
}