resource "azurerm_storage_account" "storage_account" {
  resource_group_name = azurerm_resource_group.xmprodocker.name
  location            = azurerm_resource_group.xmprodocker.location

  name = "st${var.prefix}${var.environment}001"

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }
}
